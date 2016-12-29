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
		 order     : in  STD_LOGIC_VECTOR(1 DOWNTO 0);
		 iir_ena   : in  STD_LOGIC;
		 iir_sr    : in  unsigned(3 downto 0);
		 bs        : in  STD_LOGIC;
		 val       : out signed(D_WIDTH - 1 downto 0));
end CIC;

architecture Behavioral of CIC is
	signal dif1, dif2, dif3        : signed(D_WIDTH - 1 downto 0);
	signal dif_in, dif_out         : signed(D_WIDTH - 1 downto 0);
	signal acc1, acc2, acc3        : signed(D_WIDTH - 1 downto 0);
	signal cic_o, cic_o_pre, val_i : signed(D_WIDTH - 1 downto 0);
	signal bs_in                   : signed(1 downto 0);

begin
	bs_in <= (not bs, '1');             -- '1' => +1 ("01"), '0' => -1 ("11")
	-- Integrator stage
	u_acc1 : entity work.acc_DSP
		generic map(
			D_WIDTH => D_WIDTH
		)
		port map(
			clk     => clk,
			rst     => rst,
			ce      => bs_ena,
			acc_in  => resize(bs_in, D_WIDTH),
			acc_out => acc1
		);

	u_acc2 : entity work.acc_DSP
		generic map(
			D_WIDTH => D_WIDTH
		)
		port map(
			clk     => clk,
			rst     => rst,
			ce      => bs_ena,
			acc_in  => acc1,
			acc_out => acc2
		);

	u_acc3 : entity work.acc_DSP
		generic map(
			D_WIDTH => D_WIDTH
		)
		port map(
			clk     => clk,
			rst     => rst,
			ce      => bs_ena,
			acc_in  => acc2,
			acc_out => acc3
		);

	-- Comb stage
	dif_in_sel : with order select dif_in <=
		acc1 when "01",
		acc2 when "10",
		acc3 when "11",
		to_signed(0, D_WIDTH) when others;

	u_dif1 : entity work.dif_DSP
		generic map(
			D_WIDTH => D_WIDTH
		)
		port map(
			clk     => clk,
			rst     => rst,
			ce      => decim_ena,
			dif_in  => dif_in,
			dif_out => dif1
		);

	u_dif2 : entity work.dif_DSP
		generic map(
			D_WIDTH => D_WIDTH
		)
		port map(
			clk     => clk,
			rst     => rst,
			ce      => decim_ena,
			dif_in  => dif1,
			dif_out => dif2
		);

	u_dif3 : entity work.dif_DSP
		generic map(
			D_WIDTH => D_WIDTH
		)
		port map(
			clk     => clk,
			rst     => rst,
			ce      => decim_ena,
			dif_in  => dif2,
			dif_out => dif3
		);

	dif_out_sel : with order select dif_out <=
		dif1 when "01",
		dif2 when "10",
		dif3 when "11",
		to_signed(0, D_WIDTH) when others;

	cic_o_select : cic_o <= dif_out;

	iir_p : process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				cic_o_pre <= (others => '0');
				val_i     <= (others => '0');
			else
				if decim_ena = '1' then
					cic_o_pre <= cic_o;

					-- IIR DC-block (1-z**-1)/(1-(1-2**-8)z**-1)
					if iir_ena = '1' then
						val_i <= cic_o - cic_o_pre + (val_i - shift_right(val_i, to_integer(iir_sr)));
					else
						val_i <= cic_o;
					end if;
				end if;
			end if;
		end if;
	end process;
	val <= val_i;

end Behavioral;
