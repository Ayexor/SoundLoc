library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.math_real.all;

use work.xcorr_pkg.all;

entity XCorr_v1_0_S_AXI is
	generic(
		-- Users to add parameters here
		D_TAU_ADDR_WIDTH    : integer range 1 to 6  := 4;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH : integer               := 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH : integer               := 10
	);
	port(
		-- Users to add ports here
		xcorr01, xcorr02 : in  T_CORR_RAM(-(2 ** (D_TAU_ADDR_WIDTH-1))+1 to (2 ** (D_TAU_ADDR_WIDTH-1)) - 1);
--		corr_read_addr   : out integer range 0 to D_TAU_MAX-1;
--		data_valid       : in  std_logic;
		clear_ram: out  std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK       : in  std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN    : in  std_logic;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR     : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		-- Write address valid. This signal indicates that the master signaling
		-- valid write address and control information.
		S_AXI_AWVALID    : in  std_logic;
		-- Write address ready. This signal indicates that the slave is ready
		-- to accept an address and associated control signals.
		S_AXI_AWREADY    : out std_logic;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA      : in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		-- Write valid. This signal indicates that valid write
		-- data and strobes are available.
		S_AXI_WVALID     : in  std_logic;
		-- Write ready. This signal indicates that the slave
		-- can accept the write data.
		S_AXI_WREADY     : out std_logic;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR     : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		-- Read address valid. This signal indicates that the channel
		-- is signaling valid read address and control information.
		S_AXI_ARVALID    : in  std_logic;
		-- Read address ready. This signal indicates that the slave is
		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY    : out std_logic;
		-- Read data (issued by slave)
		S_AXI_RDATA      : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		-- Read valid. This signal indicates that the channel is
		-- signaling the required read data.
		S_AXI_RVALID     : out std_logic;
		-- Read ready. This signal indicates that the master can
		-- accept the read data and response information.
		S_AXI_RREADY     : in  std_logic
	);
end XCorr_v1_0_S_AXI;

architecture arch_imp of XCorr_v1_0_S_AXI is
	-- AXI4LITE signals
	signal axi_awaddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
	signal axi_awready : std_logic;
	signal axi_wready  : std_logic;
	signal axi_araddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
	signal axi_arready : std_logic;
	signal axi_rdata   : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
	signal axi_rvalid  : std_logic;

	-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB          : integer := (C_S_AXI_DATA_WIDTH / 32) + 1;
	constant OPT_MEM_ADDR_BITS : integer := C_S_AXI_ADDR_WIDTH - ADDR_LSB - 1;
	------------------------------------------------
	---- Signals for user logic register space example
	--------------------------------------------------
	---- Number of Slave Registers 10
	type T_REG is array(-(2 ** (D_TAU_ADDR_WIDTH-1))+1 to (2 ** (D_TAU_ADDR_WIDTH-1)) - 1) of std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	
	signal reg01, reg02 : T_REG;
	signal slv_reg0            : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg_rden        : std_logic;
	signal slv_reg_wren        : std_logic;
	signal reg_data_out        : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);

begin
	
	reg_map : process (xcorr01) is
	begin
		for i in -(2 ** (D_TAU_ADDR_WIDTH-1))+1 to (2 ** (D_TAU_ADDR_WIDTH-1)) - 1 loop
			reg01(i) <= std_logic_vector(xcorr01(i));
			reg02(i) <= std_logic_vector(xcorr02(i));
		end loop;
	end process reg_map;
	
	clear_ram  <= slv_reg0(0);
	-- I/O Connections assignments

	S_AXI_AWREADY <= axi_awready;
	S_AXI_WREADY  <= axi_wready;
	S_AXI_ARREADY <= axi_arready;
	S_AXI_RDATA   <= axi_rdata;
	S_AXI_RVALID  <= axi_rvalid;
	-- Implement axi_awready generation
	-- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	-- de-asserted when reset is low.

	process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_awready <= '0';
			else
				if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
					-- slave is ready to accept write address when
					-- there is a valid write address and write data
					-- on the write address and data bus. This design 
					-- expects no outstanding transactions. 
					axi_awready <= '1';
				else
					axi_awready <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Implement axi_awaddr latching
	-- This process is used to latch the address when both 
	-- S_AXI_AWVALID and S_AXI_WVALID are valid. 

	process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_awaddr <= "0000000000";
			else
				if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
					-- Write Address latching
					axi_awaddr <= S_AXI_AWADDR;
				end if;
			end if;
		end if;
	end process;

	-- Implement axi_wready generation
	-- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	-- de-asserted when reset is low. 

	process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_wready <= '0';
			else
				if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1') then
					-- slave is ready to accept write data when 
					-- there is a valid write address and write data
					-- on the write address and data bus. This design 
					-- expects no outstanding transactions.           
					axi_wready <= '1';
				else
					axi_wready <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Implement memory mapped register select and write logic generation
	-- The write data is accepted and written to memory mapped registers when
	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	-- select byte enables of slave registers while writing.
	-- These registers are cleared when reset (active low) is applied.
	-- Slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID;

	process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				slv_reg0 <= (others => '0');
			else
				if (slv_reg_wren = '1') then
					if axi_awaddr = "0000000000" then --status register
						slv_reg0 <= S_AXI_WDATA;
					else
						slv_reg0 <= slv_reg0;
					end if;
				end if;
			end if;
		end if;
	end process;

	-- Implement axi_arready generation
	-- axi_arready is asserted for one S_AXI_ACLK clock cycle when
	-- S_AXI_ARVALID is asserted. axi_awready is 
	-- de-asserted when reset (active low) is asserted. 
	-- The read address is also latched when S_AXI_ARVALID is 
	-- asserted. axi_araddr is reset to zero on reset assertion.

	process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_arready <= '0';
				axi_araddr  <= (others => '1');
			else
				if (axi_arready = '0' and S_AXI_ARVALID = '1') then
					-- indicates that the slave has acceped the valid read address
					axi_arready <= '1';
					-- Read Address latching 
					axi_araddr  <= S_AXI_ARADDR;
				else
					axi_arready <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Implement axi_arvalid generation
	-- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	-- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	-- data are available on the axi_rdata bus at this instance. The 
	-- assertion of axi_rvalid marks the validity of read data on the 
	-- bus. axi_rvalid is deasserted on reset (active low). axi_rdata 
	-- is cleared to zero on reset (active low).  

	process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_rvalid <= '0';
			else
				if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
					-- Valid read data is available at the read data bus
					axi_rvalid <= '1';
				elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
					-- Read data is accepted by the master
					axi_rvalid <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Implement memory mapped register select and read logic generation
	-- Slave register read enable is asserted when valid address is available
	-- and the slave is ready to accept the read address.
	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid);

	process(slv_reg0, axi_araddr, xcorr01, xcorr02)
		variable loc_addr : std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
	begin
		-- Address decoding for reading registers
		loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
		if axi_araddr = "0000000000" then
			reg_data_out <= slv_reg0;
		else
            case loc_addr(7 downto 6) is
                when "10" =>
                  reg_data_out <= std_logic_vector(resize(xcorr01(to_integer(signed(loc_addr(5 downto 0)))), C_S_AXI_DATA_WIDTH));
              when "11" =>
                  reg_data_out <= std_logic_vector(resize(xcorr02(to_integer(signed(loc_addr(5 downto 0)))), C_S_AXI_DATA_WIDTH));
              when others =>
                    reg_data_out <= (others => '0');
            end case;
		end if;
	end process;

	-- Output register or memory read data
	process(S_AXI_ACLK) is
	begin
		if (rising_edge(S_AXI_ACLK)) then
			if (S_AXI_ARESETN = '0') then
				axi_rdata <= (others => '0');
			else
				if (slv_reg_rden = '1') then
					-- When there is a valid read address (S_AXI_ARVALID) with 
					-- acceptance of read address by the slave (axi_arready), 
					-- output the read dada 
					-- Read address mux
					axi_rdata <= reg_data_out; -- register read data
				end if;
			end if;
		end if;
	end process;

-- Add user logic here

-- User logic ends

end arch_imp;
