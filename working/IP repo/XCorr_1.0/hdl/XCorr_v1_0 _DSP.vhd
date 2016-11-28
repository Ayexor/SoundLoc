library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.xcorr_pkg.all;

entity corr_DSP is
	generic(
	D_WIDTH : integer range 1 to 18 := 16; -- Internal mic data width
	SUBTRACT : boolean := false
);
port (  mic0 : in signed(D_WIDTH-1 downto 0);
        mic1 : in signed(D_WIDTH-1 downto 0);
		mic2 : in signed(D_WIDTH-1 downto 0);
        corr01 : in signed(R_WIDTH-1 downto 0);
		corr02 : in signed(R_WIDTH-1 downto 0);
		val01 : out signed(R_WIDTH-1 downto 0);
		val02 : out signed(R_WIDTH-1 downto 0)
     );
end corr_DSP;

architecture Behavioral of corr_DSP is	
begin
process(mic0, mic1, mic2, corr01, corr02)
begin
	if 2*D_WIDTH-1>R_WIDTH then
		if SUBTRACT then
			val01 <= corr01 - resize(mic0*mic1, R_WIDTH);
			val02 <= corr02 - resize(mic0*mic2, R_WIDTH);
		else
			val01 <= corr01 + resize(mic0*mic1,R_WIDTH);
			val02 <= corr02 + resize(mic0*mic2,R_WIDTH);
		end if;
	else
		if SUBTRACT then
			val01 <= corr01 - mic0*mic1;
			val02 <= corr02 - mic0*mic2;
		else
			val01 <= corr01 + mic0*mic1;
			val02 <= corr02 + mic0*mic2;
		end if;	
	end if;
end process;

end Behavioral;