----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.11.2016 16:19:19
-- Design Name: 
-- Module Name: dummy_data - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dummy_data is
    Port ( clk : in STD_LOGIC;
    	   ce : in STD_LOGIC;
    	   new_val : out STD_LOGIC;
           rst_n : in STD_LOGIC;
           mic0 : out STD_LOGIC_VECTOR (15 downto 0);
           mic1 : out STD_LOGIC_VECTOR (15 downto 0);
           mic2 : out STD_LOGIC_VECTOR (15 downto 0));
end dummy_data;

architecture Behavioral of dummy_data is
type T_VAL_LUT is array (0 to 14) of integer;
	constant values : T_VAL_LUT := (0, 1, 2, 3, 4, 3, 2, 1, 0, -1, -2, -3, -4, -3, -2, -1);
	
	signal cnt0, cnt1, cnt2 : integer range 0 to 14;
begin

	process (clk, rst_n) is
	begin
		if rst_n = '0' then
			cnt0 <= 0;
			cnt1 <= -3;
			cnt2 <= 3;
		elsif rising_edge(clk) then
			new_val <= ce;
			if ce = '1' then
				if cnt0 = 14 then cnt0 <= 0; 	else cnt0 <= cnt0 + 1; end if;
				if cnt1 = 14 then cnt1 <= 0; 	else cnt1 <= cnt1 + 1; end if;
				if cnt2 = 14 then cnt2 <= 0; 	else cnt2 <= cnt2 + 1; end if;
				mic0 <= std_logic_vector(to_signed(values(cnt0), 16));
				mic1 <= std_logic_vector(to_signed(values(cnt1), 16));
				mic2 <= std_logic_vector(to_signed(values(cnt2), 16));
			end if;
		end if;
	end process;


end Behavioral;
