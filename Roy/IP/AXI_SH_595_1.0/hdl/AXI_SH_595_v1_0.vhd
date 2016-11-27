------------------------------------------------------------------------------
-- AXI Lite Peripheral for Shift Registers 74xx595
-- Roy Seitz, 2016-10-10 (rseitz@hsr.ch)
-- Supports up to 4 shift registers in dasy chain
-- Unused data pins should be left unconnected. If one register is not fully
-- used (e.g. only 4 bits), remaining bits  are undefined.
-- UNUSED DATA PINS MUST BE LEFT UNCONNECTED.
------------------------------------------------------------------------------
-- Usage:
-- 1.	Write data to REG0
-- 2.	Write '1' to REG1
------------------------------------------------------------------------------
-- Register Description
-- REG0: 	Write only register with data to write to the SH595
-- REG1: 	write '1' to programm SH. 
--			Read returns '1' if Logic is ready to accept Data
-- REG2: 	Status Register (Read/Write)
--				bit 0:	Low active reset
--				bit 1:	Low active output enable (if C_USE_OE_N = true)
------------------------------------------------------------------------------
-- Constants:
--	C_SH_DATA_WIDTH:	The SH Width. Supports up to 4 74xx595 in
--							Dasy Chain connection. Data is shifted 
--							out MSB first. If less then n*8bit are used
--							remaining bits are undefined.
--	C_CLOCK_DEZIMATION:	The dezimation factor by which S_AXI_ACLK 
--       				is divided. SH_CLK is half that Clock
--	C_USE_OE_N:			Set to TRUE if OEn is needed. Otherwise
--						OEn is driven to constant '0' 
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity AXI_SH_595_v1_0 is
	generic(
		-- Users to add parameters here
		C_SH_DATA_WIDTH    : integer := 8;
		C_USE_OE_N         : boolean := true;
		C_CLOCK_DEZIMATION : integer := 100;
		C_MSB_FIRST        : boolean := true;
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S_AXI
		C_S_AXI_DATA_WIDTH : integer := 32;
		C_S_AXI_ADDR_WIDTH : integer := 4
	);
	port(
		-- Users to add ports here
		shClk         : out std_logic;
		shStr         : out std_logic;
		shOEn         : out std_logic;
		shData        : out std_logic;
		shRstn        : out std_logic;

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
		s_axi_bvalid  : out std_logic;
		s_axi_bready  : in  std_logic;
		s_axi_araddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
		s_axi_arvalid : in  std_logic                                         := '0';
		s_axi_arready : out std_logic                                         := '1';
		s_axi_rdata   : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
		s_axi_rresp   : out std_logic_vector(1 downto 0)                      := "00";
		s_axi_rvalid  : out std_logic                                         := '1';
		s_axi_rready  : in  std_logic                                         := '0'
	);
end AXI_SH_595_v1_0;

architecture arch_imp of AXI_SH_595_v1_0 is
	type tState is (idle, start, setData, shift, done);
	-- idle		: wait for setSh = '1'
	-- start	: store dIn in dataReg
	-- setData	: apply next bit
	-- shift	: shift in applied bit
	-- done		: update outputs of SH

	signal data_reg               : std_logic_vector(C_SH_DATA_WIDTH - 1 downto 0);
	signal status_reg             : std_logic_vector(1 downto 0);
	signal ready, prog_sh, rstn_i : std_logic; --low active
	signal state, nState          : tState;
	signal SH_cnt                 : unsigned(integer(floor(log2(real(C_SH_DATA_WIDTH)))) downto 0); -- counter for #bits left
	signal fsm_clk_en             : std_logic;
	signal clk_divider_cnt        : natural range 0 to C_CLOCK_DEZIMATION - 1;

begin

	-- Instantiation of Axi Bus Interface S_AXI
	u1 : entity work.AXI_SH_595_v1_0_S_AXI
		generic map(
			C_SH_DATA_WIDTH    => C_SH_DATA_WIDTH,
			C_USE_OE_N         => C_USE_OE_N,
			C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
			C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
		)
		port map(
			ready         => ready,
			data_reg      => data_reg,
			status_reg    => status_reg,
			prog_sh       => prog_sh,
			S_AXI_ACLK    => s_axi_aclk,
			S_AXI_ARESETN => s_axi_aresetn,
			S_AXI_AWADDR  => s_axi_awaddr,
			S_AXI_AWVALID => s_axi_awvalid,
			S_AXI_AWREADY => s_axi_awready,
			S_AXI_WDATA   => s_axi_wdata,
			S_AXI_WVALID  => s_axi_wvalid,
			S_AXI_WREADY  => s_axi_wready,
			S_AXI_BVALID  => s_axi_bvalid,
			S_AXI_BREADY  => s_axi_bready,
			S_AXI_ARADDR  => s_axi_araddr,
			S_AXI_ARVALID => s_axi_arvalid,
			S_AXI_ARREADY => s_axi_arready,
			S_AXI_RDATA   => s_axi_rdata,
			S_AXI_RRESP   => s_axi_rresp,
			S_AXI_RVALID  => s_axi_rvalid,
			S_AXI_RREADY  => s_axi_rready
		);

	-- Add user logic here
	rstn_i <= s_axi_aresetn and status_reg(0);
	ready  <= '1' when state = idle else '0';
	shOEn  <= status_reg(1);
	shRstn <= rstn_i;

	pClkDivider : process(s_axi_aclk) is
	begin
		if rising_edge(s_axi_aclk) then
			if rstn_i = '0' then
				fsm_clk_en      <= '0';
				clk_divider_cnt <= 0;
			else
				if state = idle or clk_divider_cnt = C_CLOCK_DEZIMATION - 1 then
					clk_divider_cnt <= 0;
					fsm_clk_en      <= '1';
				else
					clk_divider_cnt <= clk_divider_cnt + 1;
					fsm_clk_en      <= '0';
				end if;
			end if;
		end if;
	end process pClkDivider;

	pCombOut : process(state) is
	begin
		case state is
			when idle =>
				shClk <= '0';
				shStr <= '1';
			when start =>               --str = '0'
				shClk <= '0';
				shStr <= '0';
			when setData =>             --apply data, clk = '0'
				shClk <= '0';
				shStr <= '0';
			when shift =>               -- Shift data in, shClk <= '1'
				shClk <= '1';
				shStr <= '0';
			when done =>                --str = '1', data = '0'
				shClk <= '0';
				shStr <= '1';
		end case;
	end process pCombOut;

	pSH_Data : process (SH_cnt, data_reg) is
	begin
		if SH_cnt < C_SH_DATA_WIDTH then
			if C_MSB_FIRST then
				shData <=  data_reg(to_integer(SH_cnt));
			else
				shData <=  data_reg(to_integer(C_SH_DATA_WIDTH-1-SH_cnt));
			end if;
		else
			shData <= '0';
		end if;
	end process pSH_Data;
	
	pCombInternal : process(state, SH_cnt, prog_sh, fsm_clk_en) is
	begin
		if fsm_clk_en = '0' and state = idle and prog_sh = '1' then
			nState <= start;
		elsif fsm_clk_en = '1' then
			case state is
				when idle =>
					if prog_sh = '1' then
						nState <= start;
					-- else	stay in idle
					end if;
				when start =>
					nState <= setData;
				when setData =>
					nState <= shift;
				when shift =>
					if SH_cnt = 0 then  --all bits set
						nState <= done;
					else                -- set next bit
						nState <= setData;
					end if;
				when done =>
					nState <= idle;
			end case;
		else
			nState <= state;
		end if;
	end process pCombInternal;

	pFsm : process(s_axi_aclk, rstn_i) is
	begin
		if rstn_i = '0' then
			state  <= idle;
			SH_cnt <= to_unsigned(C_SH_DATA_WIDTH - 1, integer(ceil(log2(real(C_SH_DATA_WIDTH)))));
		elsif rising_edge(s_axi_aclk) then
			state <= nState;

			if fsm_clk_en = '1' then
				if state = start then
					SH_cnt <= to_unsigned(C_SH_DATA_WIDTH - 1, integer(ceil(log2(real(C_SH_DATA_WIDTH)))));
				elsif state = shift then
					SH_cnt <= SH_cnt - 1;
				else
					SH_cnt <= SH_cnt;
				end if;
			end if;
		end if;
	end process pFsm;
-- User logic ends

end arch_imp;
