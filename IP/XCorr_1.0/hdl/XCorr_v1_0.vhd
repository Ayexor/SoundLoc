library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.math_real.all;

use work.xcorr_pkg.all;

entity XCorr_v1_0 is
	generic(
		-- Users to add parameters here
		D_WIDTH             : integer range 1 to 18 := 16; -- Internal mic data width
		D_SAMPLE_ADDR_WIDTH : integer range 6 to 16 := 10;
		D_TAU_MAX           : integer range 4 to 64 := 16;
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
		irq           : out  std_logic;
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
	constant TAU_OFFSET   : integer := (D_TAU_MAX + 1) / 2; -- Address offset for TAU in excess format. (+1 for ceil())
	constant MIC_ADDR_MAX : integer := (2 ** D_SAMPLE_ADDR_WIDTH) - 1;

--	type T_CORR_RAM is array (0 to D_TAU_MAX - 1) of signed(R_WIDTH-1 downto 0);
	type T_STATE is (idle, store_sample, start, recalc_corr);

	signal rst                                        : std_logic;
	signal mic0_i, mic1_i, mic2_i                     : signed(D_WIDTH - 1 downto 0); -- Microphone value fetched by FB stage
	signal corr_ram01, corr_ram02                     : T_CORR_RAM(0 to D_TAU_MAX-1);
	signal sample_store_addr                          : integer range 0 to MIC_ADDR_MAX; -- Address at which to store new sample
	signal state, next_state                          : T_STATE; -- state and next_state for fsm
	signal store_sample_ena							  : std_logic; -- enables write of mic data to ram
	signal recalc_start, recalc_ena, recalc_done      : std_logic; -- signals to controll recalculation
	signal ce_FA, ce_MACA, ce_FB, ce_MACB, ce_SA      : std_logic; -- Clock enable signals for fetch, MAC and Store stages
	signal FA_mic0, FA_mic1, FA_mic2                  : signed(D_WIDTH - 1 downto 0); -- Microphone value fetched by FA stage
	signal FA_corr01, FA_corr02                       : signed(R_WIDTH-1 downto 0); -- Correlation value fetched by FA stage
	signal FB_mic0, FB_mic1, FB_mic2                  : signed(D_WIDTH - 1 downto 0); -- Microphone value fetched by FB stage
	signal MACA01_P, MACA02_P, MACA01_FF, MACA02_FF : signed(R_WIDTH-1 downto 0); -- Output of DSP and DSP Flipflops of MACA stage
	signal MACB01_P, MACB02_P : signed(R_WIDTH -1 downto 0); -- Output of DSP of MACB stage
	signal tau_cnt, FA_tau, FB_tau, SA_tau            : integer range 0 to D_TAU_MAX - 1; -- Tau signals for counter, fetch and store stages

	signal FA_mic_addr0, FA_mic_addr1, FA_mic_addr2    : integer range 0 to MIC_ADDR_MAX; --Address at which to fetch microphon data in stage A
	signal ram_mic_addr0, ram_mic_addr1, ram_mic_addr2 : integer range 0 to MIC_ADDR_MAX; --Address at which to fetch microphon data in stage A
	signal FB_mic_addr0, FB_mic_addr1, FB_mic_addr2    : integer range 0 to MIC_ADDR_MAX; --Address at which to fetch microphon data in stage B

	signal clear_ram, mic_ram_we : std_logic;

	function addr_dec(addr : integer) return integer is
	begin
		if addr = 0 then
			return MIC_ADDR_MAX;
		else
			return addr - 1;            -- ringbuffer implementation
		end if;
	end function addr_dec;

	procedure addr_old_decode(oldest_sample_addr, tau : in integer; mic_addr0, mic_addr1 : out integer) is
	begin
		if tau < TAU_OFFSET then
			if oldest_sample_addr < TAU_OFFSET-tau then -- address overflow
				mic_addr0 := oldest_sample_addr + (MIC_ADDR_MAX - (TAU_OFFSET - tau) + 1);
			else
				mic_addr0 := oldest_sample_addr - (TAU_OFFSET - tau);
			end if;
			mic_addr1 := oldest_sample_addr;
		else -- tau positiv (tau>TAU_OFFSET)
			mic_addr0 := oldest_sample_addr;
			if oldest_sample_addr < tau-TAU_OFFSET then -- address overflow
				mic_addr1 := oldest_sample_addr + (MIC_ADDR_MAX - (tau - TAU_OFFSET) + 1);
			else
				mic_addr1 := oldest_sample_addr - (tau - TAU_OFFSET);
			end if;
		end if;
	end procedure addr_old_decode;

	procedure addr_new_decode(oldest_sample_addr, tau : in integer; mic_addr0, mic_addr1 : out integer) is
		variable newest_addr          : integer range 0 to MIC_ADDR_MAX := oldest_sample_addr; -- Address with newest value
	begin
		--tau := tau - TAU_OFFSET;
		newest_addr := addr_dec(oldest_sample_addr);
		if tau < TAU_OFFSET then
			mic_addr0 := newest_addr;
			if newest_addr < TAU_OFFSET - tau then   -- address overflow
				mic_addr1 := newest_addr + (MIC_ADDR_MAX - (TAU_OFFSET - tau) + 1);
			else
				mic_addr1 := newest_addr - (TAU_OFFSET - tau); -- tau - TAU_OFFSET
			end if;
		else -- tau positiv (tau>TAU_OFFSET)
			if newest_addr < tau - TAU_OFFSET then   -- address overflow
				mic_addr0 := newest_addr + (MIC_ADDR_MAX - (tau - TAU_OFFSET) + 1);
			else
				mic_addr0 := newest_addr - (tau - TAU_OFFSET);
			end if;
			mic_addr1 := newest_addr;
		end if;
	end procedure addr_new_decode;

begin
	irq <= recalc_done;

	ram_mic_addr0 <= sample_store_addr when store_sample_ena = '1' else FA_mic_addr0;
	ram_mic_addr1 <= sample_store_addr when store_sample_ena = '1' else FA_mic_addr1;
	ram_mic_addr2 <= sample_store_addr when store_sample_ena = '1' else FA_mic_addr2;
	
	mic_ram_we <= store_sample_ena or clear_ram;
	
	mic0_i <= signed(mic0) when clear_ram = '0' else (others => '0');
	mic1_i <= signed(mic1) when clear_ram = '0' else (others => '0');
	mic2_i <= signed(mic2) when clear_ram = '0' else (others => '0');

	mic0_ram : entity work.block_ram
		generic map(
			D_IS_DUAL => true,
			D_WIDTH => D_WIDTH,
			D_DEPTH => 2 ** D_SAMPLE_ADDR_WIDTH
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
			D_WIDTH => D_WIDTH,
			D_DEPTH => 2 ** D_SAMPLE_ADDR_WIDTH
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
			D_WIDTH => D_WIDTH,
			D_DEPTH => 2 ** D_SAMPLE_ADDR_WIDTH
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

	corr_ram : process(s_axi_aclk) is
	begin
		if rising_edge(s_axi_aclk) then
			if ((rst = '1') or (clear_ram = '1')) then
				corr_ram01 <= (others => (others => '0'));
				corr_ram02 <= (others => (others => '0'));
				FA_corr01 <= (others => '0');
				FA_corr02 <= (others => '0');
			else			 
				if ce_SA = '1' then
					corr_ram01(SA_tau) <= MACB01_P;
					corr_ram02(SA_tau) <= MACB02_P;
				end if;
				if ce_FA = '1' then
					FA_corr01 <= corr_ram01(FA_tau);
					FA_corr02 <= corr_ram02(FA_tau);
				end if;
--				corr_read01 <= resize(corr_ram01(corr_read_addr), 32);
--				corr_read02 <= resize(corr_ram02(corr_read_addr), 32);
			end if;
		end if;
	end process corr_ram;

--	corr_addr_ff : process(s_axi_aclk, rst) is
--	begin
--		if rst = '1' then
--			corr_read_addr_ff <= 0;
--		elsif rising_edge(s_axi_aclk) then
--			corr_read_addr_ff <= corr_read_addr;
--		end if;
--	end process corr_addr_ff;
--	data_valid <= '1' when corr_read_addr_ff = corr_read_addr else '0';

	-- Instantiation of Axi Bus Interface S_AXI
	XCorr_v1_0_S_AXI_inst : entity work.XCorr_v1_0_S_AXI
		generic map(
			D_TAU_MAX          => D_TAU_MAX,
			C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
			C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
		)
		port map(
			xcorr01        => corr_ram01,
			xcorr02        => corr_ram02,
--			corr_read_addr => corr_read_addr,
--			data_valid     => data_valid,
			clear_ram	   => clear_ram,
			S_AXI_ACLK     => s_axi_aclk,
			S_AXI_ARESETN  => s_axi_aresetn,
			S_AXI_AWADDR   => s_axi_awaddr,
			S_AXI_AWVALID  => s_axi_awvalid,
			S_AXI_AWREADY  => s_axi_awready,
			S_AXI_WDATA    => s_axi_wdata,
			S_AXI_WVALID   => s_axi_wvalid,
			S_AXI_WREADY   => s_axi_wready,
			S_AXI_ARADDR   => s_axi_araddr,
			S_AXI_ARVALID  => s_axi_arvalid,
			S_AXI_ARREADY  => s_axi_arready,
			S_AXI_RDATA    => s_axi_rdata,
			S_AXI_RVALID   => s_axi_rvalid,
			S_AXI_RREADY   => s_axi_rready
		);

	-- Add user logic here
	-- reset alias ------------------------------------------------------------
	rst <= not s_axi_aresetn;

	-- Tau logic --------------------------------------------------------------
	tau_logic : process(s_axi_aclk, rst) is
	begin
		if rst = '1' then
			tau_cnt <= 0;
			FA_tau  <= 0;
			FB_tau  <= 0;
			SA_tau  <= 0;
		elsif rising_edge(s_axi_aclk) then
			if recalc_start = '1' then
				tau_cnt <= 1;
				FA_tau  <= 0;
				FB_tau  <= 0;
				SA_tau  <= 0;
			elsif recalc_ena = '1' then
				if tau_cnt > 0 then     -- tau_cnt started with recalc_start (set to 1). 
					if tau_cnt = D_TAU_MAX - 1 then
						tau_cnt <= 0;
					else
						tau_cnt <= tau_cnt + 1;
					end if;
				else                    -- if it's 0, then a recalc cycle is finished
					tau_cnt <= 0;
				end if;
				FA_tau <= tau_cnt;      -- shift taus for stages
				FB_tau <= FA_tau;
				SA_tau <= FB_tau;
			end if;
		end if;
	end process tau_logic;
	-- Address logic end ------------------------------------------------------
	-- State Machine ----------------------------------------------------------
	fsm : process(s_axi_aclk, rst) is
	begin
		if rst = '1' then
			state <= idle;
		elsif rising_edge(s_axi_aclk) then
			state <= next_state;
		end if;
	end process fsm;
	-- State Machine next state logic -----------------------------------------
	fsm_logic : process(new_val, recalc_done, state) is
	begin
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
		end case;
	end process fsm_logic;
	-- Store sample enabel ----------------------------------------------------
	store_sample_ena <= '1' when state = store_sample else '0';
	-- Recalculate signals ----------------------------------------------------
	rec_start_logic : with state select recalc_start <=
		'1' when start,
		'0' when others;
	rec_ena_logic : with state select recalc_ena <=
		'1' when recalc_corr,
		'0' when others;
	rec_done_logic : recalc_done <= '1' when SA_tau = D_TAU_MAX-1 else '0';
	-- clock enabel signals for stages ----------------------------------------
	ce_FA_logic : ce_FA          <= '1' when ((FA_tau > 0) or (tau_cnt = 1)) else '0'; -- valid tau or begining of recalc
	ce_logic : process(s_axi_aclk) is
	begin
		if rising_edge(s_axi_aclk) then
			if rst = '1' then
				ce_MACA <= '0';
				ce_FB   <= '0';
				ce_MACB <= '0';
				ce_SA   <= '0';
			else
				ce_MACA <= ce_FA;       -- if FA gave a falid value, prozess it
				ce_FB   <= ce_FA;       -- if FA had a valid address, FB has it one cycle later, too
				ce_MACB <= ce_MACA;     -- if MACA produces a valid value, MACB now processes its output
				ce_SA   <= ce_FB;       -- if FB had a valid Address, SA has it too, one cycle later
			end if;
		end if;
	end process ce_logic;
	-- State Machine end ------------------------------------------------------
	-- Address logic for storing of microphon samples -------------------------
	sample_store_addr_logic : process(s_axi_aclk, rst) is
	begin
		if rst = '1' then
			sample_store_addr <= 0;
		elsif rising_edge(s_axi_aclk) then
			if mic_ram_we = '1' then
				if sample_store_addr = MIC_ADDR_MAX then
					sample_store_addr <= 0;
				else
					sample_store_addr <= sample_store_addr + 1; -- ringbuffer implementation
				end if;
			end if;
		end if;
	end process sample_store_addr_logic;

	-- Fetch Stage A address logic --------------------------------------------
	process(sample_store_addr, FA_tau) is
		variable v_mic0, v_mic1 : integer range 0 to D_TAU_MAX-1;
	begin
		addr_old_decode(sample_store_addr, FA_tau, v_mic0, v_mic1);
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
			mic0   => FA_mic0,
			mic1   => FA_mic1,
			mic2   => FA_mic2,
			corr01 => FA_corr01,
			corr02 => FA_corr02,
			val01  => MACA01_P,
			val02  => MACA02_P
		);
	-- DSP Stage A FF ---------------------------------------------------------
	MACA_FF : process(s_axi_aclk) is
	begin
		if rising_edge(s_axi_aclk) then
			if s_axi_aresetn = '0' then
				MACA01_FF <= (others => '0');
				MACA02_FF <= (others => '0');
			else
				MACA01_FF <= MACA01_P;
				MACA02_FF <= MACA02_P;
			end if;
		end if;
	end process MACA_FF;
	-- Fetch Stage B address logic --------------------------------------------
	process(sample_store_addr, FB_tau) is
		variable v_mic0, v_mic1 : integer range 0 to D_TAU_MAX-1;
	begin
		addr_new_decode(sample_store_addr, FB_tau, v_mic0, v_mic1);
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
			mic0   => FB_mic0,
			mic1   => FB_mic1,
			mic2   => FB_mic2,
			corr01 => MACA01_FF,
			corr02 => MACA02_FF,
			val01  => MACB01_P,
			val02  => MACB02_P
		);

-- User logic ends

end arch_imp;


