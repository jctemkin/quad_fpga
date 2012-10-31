----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:27:02 10/13/2012 
-- Design Name: 
-- Module Name:    register_file - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_file is
    Port ( wr_addr : in  STD_LOGIC_VECTOR (7 downto 0);
           rd_addr : in  STD_LOGIC_VECTOR (7 downto 0);
           wr_data : in  STD_LOGIC_VECTOR (7 downto 0);
           rd_data : out  STD_LOGIC_VECTOR (7 downto 0));
end register_file;

architecture Behavioral of register_file is

begin


end Behavioral;

