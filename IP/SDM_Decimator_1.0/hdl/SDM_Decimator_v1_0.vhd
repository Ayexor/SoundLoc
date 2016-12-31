library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SDM_Decimator_v1_0 is
	generic(
		-- Users to add parameters here
		D_WIDTH            : integer range 1 to 32   := 25; -- Internal width
		D_OUT_WIDTH        : integer range 1 to 18   := 16; -- Output Data width (DSP support Data up to 18 Bit)
		DIVIDE             : integer range 4 to 1024 := 40; -- Divider to generate BS clk
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S_AXI
		C_S_AXI_DATA_WIDTH : integer                 := 32;
		C_S_AXI_ADDR_WIDTH : integer                 := 5
	);
	port(
		-- Users to add ports here
		mic_clk       : out STD_LOGIC;  -- Bitstream clock
		mic_bs        : in  std_logic_vector(2 downto 0); -- Bitstream from DSM
		irq_new_val   : out std_logic;  -- interrupt every decimation cycle
		new_val       : out std_logic;  -- interrupt every decimation cycle
		val0          : out signed(D_OUT_WIDTH - 1 downto 0);
		val1          : out signed(D_OUT_WIDTH - 1 downto 0);
		val2          : out signed(D_OUT_WIDTH - 1 downto 0);

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S_AXI
		s_axi_aclk    : in  std_logic;
		s_axi_aresetn : in  std_logic;
		s_axi_awaddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		s_axi_awprot  : in  std_logic_vector(2 downto 0);
		s_axi_awvalid : in  std_logic;
		s_axi_awready : out std_logic;
		s_axi_wdata   : in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		s_axi_wstrb   : in  std_logic_vector((C_S_AXI_DATA_WIDTH / 8) - 1 downto 0);
		s_axi_wvalid  : in  std_logic;
		s_axi_wready  : out std_logic;
		s_axi_bresp   : out std_logic_vector(1 downto 0);
		s_axi_bvalid  : out std_logic;
		s_axi_bready  : in  std_logic;
		s_axi_araddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		s_axi_arprot  : in  std_logic_vector(2 downto 0);
		s_axi_arvalid : in  std_logic;
		s_axi_arready : out std_logic;
		s_axi_rdata   : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		s_axi_rresp   : out std_logic_vector(1 downto 0);
		s_axi_rvalid  : out std_logic;
		s_axi_rready  : in  std_logic
	);
end SDM_Decimator_v1_0;

architecture arch_imp of SDM_Decimator_v1_0 is
	type mic_data_t is array (2 downto 0) of signed(D_WIDTH - 1 downto 0);
	signal decim_max, decim_cnt, decim_cnt_next : unsigned(D_WIDTH - 1 downto 0);
	signal iir_sr, post_divide                  : unsigned(3 downto 0);

	signal val_i                                          : mic_data_t;
	signal val0_i, val1_i, val2_i                         : signed(D_OUT_WIDTH - 1 downto 0);
	signal decim_ena, clk, rst, irq_ena, clk_ena, iir_ena : std_logic;
	signal order                                          : std_logic_vector(1 downto 0);

	component CIC
		generic(D_WIDTH : integer range 1 to 32 := 16);
		port(clk       : in  STD_LOGIC;
			 rst       : in  STD_LOGIC;
			 bs_ena    : in  STD_LOGIC;
			 decim_ena : in  STD_LOGIC;
			 order     : in  STD_LOGIC_VECTOR(1 DOWNTO 0);
			 iir_ena   : in  STD_LOGIC;
			 iir_sr    : in  unsigned(3 downto 0);
			 bs        : in  STD_LOGIC;
			 val       : out signed(D_WIDTH - 1 downto 0));
	end component CIC;
begin
	clk <= s_axi_aclk;
	rst <= '1' when ((s_axi_aresetn = '0') or (order = "00")) else '0';

	clk_divider : process(rst, clk) is
		variable cnt : integer range 0 to DIVIDE;
	begin
		if rst = '1' then
			cnt     := 0;
			mic_clk <= '1';
			clk_ena <= '0';
		elsif rising_edge(clk) then
			-- FF working on active edge only!
			-- Using FF already divides clock by 2!
			if cnt > DIVIDE / 2 then
				mic_clk <= '0';
			else
				mic_clk <= '1';
			end if;

			if cnt = DIVIDE then
				clk_ena <= '1';         -- ce by rising edge of bs_clk !
				cnt     := 1;
			else
				clk_ena <= '0';
				cnt     := cnt + 1;
			end if;
		end if;
	end process clk_divider;

	sig_resize : process(val_i, post_divide) is
		variable discard_bits : integer range 0 to 15;
	begin
		discard_bits := to_integer(post_divide);
		val0_i       <= resize(shift_right(val_i(0), discard_bits), D_OUT_WIDTH);
		val1_i       <= resize(shift_right(val_i(1), discard_bits), D_OUT_WIDTH);
		val2_i       <= resize(shift_right(val_i(2), discard_bits), D_OUT_WIDTH);
	end process;
	val0 <= val0_i;
	val1 <= val1_i;
	val2 <= val2_i;

	-- Instantiation of Axi Bus Interface S_AXI
	SDM_Decimator_v1_0_S_AXI_inst : entity work.SDM_Decimator_v1_0_S_AXI
		generic map(
			D_WIDTH            => D_WIDTH,
			C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
			C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
		)
		port map(
			val0          => resize(val0_i, D_WIDTH),
			val1          => resize(val1_i, D_WIDTH),
			val2          => resize(val2_i, D_WIDTH),
			order         => order,
			decim_max     => decim_max,
			irq_ena       => irq_ena,
			post_divide   => post_divide,
			iir_ena       => iir_ena,
			iir_sr        => iir_sr,
			S_AXI_ACLK    => s_axi_aclk,
			S_AXI_ARESETN => s_axi_aresetn,
			S_AXI_AWADDR  => s_axi_awaddr,
			S_AXI_AWPROT  => s_axi_awprot,
			S_AXI_AWVALID => s_axi_awvalid,
			S_AXI_AWREADY => s_axi_awready,
			S_AXI_WDATA   => s_axi_wdata,
			S_AXI_WSTRB   => s_axi_wstrb,
			S_AXI_WVALID  => s_axi_wvalid,
			S_AXI_WREADY  => s_axi_wready,
			S_AXI_BRESP   => s_axi_bresp,
			S_AXI_BVALID  => s_axi_bvalid,
			S_AXI_BREADY  => s_axi_bready,
			S_AXI_ARADDR  => s_axi_araddr,
			S_AXI_ARPROT  => s_axi_arprot,
			S_AXI_ARVALID => s_axi_arvalid,
			S_AXI_ARREADY => s_axi_arready,
			S_AXI_RDATA   => s_axi_rdata,
			S_AXI_RRESP   => s_axi_rresp,
			S_AXI_RVALID  => s_axi_rvalid,
			S_AXI_RREADY  => s_axi_rready
		);

	-- Add user logic here
	filt : for i in 0 to 2 generate
		u0 : component CIC
			generic map(
				D_WIDTH => D_WIDTH
			)
			port map(
				clk       => clk,
				rst       => rst,
				bs_ena    => clk_ena,
				decim_ena => decim_ena,
				order     => order,
				iir_ena   => iir_ena,
				iir_sr    => iir_sr,
				bs        => mic_bs(i),
				val       => val_i(i)
			);
	end generate filt;

	-- Logic for decimation
	irq_new_val <= irq_ena when decim_cnt = 1 else '0';
	new_val     <= '1' when decim_cnt = 1 else '0';

	decim_comb : decim_cnt_next <= to_unsigned(1, D_WIDTH) when decim_cnt >= decim_max else decim_cnt + 1;
	decim_fsm : process(clk, rst) is
	begin
		if rst = '1' then
			decim_cnt <= (others => '0');
		elsif rising_edge(clk) then
			decim_ena <= '0';
			if clk_ena = '1' then
				decim_cnt <= decim_cnt_next;
				if decim_cnt = decim_max then
					decim_ena <= '1';
				end if;
			end if;
		end if;
	end process;

-- User logic ends

end arch_imp;
