library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_module is
	port ( 
		sck : in  STD_LOGIC;
		cs : in  STD_LOGIC;           
		mosi : in STD_LOGIC;
		
		rst: in STD_LOGIC;
		clk: in STD_LOGIC;
		
		read_addr: out STD_LOGIC_VECTOR (6 downto 0);
		read_data: in STD_LOGIC_VECTOR (7 downto 0);
		write_addr: out STD_LOGIC_VECTOR (6 downto 0);
		write_data: out STD_LOGIC_VECTOR (7 downto 0);
		write_enable: out STD_LOGIC;
		

		data_ready : out STD_LOGIC;
		data_out : out STD_LOGIC_VECTOR (7 downto 0));
end spi_module;

architecture Behavioral of spi_module is


	
	
	
end Behavioral;

