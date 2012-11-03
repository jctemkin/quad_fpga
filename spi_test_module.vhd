----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:01:33 10/31/2012 
-- Design Name: 
-- Module Name:    spi_test_module - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;


entity spi_test_module is
	port( 
		sclk : in  STD_LOGIC;
		ssel : in  STD_LOGIC;
		miso : out  STD_LOGIC;
		mosi : in  STD_LOGIC;
		clk : in  STD_LOGIC;
		rst: in STD_LOGIC
	);
end spi_test_module;

architecture Behavioral of spi_test_module is

	--spi slave signals
	signal spi_di_req: std_logic;
	signal spi_di_req_strobe: std_logic := '0';
	signal spi_di: std_logic_vector(7 downto 0);
	signal spi_do: std_logic_vector(7 downto 0);
	signal spi_wr_en: std_logic := '0';
	signal spi_do_valid: std_logic;
	signal spi_miso: std_logic;

	--Holds address byte from SPI.
	signal addr_hold: std_logic_vector(7 downto 0) := (others => '0');
	signal holding_addr: std_logic := '0';

	--fifo signals
	signal fifo_out: std_logic_vector(15 downto 0);
	signal fifo_full: std_logic;
	signal fifo_empty: std_logic;
	signal fifo_almost_full: std_logic;
	signal fifo_almost_empty: std_logic;
	signal fifo_read_en: std_logic := '0';
	signal fifo_wr_en: std_logic := '0';
	signal fifo_rst: std_logic;

	--register file signals
	signal reg_wr_en: std_logic;
	
	
	--Signals for generating do_valid.
	signal do_valid: std_logic := '0';
	signal sclk_del_reg: std_logic := '1';
	signal sclk_count: integer range 0 to 15;
	
	--FIFO component declaration
	component fifo is
		port(
			clk : IN STD_LOGIC;
			rst : IN STD_LOGIC;
			din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			wr_en : IN STD_LOGIC;
			rd_en : IN STD_LOGIC;
			dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			full : OUT STD_LOGIC;
			almost_full : OUT STD_LOGIC;
			empty : OUT STD_LOGIC;
			almost_empty : OUT STD_LOGIC
		);
	end component;
	
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
		
		miso <= spi_miso AND NOT ssel;	--Prevents blips on MISO after SSEL has been raised.


	regs: entity work.reg_file(Behavioral)
		generic map (addr_len => 8, data_len => 8)
		port map(
			rd_addr => '0' & addr_hold(6 downto 0),
			rd_en=> do_valid,
			wr_addr => fifo_out(15 downto 8),
			wr_data => fifo_out(7 downto 0),
			wr_en=> reg_wr_en,
			clk => clk,
			rd_data => spi_di
		);
		
	afifo: component fifo
		port map(
			clk => clk,
			rst => fifo_rst,
			din => '0' & addr_hold(6 downto 0) & spi_do,
			wr_en => fifo_wr_en,
			rd_en => fifo_read_en,
			dout => fifo_out,
			full => fifo_full,
			almost_full => fifo_almost_full,
			empty => fifo_empty,
			almost_empty => fifo_almost_empty
		);

	process(clk)
	begin
		if rising_edge(clk) then
		
			--Generate our own do_valid signal, since the one given takes an extra 3 clock cycles.
			sclk_del_reg <= sclk;
			if ssel = '1' then	--reset counter if ssel goes high
				sclk_count <= 0;
				do_valid <= '0';
				fifo_wr_en <= '0';
				holding_addr <= '0';
				
			elsif sclk_del_reg = '0' and sclk = '1' then	--detect a rising edge on sclk
				sclk_count <= sclk_count + 1;
				
				if sclk_count = 7 and do_valid = '0' then
					do_valid <= '1';
					addr_hold <= spi_do;
					holding_addr <= '1';
				
				elsif sclk_count = 15 and do_valid = '0' then
					do_valid <= '1';
					if addr_hold(7) = '0' then
						fifo_wr_en <= '1';
					end if;
				
				else
					do_valid <= '0';
					
				end if;
			else
			do_valid <= '0';
			fifo_wr_en <= '0';
			end if;				
			
		
			--Handle writes to SPI module.
			spi_wr_en <= do_valid;
		
		
			--Handle writing to the FIFO.
	
--			--When a byte has been received,
--			if do_valid = '1' then
--				--If an address byte has already been received,
--				if holding_addr = '1' then
--					--and if the address byte contains a write flag,
--					if addr_hold(7) = '0' then
--						fifo_wr_en <= '1';	--Write to the FIFO.
--					end if;
--
--					holding_addr <= '0';	--Clear the holding_addr flag, regardless.
--					addr_hold <= (others => '0'); --Clear the register.
--					
--				--If no address byte has been received yet, save the address byte.
--				else
--					addr_hold <= spi_do;
--					holding_addr <= '1';
--				end if;
--				
--			--If we're still waiting for a byte, be sure to clear the fifo write enable.
--			else
--				fifo_wr_en <= '0';
--			end if;
			
						
						
			
			--Handle moving data from FIFO to register file.
			--If the fifo won't be empty after this cycle's read, then read.
			if fifo_empty = '0'  and not (fifo_read_en = '1' and fifo_almost_empty = '1') then	
				fifo_read_en <= '1';
			else
				fifo_read_en <= '0';
			end if;
			
			--Clock data from fifo into register file once the data is ready (one cycle after fifo_read_en).
			reg_wr_en <= fifo_read_en;
			

		end if;
	end process;



end Behavioral;

