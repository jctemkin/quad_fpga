library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity spi_controller is
	generic (
		addr_len : positive := 8;
		data_len : positive := 16
	);
	port ( 
		clk: in  STD_LOGIC;

		sclk: in  STD_LOGIC;
		ssel: in  STD_LOGIC;
		miso: out  STD_LOGIC;
		mosi: in  STD_LOGIC;
		
		write_en: out STD_LOGIC;
		write_addr: out STD_LOGIC_VECTOR((addr_len - 1) downto 0);
		write_data: out std_logic_vector((data_len - 1) downto 0); 
		read_regs: in std_logic_vector((((2 ** (addr_len - 1)) * data_len) - 1) downto 0)
		
	);
end spi_controller;

architecture Behavioral of spi_controller is

	--SPI slave signals
	signal spi_di_req: std_logic;
	signal spi_di: std_logic_vector(7 downto 0);
	signal spi_do: std_logic_vector(7 downto 0);
	signal spi_wr_en: std_logic := '0';
	signal spi_do_valid: std_logic;
	signal spi_miso: std_logic;

		
	--Various control signals and registers
	signal addr_hold: std_logic_vector(7 downto 0) := (others => '0');
	signal spi_do_valid_delay: std_logic := '0';
	signal do_valid: std_logic := '0';
	signal do_valid_delay: std_logic := '0';
	signal addr_rxd: std_logic := '0';
	signal lsb_rxd: std_logic := '0';
	signal lsb_hold: std_logic_vector(7 downto 0) := (others => '0');
	signal current_read_reg: std_logic_vector((data_len - 1) downto 0);
	
begin

	spi_slave: entity work.spi_slave(rtl)
		generic map (N => 8, CPOL => '1', CPHA => '1', PREFETCH => 1)
		port map(
			clk_i => clk,
			spi_ssel_i => ssel,
			spi_sck_i => sclk,
			spi_mosi_i => mosi,
			spi_miso_o => spi_miso,
			di_req_o => spi_di_req,
			di_i => spi_di,	
			wren_i => spi_wr_en,
			do_valid_o => spi_do_valid,
			do_o => spi_do
		);


	--Hold miso at high-Z when not transmitting.
	miso <= spi_miso when ssel = '0' else 'Z';


	hold_bytes: process(clk)
	begin
		if rising_edge(clk) then

			--For generating do_valid strobe.
			spi_do_valid_delay <= spi_do_valid;
			
			--For generating some useful read/write signals.
			do_valid_delay <= do_valid;
			
			--Keep track of the address byte.
			if ssel = '1' then
				addr_rxd <= '0';
				addr_hold <= (others => '0');
				lsb_rxd <= '0';
			
			elsif do_valid = '1' then
				addr_rxd <= '1';
				
				--The first byte is an address byte, so hold on to it.
				if addr_rxd = '0' then
					addr_hold <= spi_do;
					
				--Proceeding bytes will be LSB, then MSB.
				else
					lsb_rxd <= NOT lsb_rxd;
					
					--Increment address after every full int.
					if lsb_rxd = '0' then
						lsb_hold <= spi_do;
					else
						addr_hold <= std_logic_vector(unsigned(addr_hold) + 1);
					end if;
					
				end if;
			end if;
		end if;
		
		--Generate do_valid strobe.
		do_valid <= spi_do_valid AND NOT spi_do_valid_delay;
	
	end process;
	
	
	--Clock read data into SPI module when in write mode.
	spi_wr_en <= do_valid_delay AND addr_hold(7);
	
	--An intermediate sanity variable, so I don't have to write this monstrosity more than once.
	current_read_reg <= read_regs((((to_integer(unsigned(addr_hold(6 downto 0))) + 1) * data_len) - 1) downto (to_integer(unsigned(addr_hold(6 downto 0))) * data_len));
	--current_read_reg <= read_regs((((unsigned(addr_hold(6 downto 0)) + 1) * data_len)  1) downto (unsigned(addr_hold(6 downto 0)) * data_len));
	
	--Feed asynchronous read data to SPI module.
	spi_di <= current_read_reg(7 downto 0) when lsb_rxd = '0' else current_read_reg(15 downto 8);
	
	
	--Signals to write to register file.
	write_en <= do_valid AND NOT addr_hold(7) AND addr_rxd AND lsb_rxd;
	write_addr <= '0' & addr_hold(6 downto 0);
	write_data <= spi_do & lsb_hold;
	
	

end Behavioral;
