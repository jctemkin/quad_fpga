library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_module is
	port ( 
		sck : in  STD_LOGIC;
		cs : in  STD_LOGIC;
		mosi : in STD_LOGIC;
		miso : out STD_LOGIC;
		
		rst: in STD_LOGIC;
		clk: in STD_LOGIC;
		
		read_addr: out STD_LOGIC_VECTOR (5 downto 0);
		read_data: in STD_LOGIC_VECTOR (7 downto 0);
		write_addr: out STD_LOGIC_VECTOR (5 downto 0);
		write_data: out STD_LOGIC_VECTOR (7 downto 0);
		write_enable: out STD_LOGIC);

end spi_module;

architecture Behavioral of spi_module is

	-- Control signals
	signal save_wr_addr: std_logic;
	signal rx_shift: std_logic;
	signal tx_shift: std_logic;
	signal tx_load: std_logic;
	
	-- Registers
	signal wr_addr_reg: std_logic_vector(5 downto 0);
	signal rx_shift_reg: std_logic_vector(7 downto 0);
	signal tx_shift_reg: std_logic_vector(7 downto 0);

	signal bits_received: integer range 0 to 31;
	signal write_enable_reg: std_logic;
	
	
begin
		
	process(cs, sck, clk)
	begin
		if cs then
			if rising_edge(sck) then
				
				bits_received <= bits_received + 1;
				
				if rx_shift then
					rx_shift_reg <= rx_shift_reg(6 downto 0) & mosi; 
				end if;
				
			end if;
			
			if falling_edge(sck) then
			
				if save_wr_addr then
					wr_addr_reg <= rx_shift_reg;
				end if;
				
				
					
			
			end if;
			

			
		else
			bits_received <= 0;
		end if;
		
	end process;
	
	tx_load <= (bits_received = 8);
	tx_shift <= NOT cs AND (bits_received > 7);
	rx_shift <= NOT cs AND (bits_received < 8);
	save_wr_addr <= (bits_receieved = 8) AND NOT rx_shift_reg(7);
	
	miso <= 	'Z' when NOT (tx_shift OR tx_load) else
				tx_shift(7);
				
				
	
end Behavioral;

