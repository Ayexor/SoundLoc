library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dif_DSP is
	generic (
		D_WIDTH : integer range 1 to 48 := 32 -- Internal width
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		ce : in std_logic;
		dif_in: in signed(D_WIDTH-1 downto 0);
		dif_out : out signed(D_WIDTH-1 downto 0)
	);
end dif_DSP;

architecture Behavioral of dif_DSP is
	signal dif, dif_pre : signed(D_WIDTH-1 downto 0);
begin
	
	dif_logic : dif <= dif_in - dif_pre;
	
	dif_p : process (clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				dif_pre <= (others => '0');
				dif_out <= (others => '0');
			elsif ce = '1' then
				dif_pre <= dif_in;
				dif_out <= dif;
			end if;
		end if;
	end process dif_p;

end Behavioral;
