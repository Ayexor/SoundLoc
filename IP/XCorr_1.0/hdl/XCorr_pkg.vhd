library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package XCorr_pkg is
		constant 		R_WIDTH : integer := 32; -- Internal corr data width
		
		type T_CORR_RAM is array (integer range <>) of signed(R_WIDTH - 1 downto 0);
		
		
end package XCorr_pkg;

package body XCorr_pkg is
	
end package body XCorr_pkg;
