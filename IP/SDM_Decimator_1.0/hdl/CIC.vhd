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
	generic(D_WIDTH : integer range 8 to 32 := 16);
	Port(clk       : in  STD_LOGIC;
		 rst       : in  STD_LOGIC;
		 bs_ena    : in  STD_LOGIC;
		 decim_ena : in  STD_LOGIC;
		 order    : in  STD_LOGIC_VECTOR(1 DOWNTO 0);
		 iir_ena : in  STD_LOGIC;
		 iir_sr       : in unsigned(3 downto 0);
		 bs        : in  STD_LOGIC;
		 val       : out signed(D_WIDTH - 1 downto 0));
end CIC;

architecture Behavioral of CIC is
	signal dif1, dif2, dif3, dif_pre1, dif_pre2, dif_pre3 : signed(D_WIDTH - 1 downto 0);
	signal acc1, acc2, acc3                       : signed(D_WIDTH - 1 downto 0);
	signal cic_o, cic_o_pre, val_i, val_pre_i               : signed(D_WIDTH - 1 downto 0);
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
				if order /= "00" then -- order = 1, 2 or 3
					acc1 <= acc1 + bs_in;
				else
					acc1 <= (others => '0');
				end if;
				if order(1) = '1' then -- order = 2 or 3
					acc2 <= acc2 + acc1;
				else
					acc2 <= (others => '0');
				end if;
				if order = "11" then -- order = 3
					acc3 <= acc3 + acc2;
				else
					acc3 <= (others => '0');
				end if;  
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
				
				if order(1) = '1' then -- order = 2 or 3
					dif2    <= dif1 - dif_pre1;
				else
					dif2 <= (others => '0');
				end if;
				if order = "11" then -- order = 3
					dif3    <= dif2 - dif_pre2;
				else
					dif3 <= (others => '0');
				end if;  
											
				case order is
					when "01" =>
						dif1    <= acc1;
					when "10" =>
						dif1    <= acc2;
					when "11" =>
						dif1    <= acc3;
					when others =>
						dif1    <= (others => '0');
				end case;
			end if;
		end if;
	end process;
	
	cic_o_select : process (clk, rst) is
	begin
		if rst = '1' then
			cic_o_pre <= (others => '0');
			cic_o <= (others => '0');
			val_i <= (others => '0');
		elsif rising_edge(clk) then
			if decim_ena = '1' then
				cic_o_pre <= cic_o;
				case order is
					when "01" =>
						cic_o <= dif1 - dif_pre1;
					when "10" =>
						cic_o <= dif2 - dif_pre2;						
					when "11" =>
						cic_o <= dif3 - dif_pre3;
					when others =>
						cic_o <= (others => '0');
				end case;
				
				-- IIR DC-block (1-z**-1)/(1-(1-2**-8)z**-1)
				if iir_ena = '1' then
					val_i <= cic_o - cic_o_pre + (val_i - shift_right(val_i, to_integer(iir_sr)));
				else
					val_i <= cic_o;
				end if;
			end if;
		end if;
	end process;
	val   <= val_i;
end Behavioral;
