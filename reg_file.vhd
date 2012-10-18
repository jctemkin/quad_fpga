library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity reg_file is
    Port ( rd_addr : in  STD_LOGIC_VECTOR (7 downto 0);
           wr_addr : in  STD_LOGIC_VECTOR (7 downto 0);
           wr_data : in  STD_LOGIC_VECTOR (7 downto 0);
           rd_data : out  STD_LOGIC_VECTOR (7 downto 0);
           clk : in  STD_LOGIC;
           spi_rd_addr : in  STD_LOGIC_VECTOR (7 downto 0);
           spi_rd_data : out  STD_LOGIC_VECTOR (7 downto 0));
end reg_file;

architecture Behavioral of reg_file is



begin


end Behavioral;

