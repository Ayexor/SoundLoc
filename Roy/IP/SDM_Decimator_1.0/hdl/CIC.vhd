----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.11.2016 20:33:11
-- Design Name: 
-- Module Name: CIC - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CIC is
	generic(D_WIDTH : integer range 1 to 32 := 16);
	Port(clk       : in  STD_LOGIC;
		 rst       : in  STD_LOGIC;
		 bs_ena    : in  STD_LOGIC;
		 decim_ena : in  STD_LOGIC;
		 inv_bs    : in  STD_LOGIC;
		 ena_3rd_order : IN STD_LOGIC;
		 bs        : in  STD_LOGIC;
		 val       : out signed(D_WIDTH - 1 downto 0));
end CIC;

architecture Behavioral of CIC is
	signal dif, dif2, dif3, dif_pre, dif_pre2, dif_pre3 : signed(D_WIDTH - 1 downto 0);
	signal val_i, acc, acc2, acc3                       : signed(D_WIDTH - 1 downto 0);

begin

	-- Integrator stage
	acc_p : process(clk, rst) is
	begin
		if rst = '1' then
			acc  <= (others => '0');
			acc2 <= (others => '0');
			acc3 <= (others => '0');
		elsif rising_edge(clk) then
			if bs_ena = '1' then
				if ena_3rd_order = '1' then
					acc2 <= acc2 + acc;
					acc3 <= acc3 + acc2;
				end if;

				if bs = inv_bs then
					acc <= acc - 1;
				else
					acc <= acc + 1;
				end if;
			end if;
		end if;
	end process;

	-- Comb stage
	com_p : process(clk, rst) is
	begin
		if rst = '1' then
			dif_pre  <= (others => '0');
			dif      <= (others => '0');
			dif_pre2 <= (others => '0');
			dif2     <= (others => '0');
			dif_pre3 <= (others => '0');
			dif3     <= (others => '0');
		elsif rising_edge(clk) then
			if decim_ena = '1' then
				dif_pre  <= dif;
				dif      <= acc;
				if ena_3rd_order = '1' then
					dif_pre2 <= dif2;
					dif2     <= dif - dif_pre;
					dif_pre3 <= dif3;
					dif3     <= dif2 - dif_pre2;
					dif      <= acc3;
				end if;
			end if;
		end if;
	end process;
	val_i <= dif3 - dif_pre3 when ena_3rd_order = '1' else dif-dif_pre;
	val   <= val_i;
end Behavioral;
