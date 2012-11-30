----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:13:58 11/04/2012 
-- Design Name: 
-- Module Name:    mem_spi - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mem_spi is
	port ( 
		clk : in  STD_LOGIC;

		sclk : in  STD_LOGIC;
		ssel : in  STD_LOGIC;
		miso : out  STD_LOGIC;
		mosi : in  STD_LOGIC;
		
		wr_en : in  STD_LOGIC;
		wr_addr : in  STD_LOGIC_VECTOR (6 downto 0);
		wr_data: in std_logic_vector(15 downto 0);
		rd_en : in  STD_LOGIC;
		rd_addr : in  STD_LOGIC_VECTOR (6 downto 0);
		rd_data : out  STD_LOGIC_VECTOR (15 downto 0);
		rd_data_ready: out std_logic
		);
end mem_spi;

architecture Behavioral of mem_spi is

	--SPI slave signals
	signal spi_di_req: std_logic;
	signal spi_di: std_logic_vector(7 downto 0);
	signal spi_do: std_logic_vector(7 downto 0);
	signal spi_wr_en: std_logic := '0';
	signal spi_do_valid: std_logic;
	signal spi_miso: std_logic;

	--fifo signals
	signal fifo_out: std_logic_vector(23 downto 0);
	signal fifo_full: std_logic;
	signal fifo_empty: std_logic;
	signal fifo_almost_full: std_logic;
	signal fifo_almost_empty: std_logic;
	signal fifo_read_en: std_logic := '0';
	signal fifo_wr_en: std_logic := '0';
	signal fifo_rst: std_logic := '0';

	--register file signals
	signal reg_wr_en: std_logic;
	signal reg_rd_addr: std_logic_vector(6 downto 0);
	signal reg_rd_data: std_logic_vector(15 downto 0);
	signal reg_rd_en: std_logic;
	signal reg_wr_addr: std_logic_vector(6 downto 0);
	signal reg_wr_data: std_logic_vector(15 downto 0);
	signal reg_rd_addr_a: std_logic_vector(6 downto 0);
	signal reg_rd_data_a: std_logic_vector(15 downto 0);
	
	
	--Various control signals and registers
	signal addr_hold: std_logic_vector(7 downto 0) := (others => '0');
	signal spi_do_valid_delay: std_logic := '0';
	signal do_valid: std_logic := '0';
	signal do_valid_delay: std_logic := '0';
	signal addr_rxd: std_logic := '0';
	signal rd_data_ready_reg: std_logic := '0';
	signal fifo_read_en_hold: std_logic := '0';
	signal lsb_rxd: std_logic := '0';
	signal lsb_hold: std_logic_vector(7 downto 0) := (others => '0');
	
	--FIFO component declaration
	component fifo is
		port(
			clk : IN STD_LOGIC;
			rst : IN STD_LOGIC;
			din : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
			wr_en : IN STD_LOGIC;
			rd_en : IN STD_LOGIC;
			dout : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
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


	regs: entity work.reg_file(Behavioral)
		generic map (addr_len => 7, data_len => 16)
		port map(
			rd_addr => reg_rd_addr,	
			rd_en=> reg_rd_en,
			wr_addr => reg_wr_addr,
			wr_data => reg_wr_data,
			wr_en=> reg_wr_en,
			clk => clk,
			rd_data => reg_rd_data,
			rd_addr_a => reg_rd_addr_a,
			rd_data_a => reg_rd_data_a
		);
		
	afifo: component fifo
		port map(
			clk => clk,
			rst => fifo_rst,
			din => '0' & addr_hold(6 downto 0) & spi_do & lsb_hold,
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
			
			
			--Hold fifo read enable if there's an external write request.
			if fifo_read_en = '1' or (fifo_read_en_hold = '1' and wr_en = '1') then
				fifo_read_en_hold <= '1';
			else
				fifo_read_en_hold <= '0';
			end if;


			--Signal when synchronous read data is ready.
			rd_data_ready_reg <= reg_rd_en;
			
			


		end if;
	end process;
	
	--Hold miso at high-Z when not transmitting.
	miso <= spi_miso when ssel = '0' else 'Z';
	
	
	
	--Generate do_valid strobe.
	do_valid <= spi_do_valid AND NOT spi_do_valid_delay;
	
	
	
	--Clock asynchronous read data into SPI module when in write mode.
	spi_wr_en <= do_valid_delay AND addr_hold(7);
	
	--Let asynchronous read address always be whatever address is currently held from SPI.
	reg_rd_addr_a <= addr_hold(6 downto 0);
	
	--Feed asynchronous read data to SPI module.
	spi_di <= reg_rd_data_a(7 downto 0) when lsb_rxd = '0' else reg_rd_data_a(15 downto 8);	--checkme
	
	
	
	--Wire the register IO to system IO
	reg_rd_addr <=	rd_addr;
	reg_rd_en <= rd_en;
	rd_data <= reg_rd_data;
	
	--Signal when synchronous read data is ready.
	rd_data_ready <= rd_data_ready_reg;
	
	
	
	--Write to fifo as soon as data is valid, if in write mode and the last byte wasn't the address.
	--fifo_wr_en <= do_valid AND NOT addr_hold(7) when (byte_count > 1) else '0';
	fifo_wr_en <= do_valid AND NOT addr_hold(7) AND addr_rxd AND lsb_rxd;
	
	--Read from fifo until it's empty, but not if there's an external write request.
	fifo_read_en <= not fifo_empty and not (fifo_read_en_hold and fifo_almost_empty) and not wr_en;
	
	
	
	--Clock data from fifo or external writes into registers.
	reg_wr_en <= fifo_read_en_hold OR wr_en;
	
	--Switch between fifo data and external data depending on external write enable.
	reg_wr_addr <= wr_addr when wr_en = '1' else
						fifo_out(22 downto 16);
	reg_wr_data <= wr_data when wr_en = '1' else
						fifo_out(15 downto 0);
	
	
	

end Behavioral;