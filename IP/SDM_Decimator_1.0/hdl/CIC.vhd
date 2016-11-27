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
		 order    : in  STD_LOGIC_VECTOR(1 DOWNTO 0);
		 bs        : in  STD_LOGIC;
		 val       : out signed(D_WIDTH - 1 downto 0));
end CIC;

architecture Behavioral of CIC is
	signal dif1, dif2, dif3, dif_pre1, dif_pre2, dif_pre3 : signed(D_WIDTH - 1 downto 0);
	signal val_i, acc1, acc2, acc3                       : signed(D_WIDTH - 1 downto 0);
	signal bs_in : signed(1 downto 0);

begin

	bs_in <= to_signed(1,2) when bs = '1' else to_signed(-1,2);
	-- Integrator stage
	acc_p : process(clk, rst) is
	begin
		if rst = '1' then
			acc1 <= (others => '0');
			acc2 <= (others => '0');
			acc3 <= (others => '0');
		elsif rising_edge(clk) then
			if bs_ena = '1' then
				case order is
					when "01" =>
						acc1 <= acc1 + bs_in;
						acc2 <= (others => '0');
						acc3 <= (others => '0');
					when "10" =>
						acc1 <= acc1 + bs_in;
						acc2 <= acc2 + acc1;
						acc3 <= (others => '0');
					when "11" =>
						acc1 <= acc1 + bs_in;
						acc2 <= acc2 + acc1;
						acc3 <= acc3 + acc2;
					when others =>
						acc1 <= (others => '0');
						acc2 <= (others => '0');
						acc3 <= (others => '0');
				end case;
			end if;
		end if;
	end process;

	-- Comb stage
	com_p : process(clk, rst) is
	begin
		if rst = '1' then
			dif_pre1 <= (others => '0');
			dif1     <= (others => '0');
			dif_pre2 <= (others => '0');
			dif2     <= (others => '0');
			dif_pre3 <= (others => '0');
			dif3     <= (others => '0');
		elsif rising_edge(clk) then
			if decim_ena = '1' then
				dif_pre1  <= dif1;
				dif_pre2  <= dif2;
				dif_pre3  <= dif3;
				
				case order is
					when "01" =>
						dif1    <= acc1;
						dif2	<= (others => '0');
						dif3	<= (others => '0');
					when "10" =>
						dif1    <= acc2;
						dif2    <= dif1 - dif_pre1;
						dif3	<= (others => '0');						
					when "11" =>
						dif1    <= acc3;
						dif2    <= dif1 - dif_pre1;
						dif3    <= dif2 - dif_pre2;
					when others =>
						dif1    <= (others => '0');
						dif2	<= (others => '0');
						dif3	<= (others => '0');
				end case;
			end if;
		end if;
	end process;
	
	val_select : process (dif1, dif_pre1, dif2, dif_pre2, dif3, dif_pre3, order) is
	begin
		case order is
			when "01" =>
				val_i <= dif1 - dif_pre1;
			when "10" =>
				val_i <= dif2 - dif_pre2;						
			when "11" =>
				val_i <= dif3 - dif_pre3;
			when others =>
				val_i <= (others => '0');
		end case;
	end process;
	val   <= val_i;
end Behavioral;
