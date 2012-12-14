library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity ahrs is
	port ( 
		gx : in  STD_LOGIC_VECTOR (15 downto 0);
		gy : in  STD_LOGIC_VECTOR (15 downto 0);
		gz : in  STD_LOGIC_VECTOR (15 downto 0);
		ax : in  STD_LOGIC_VECTOR (15 downto 0);
		ay : in  STD_LOGIC_VECTOR (15 downto 0);
		az : in  STD_LOGIC_VECTOR (15 downto 0);
		mx : in  STD_LOGIC_VECTOR (15 downto 0);
		my : in  STD_LOGIC_VECTOR (15 downto 0);
		mz : in  STD_LOGIC_VECTOR (15 downto 0)
	);
end ahrs;

architecture Behavioral of ahrs is

begin


end Behavioral;

