library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.math_real.all;

use work.XCorr_pkg.all;

entity XCorr_v1_0 is
	generic(
		-- Users to add parameters here
		D_WIDTH             : integer range 1 to 18 := 16; -- Internal mic data width
		D_SAMPLE_ADDR_WIDTH : integer range 7 to 16 := 10;
		D_TAU_ADDR_WIDTH    : integer range 4 to 6  := 4;
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S_AXI
		C_S_AXI_DATA_WIDTH  : integer               := 32;
		C_S_AXI_ADDR_WIDTH  : integer               := 10
	);
	port(
		-- Users to add ports here
		mic0          : in  std_logic_vector(D_WIDTH - 1 downto 0);
		mic1          : in  std_logic_vector(D_WIDTH - 1 downto 0);
		mic2          : in  std_logic_vector(D_WIDTH - 1 downto 0);
		new_val       : in  std_logic;
		irq           : out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S_AXI
		s_axi_aclk    : in  std_logic;
		s_axi_aresetn : in  std_logic;
		s_axi_awaddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		s_axi_awvalid : in  std_logic;
		s_axi_awready : out std_logic;
		s_axi_wdata   : in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		s_axi_wvalid  : in  std_logic;
		s_axi_wready  : out std_logic;
		s_axi_bvalid  : out std_logic := '1';
		s_axi_bready  : in  std_logic;
		s_axi_araddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		s_axi_arvalid : in  std_logic;
		s_axi_arready : out std_logic;
		s_axi_rdata   : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		s_axi_rvalid  : out std_logic;
		s_axi_rready  : in  std_logic
	);
end XCorr_v1_0;

architecture arch_imp of XCorr_v1_0 is
	type T_STATE is (idle, store_sample, start, recalc_corr, start_clear, clear);
	constant TAU_MIN : integer := -(2 ** (D_TAU_ADDR_WIDTH - 1));
	constant TAU_MAX : integer := (2 ** (D_TAU_ADDR_WIDTH - 1)) - 1;

	signal rst                    : std_logic;
	signal mic0_i, mic1_i, mic2_i : signed(D_WIDTH - 1 downto 0); -- Microphone value to be stored (0 if clear_ram = '1')
	--	signal corr_ram01, corr_ram02 : T_CORR_RAM(TAU_MIN + 1 to TAU_MAX);

	signal sample_store_addr               : unsigned(D_SAMPLE_ADDR_WIDTH - 1 downto 0); -- Address at which to store new sample
	signal tau_cnt, FA_tau, FB_tau, SA_tau : signed(D_TAU_ADDR_WIDTH - 1 downto 0); -- Tau signals for counter, fetch and store stages

	signal state, next_state               : T_STATE; -- state and next_state for fsm
	signal store_sample_ena, clear_ram_ena : std_logic; -- enables write of mic data to ram
	signal recalc_start, recalc_done       : std_logic; -- signals to controll recalculation
	--	signal recalc_ena : std_logic; -- signals to controll recalculation
	--	signal ce_FA                                 : std_logic; -- Clock enable signals for fetch stage
	signal ce_SA                           : std_logic; -- Clock enable signals for store stage

	signal FA_mic0, FA_mic1, FA_mic2 : signed(D_WIDTH - 1 downto 0); -- Microphone value fetched by FA stage
	signal FA_corr01, FA_corr02      : signed(R_WIDTH - 1 downto 0); -- Correlation value fetched by FA stage
	signal FB_mic0, FB_mic1, FB_mic2 : signed(D_WIDTH - 1 downto 0); -- Microphone value fetched by FB stage
	signal MACA01_FF, MACA02_FF      : signed(R_WIDTH - 1 downto 0); -- Output of DSP and DSP Flipflops of MACA stage
	signal MACB01_FF, MACB02_FF      : signed(R_WIDTH - 1 downto 0); -- Output of DSP of MACB stage

	signal FA_mic_addr0, FA_mic_addr1, FA_mic_addr2    : unsigned(D_SAMPLE_ADDR_WIDTH - 1 downto 0); --Address at which to fetch microphon data in stage A
	signal ram_mic_addr0, ram_mic_addr1, ram_mic_addr2 : unsigned(D_SAMPLE_ADDR_WIDTH - 1 downto 0); --Address at which to fetch microphon data in stage A
	signal FB_mic_addr0, FB_mic_addr1, FB_mic_addr2    : unsigned(D_SAMPLE_ADDR_WIDTH - 1 downto 0); --Address at which to fetch microphon data in stage B

	signal clear_ram, mic_ram_we : std_logic;

	-- maximum evaluation
	signal max01_eval, max02_eval         : signed(R_WIDTH - 1 downto 0); -- greatest xcorr value
	signal max_tau01_eval, max_tau02_eval : signed(D_TAU_ADDR_WIDTH - 1 downto 0); -- Tau pointing to largest value

	-- ff for found max_taus
	signal max_tau01, max_tau02 : signed(D_TAU_ADDR_WIDTH - 1 downto 0); -- Tau pointing to largest value
	--axi corr read
	--	signal corr01_axi, corr02_axi, ram_out01, ram_out02 : signed(R_WIDTH - 1 downto 0); -- xcorr value read by axi
	--	signal tau_ram, tau_axi, tau_ram_act                : signed(D_TAU_ADDR_WIDTH - 1 downto 0); -- taus for ram
	--	signal corr_data_valid                              : std_logic; -- enables write of mic data to ram


	procedure addr_old_decode(
			oldest_sample_addr   : in  unsigned(D_SAMPLE_ADDR_WIDTH - 1 downto 0);
			tau                  : in  signed(D_TAU_ADDR_WIDTH - 1 downto 0);
			mic_addr0, mic_addr1 : out unsigned(D_SAMPLE_ADDR_WIDTH - 1 downto 0)
		) is
	begin
		if tau < 0 then
			mic_addr0 := oldest_sample_addr - to_integer(tau);
			mic_addr1 := oldest_sample_addr;
		else                            -- tau positiv (tau>TAU_OFFSET)
			mic_addr0 := oldest_sample_addr;
			mic_addr1 := oldest_sample_addr + to_integer(tau);
		end if;
	end procedure addr_old_decode;

	procedure addr_new_decode(
			oldest_sample_addr   : in  unsigned(D_SAMPLE_ADDR_WIDTH - 1 downto 0);
			tau                  : in  signed(D_TAU_ADDR_WIDTH - 1 downto 0);
			mic_addr0, mic_addr1 : out unsigned(D_SAMPLE_ADDR_WIDTH - 1 downto 0)
		) is
		variable newest_addr : unsigned(D_SAMPLE_ADDR_WIDTH - 1 downto 0); -- Address with newest value
	begin
		--tau := tau - TAU_OFFSET;
		newest_addr := oldest_sample_addr - 1;
		if tau < 0 then
			mic_addr0 := newest_addr;
			mic_addr1 := newest_addr + to_integer(tau);
		else
			mic_addr0 := newest_addr - to_integer(tau);
			mic_addr1 := newest_addr;
		end if;
	end procedure addr_new_decode;

begin
	irq <= recalc_done;

	ram_mic_addr0 <= sample_store_addr when store_sample_ena = '1' else FA_mic_addr0;
	ram_mic_addr1 <= sample_store_addr when store_sample_ena = '1' else FA_mic_addr1;
	ram_mic_addr2 <= sample_store_addr when store_sample_ena = '1' else FA_mic_addr2;

	clear_ram_ena <= '1' when state = clear or state = start_clear else '0';
	mic_ram_we    <= clear_ram_ena or store_sample_ena;

	mic0_i <= signed(mic0) when clear_ram = '0' else (others => '0');
	mic1_i <= signed(mic1) when clear_ram = '0' else (others => '0');
	mic2_i <= signed(mic2) when clear_ram = '0' else (others => '0');

	mic0_ram : entity work.block_ram
		generic map(
			D_IS_DUAL => true,
			D_WIDTH   => D_WIDTH,
			A_WIDTH   => D_SAMPLE_ADDR_WIDTH
		)
		port map(
			Clk  => s_axi_aclk,
			aa   => ram_mic_addr0,
			ab   => FB_mic_addr0,
			wae  => mic_ram_we,
			wbe  => '0',
			da_i => mic0_i,
			da_o => FA_mic0,
			db_i => (others => '0'),
			db_o => FB_mic0
		);
	mic1_ram : entity work.block_ram
		generic map(
			D_IS_DUAL => true,
			D_WIDTH   => D_WIDTH,
			A_WIDTH   => D_SAMPLE_ADDR_WIDTH
		)
		port map(
			Clk  => s_axi_aclk,
			aa   => ram_mic_addr1,
			ab   => FB_mic_addr1,
			wae  => mic_ram_we,
			wbe  => '0',
			da_i => mic1_i,
			da_o => FA_mic1,
			db_i => (others => '0'),
			db_o => FB_mic1
		);
	mic2_ram : entity work.block_ram
		generic map(
			D_IS_DUAL => true,
			D_WIDTH   => D_WIDTH,
			A_WIDTH   => D_SAMPLE_ADDR_WIDTH
		)
		port map(
			Clk  => s_axi_aclk,
			aa   => ram_mic_addr2,
			ab   => FB_mic_addr2,
			wae  => mic_ram_we,
			wbe  => '0',
			da_i => mic2_i,
			da_o => FA_mic2,
			db_i => (others => '0'),
			db_o => FB_mic2
		);

	corr01_ram : entity work.block_ram
		generic map(
			D_IS_DUAL => true,
			D_WIDTH   => R_WIDTH,
			A_WIDTH   => D_TAU_ADDR_WIDTH
		)
		port map(
			Clk  => s_axi_aclk,
			aa   => unsigned(SA_tau),
			ab   => unsigned(tau_cnt),
			wae  => ce_SA,
			wbe  => '0',
			da_i => MACB01_FF,
			da_o => open,
			db_i => (others => '0'),
			db_o => FA_corr01
		);

	corr02_ram : entity work.block_ram
		generic map(
			D_IS_DUAL => true,
			D_WIDTH   => R_WIDTH,
			A_WIDTH   => D_TAU_ADDR_WIDTH
		)
		port map(
			Clk  => s_axi_aclk,
			aa   => unsigned(SA_tau),
			ab   => unsigned(tau_cnt),
			wae  => ce_SA,
			wbe  => '0',
			da_i => MACB02_FF,
			da_o => open,
			db_i => (others => '0'),
			db_o => FA_corr02
		);

	--	corr_addr_sel : process(FA_tau, state, tau_axi, ram_out01, ram_out02) is
	--	begin
	--		if state = idle then
	--			tau_ram    <= tau_axi;
	--			FA_corr01  <= (others => '0');
	--			corr01_axi <= ram_out01;
	--			FA_corr02  <= (others => '0');
	--			corr02_axi <= ram_out02;
	--		else
	--			tau_ram    <= FA_tau;
	--			FA_corr01  <= ram_out01;
	--			corr01_axi <= (others => '0');
	--			FA_corr02  <= ram_out02;
	--			corr02_axi <= (others => '0');
	--		end if;
	--	end process corr_addr_sel;

	--	-- data is valid for AXI read iff state is idle (read on port B set to tau_axi)
	--	-- and address was stable for one clock (data onm output port of ram corresponds to the address)
	--	corr_data_valid_gen : corr_data_valid <= '1' when state = idle and tau_ram_act = tau_ram else '0';
	--
	--	tau_ram_act_p : process(s_axi_aclk) is
	--	begin
	--		if rising_edge(s_axi_aclk) then
	--			tau_ram_act <= tau_ram;
	--		end if;
	--	end process tau_ram_act_p;

	-- Instantiation of Axi Bus Interface S_AXI
	XCorr_v1_0_S_AXI_inst : entity work.XCorr_v1_0_S_AXI
		generic map(
			D_TAU_ADDR_WIDTH   => D_TAU_ADDR_WIDTH,
			C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
			C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
		)
		port map(
			--			corr01_axi      => corr01_axi,
			--			corr02_axi      => corr02_axi,
			--			corr_data_valid => corr_data_valid,
			--			tau_axi         => tau_axi,
			max_tau01     => max_tau01,
			max_tau02     => max_tau02,
			clear_ram     => clear_ram,
			clear_ram_ena => clear_ram_ena,
			S_AXI_ACLK    => s_axi_aclk,
			S_AXI_ARESETN => s_axi_aresetn,
			S_AXI_AWADDR  => s_axi_awaddr,
			S_AXI_AWVALID => s_axi_awvalid,
			S_AXI_AWREADY => s_axi_awready,
			S_AXI_WDATA   => s_axi_wdata,
			S_AXI_WVALID  => s_axi_wvalid,
			S_AXI_WREADY  => s_axi_wready,
			S_AXI_ARADDR  => s_axi_araddr,
			S_AXI_ARVALID => s_axi_arvalid,
			S_AXI_ARREADY => s_axi_arready,
			S_AXI_RDATA   => s_axi_rdata,
			S_AXI_RVALID  => s_axi_rvalid,
			S_AXI_RREADY  => s_axi_rready
		);

	-- Add user logic here
	-- reset alias ------------------------------------------------------------
	rst <= not s_axi_aresetn;

	-- Tau logic --------------------------------------------------------------
	tau_ff : process(s_axi_aclk) is
	begin
		if rising_edge(s_axi_aclk) then
			if rst = '1' or tau_cnt = TAU_MIN then
				tau_cnt(D_TAU_ADDR_WIDTH - 1)          <= '1';
				tau_cnt(D_TAU_ADDR_WIDTH - 2 downto 1) <= (others => '0');
				tau_cnt(0)                             <= recalc_start;
			else
				tau_cnt <= tau_cnt + 1;
			end if;
		end if;
	end process tau_ff;

	tau_shift : process(s_axi_aclk) is
	begin
		if rising_edge(s_axi_aclk) then
			if rst = '1' or recalc_start = '1' then
				FA_tau <= to_signed(TAU_MIN, D_TAU_ADDR_WIDTH);
				FB_tau <= to_signed(TAU_MIN, D_TAU_ADDR_WIDTH);
				SA_tau <= to_signed(TAU_MIN, D_TAU_ADDR_WIDTH);
			else
				FA_tau <= tau_cnt;      -- shift taus for stages
				FB_tau <= FA_tau;
				SA_tau <= FB_tau;
			end if;
		end if;
	end process tau_shift;
	-- Address logic end ------------------------------------------------------
	-- State Machine ----------------------------------------------------------
	fsm : process(s_axi_aclk) is
	begin
		if rising_edge(s_axi_aclk) then
			if rst = '1' then
				state <= idle;
			else
				state <= next_state;
			end if;
		end if;
	end process fsm;
	-- State Machine next state logic -----------------------------------------
	fsm_logic : process(new_val, clear_ram, recalc_done, state, sample_store_addr) is
	begin
		if clear_ram = '1' then
			next_state <= start_clear;
		else
			case state is
				when idle =>
					if new_val = '1' then
						next_state <= store_sample;
					else
						next_state <= idle;
					end if;
				when store_sample =>
					next_state <= start;
				when start =>
					next_state <= recalc_corr;
				when recalc_corr =>
					if recalc_done = '1' then
						next_state <= idle;
					else
						next_state <= recalc_corr;
					end if;
				when start_clear =>
					next_state <= clear;
				when clear =>
					if sample_store_addr = unsigned(to_signed(-1, D_SAMPLE_ADDR_WIDTH)) then -- (others => '1') doesn't work in equality check
						next_state <= idle;
					else
						next_state <= clear;
					end if;
			end case;
		end if;
	end process fsm_logic;

	-- Store sample enabel ----------------------------------------------------
	store_sample_ena <= '1' when state = store_sample else '0';

	-- Recalculate signals ----------------------------------------------------
	rec_start_logic : with state select recalc_start <=
		'1' when start | start_clear,
		'0' when others;
	--	rec_ena_logic : with state select recalc_ena <=
	--		'1' when recalc_corr | clear,
	--		'0' when others;
	rec_done_logic : recalc_done <= '1' when SA_tau = TAU_MAX and state /= clear else '0';

	-- clock enabel signals for stages ----------------------------------------
	--	ce_FA_logic : ce_FA <= '1' when ((FA_tau /= TAU_MIN) or (tau_cnt = TAU_MIN + 1)) else '0'; -- valid tau or begining of recalc
	ce_SA_logic : ce_SA <= '1' when SA_tau /= TAU_MIN else '0'; -- valid tau

	-- State Machine end ------------------------------------------------------
	-- Address logic for storing of microphon samples -------------------------
	sample_store_addr_logic : process(s_axi_aclk) is
	begin
		if rising_edge(s_axi_aclk) then
			if rst = '1' or clear_ram = '1' then
				sample_store_addr <= (others => '0');
			else
				if mic_ram_we = '1' then
					sample_store_addr <= sample_store_addr + 1; -- ringbuffer implementation by overflow of address
				end if;
			end if;
		end if;
	end process sample_store_addr_logic;

	-- Fetch Stage A address logic --------------------------------------------
	process(sample_store_addr, tau_cnt) is
		variable v_mic0, v_mic1 : unsigned(D_SAMPLE_ADDR_WIDTH - 1 downto 0);
	begin
		addr_old_decode(sample_store_addr, tau_cnt, v_mic0, v_mic1);
		FA_mic_addr0 <= v_mic0;
		FA_mic_addr1 <= v_mic1;
	end process;
	FA_mic_addr2 <= FA_mic_addr1;

	-- DSP Stage A ------------------------------------------------------------
	MACA : entity work.corr_DSP
		generic map(
			D_WIDTH  => D_WIDTH,
			SUBTRACT => true
		)
		port map(
			clk    => s_axi_aclk,
			mic0   => FA_mic0,
			mic1   => FA_mic1,
			mic2   => FA_mic2,
			corr01 => FA_corr01,
			corr02 => FA_corr02,
			val01  => MACA01_FF,
			val02  => MACA02_FF
		);
	-- Fetch Stage B address logic --------------------------------------------
	process(sample_store_addr, FA_tau) is
		variable v_mic0, v_mic1 : unsigned(D_SAMPLE_ADDR_WIDTH - 1 downto 0);
	begin
		addr_new_decode(sample_store_addr, FA_tau, v_mic0, v_mic1);
		FB_mic_addr0 <= v_mic0;
		FB_mic_addr1 <= v_mic1;
	end process;
	FB_mic_addr2 <= FB_mic_addr1;
	-- DSP Stage B ------------------------------------------------------------
	MACB : entity work.corr_DSP
		generic map(
			D_WIDTH  => D_WIDTH,
			SUBTRACT => false
		)
		port map(
			clk    => s_axi_aclk,
			mic0   => FB_mic0,
			mic1   => FB_mic1,
			mic2   => FB_mic2,
			corr01 => MACA01_FF,
			corr02 => MACA02_FF,
			val01  => MACB01_FF,
			val02  => MACB02_FF
		);

	-- Maximum detection ------------------------------------------------------

	max_p : process(s_axi_aclk) is
	begin
		if rising_edge(s_axi_aclk) then
			if rst = '1' or state = start then
				max01_eval(R_WIDTH - 1)          <= '1';
				max02_eval(R_WIDTH - 1)          <= '1';
				max01_eval(R_WIDTH - 2 downto 0) <= (others => '0');
				max02_eval(R_WIDTH - 2 downto 0) <= (others => '0');
				max_tau01_eval                   <= to_signed(TAU_MIN, D_TAU_ADDR_WIDTH);
				max_tau02_eval                   <= to_signed(TAU_MIN, D_TAU_ADDR_WIDTH);
			else
				if ce_SA = '1' then
					if MACB01_FF > max01_eval then
						max01_eval     <= MACB01_FF;
						max_tau01_eval <= SA_tau;
					end if;
					if MACB02_FF > max02_eval then
						max02_eval     <= MACB02_FF;
						max_tau02_eval <= SA_tau;
					end if;
				end if;
			end if;
		end if;
	end process max_p;

	max_latch : process(s_axi_aclk) is
	begin
		if rising_edge(s_axi_aclk) then
			if rst = '1' then
				max_tau01 <= to_signed(TAU_MIN, D_TAU_ADDR_WIDTH);
				max_tau02 <= to_signed(TAU_MIN, D_TAU_ADDR_WIDTH);
			else
				if recalc_done = '1' then
					max_tau01 <= max_tau01_eval;
					max_tau02 <= max_tau02_eval;
				end if;
			end if;
		end if;
	end process max_latch;

-- User logic ends

end arch_imp;


