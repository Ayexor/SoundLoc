library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity block_ram is
	generic(
		D_IS_DUAL : boolean := false;
		D_WIDTH : integer range 1 to 32     := 16; -- Internal width of data
		A_WIDTH : integer range 4 to 16 := 10 -- Internal width of addr
	);
	port(Clk  : in  std_logic;
		 aa   : in  unsigned(A_WIDTH - 1 downto 0);
		 ab   : in  unsigned(A_WIDTH - 1 downto 0):= (others  => '0');
		 wae  : in  std_logic;
		 wbe  : in  std_logic                    := '0';
		 da_i : in  signed(D_WIDTH - 1 downto 0);
		 da_o : out signed(D_WIDTH - 1 downto 0);
		 db_i : in  signed(D_WIDTH - 1 downto 0) := (others => '0');
		 db_o : out signed(D_WIDTH - 1 downto 0) := (others => '0')
	);
end block_ram;

architecture Behavioral of block_ram is
	type ram_t is array (0 to (2**A_WIDTH) - 1) of signed(D_WIDTH - 1 downto 0);
	shared variable ram : ram_t := (others => (others => '0'));
	attribute ram_style : string;
	attribute ram_style of ram : variable is "block";

begin

	--process for read and write operation.
	PROCESS(Clk)
	BEGIN
		if (rising_edge(Clk)) then
			if (wae = '1') then
				ram(to_integer(aa)) := da_i;
			end if;
			da_o <= ram(to_integer(aa));
		end if;
	END PROCESS;

	PROCESS(Clk)
	BEGIN
		if (rising_edge(Clk)) then
			if D_IS_DUAL then
				if (wbe = '1') then
					ram(to_integer(ab)) := db_i;
				end if;
				db_o <= ram(to_integer(ab));
			end if;
		end if;
	END PROCESS;
end Behavioral;