----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.11.2016 22:05:20
-- Design Name: 
-- Module Name: clk_div - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_div is
generic (DIVIDE : integer range 1 to 1024);
    Port ( clk_in : in STD_LOGIC;
           clk_out : out STD_LOGIC;
           ce_out :  out STD_LOGIC;
           rst_n : in STD_LOGIC);
end clk_div;

architecture Behavioral of clk_div is
	signal cnt : integer range 1 to DIVIDE;
begin
	ce_out <= '1' when cnt = DIVIDE else '0';
	
	process (rst_n, clk_in) is
	begin
		if rst_n = '0' then
			cnt <= 0;
		elsif rising_edge(clk_in) then
			if cnt > DIVIDE / 2 then
				clk_out <= '1';
			else
				clk_out <= '0';
			end if;
			
			if cnt = DIVIDE then
				cnt <= 1;
			else
				cnt <= cnt + 1;
			end if;
		end if;
	end process;


end Behavioral;
