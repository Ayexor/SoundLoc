library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity acc_DSP is
	generic (
		D_WIDTH : integer range 1 to 48 := 32 -- Internal width
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		ce : in std_logic;
		acc_in: in signed(D_WIDTH-1 downto 0);
		acc_out : out signed(D_WIDTH-1 downto 0)
	);
end acc_DSP;

architecture Behavioral of acc_DSP is
	signal acc : signed(D_WIDTH-1 downto 0);
begin
	
	acc_out <= acc;
	
	acc_p : process (clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				acc <= (others => '0');
			elsif ce = '1' then
				acc <= acc + acc_in;
			end if;
		end if;
	end process acc_p;

end Behavioral;
