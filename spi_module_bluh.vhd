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

	signal bits_received: std_logic_vector(7 downto 0);
	signal write_data_reg: std_logic_vector(7 downto 0);
	signal wr_flag_sck: std_logic;
	signal wr_flag_clk: std_logic;
	signal wr_flag_clk_sync: std_logic;
begin
		
	-- SPI process
	process(cs, sck)
	begin
		if cs = '1' then
			if rising_edge(sck) then
				
				if rx_shift = '1' then
					rx_shift_reg <= rx_shift_reg(6 downto 0) & mosi; 
				end if;
				
				if (bits_received = x"0F") then
					wr_flag_sck <= NOT wr_flag_sck;
					write_data_reg <= rx_shift_reg;
				end if;
				
				bits_received <= std_logic_vector(unsigned(bits_received) + 1);
				
			end if;
			
			if falling_edge(sck) then
			
				if save_wr_addr = '1' then
					wr_addr_reg <= rx_shift_reg;
				end if;
				
				if tx_shift = '1' then
					tx_shift_reg <= tx_shift_reg(6 downto 0) & '0';
				end if;
			
				if tx_load = '1' then
					tx_shift_reg <= read_data;
				end if;
			
			end if;
			
		else
			bits_received <= (others => '0');
		end if;
		
	end process;

	
	-- Synchronize write enable signal to local clock
	process(clk)
	begin
		if rising_edge(clk) then
			wr_flag_clk_sync <= wr_flag_clk;
			wr_flag_clk <= wr_flag_sck;
		end if;
	end process;
	
	write_enable <= wr_flag_clk XOR wr_flag_clk_sync;
	
	
	-- Control signals
	--tx_load <= not cs AND (bits_received = x"08");
	--tx_load <= '0' when bits_received = x"00" else '1';
	
	
	tx_load <= (not cs) when (unsigned(bits_received) = 8);
	
	
	tx_shift <= NOT cs when (unsigned(bits_received) > 8) else '0';
	rx_shift <= NOT cs when (unsigned(bits_received) < 8) else '0';
	
	
	save_wr_addr <= NOT rx_shift_reg(7) when (unsigned(bits_received) = 8) else '0';
	
	miso <= 	'Z' when NOT (tx_shift = '1' OR tx_load = '1') else
				tx_shift_reg(7);
				
				
	
end Behavioral;

