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
		wr_data: in std_logic_vector(7 downto 0);
		rd_en : in  STD_LOGIC;
		rd_addr : in  STD_LOGIC_VECTOR (6 downto 0);
		rd_data : out  STD_LOGIC_VECTOR (7 downto 0);
		rd_data_ready: out std_logic
		);
end mem_spi;

architecture Behavioral of mem_spi is

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
	signal reg_rd_addr: std_logic_vector(6 downto 0);
	signal reg_rd_data: std_logic_vector(7 downto 0);
	signal reg_rd_en: std_logic;
	signal reg_wr_addr: std_logic_vector(6 downto 0);
	signal reg_wr_data: std_logic_vector(7 downto 0);
	
	
	--Signals for generating do_valid.
	signal do_valid: std_logic := '0';
	signal do_valid_delay: std_logic := '0';
	signal sclk_del_reg: std_logic := '1';
	signal sclk_count: std_logic_vector(10 downto 0) := (others => '0');
	
	
	--wut
	signal rd_data_out: std_logic_Vector(7 downto 0) := (others => '0');
	signal rd_data_almost_ready: std_logic := '0';
	signal rd_en_hold: std_logic := '0';
	signal rd_data_ready_reg: std_logic := '0';
	signal fifo_read_en_hold: std_logic := '0';
	
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
		
		miso <= spi_miso when ssel = '0' else
					'Z';


	regs: entity work.reg_file(Behavioral)
		generic map (addr_len => 7, data_len => 8)
		port map(
			rd_addr => reg_rd_addr,	
			rd_en=> reg_rd_en,
			wr_addr => reg_wr_addr,
			wr_data => reg_wr_data,
			wr_en=> reg_wr_en,
			clk => clk,
			rd_data => reg_rd_data	
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
		------------------------------------------------------------------------------------------
			--Handle address byte and writing from SPI to FIFO
		------------------------------------------------------------------------------------------	
			--Generate our own do_valid signal, since the one given takes an extra 3 clock cycles.
			sclk_del_reg <= sclk;	--Used to detect rising edge of SCLK.
			do_valid_delay <= do_valid;
			if ssel = '1' then		--If the transmission ends, reset values.
				sclk_count <= (others => '0');
				do_valid <= '0';
				fifo_wr_en <= '0';
				addr_hold <= (others => '0');
				
			elsif sclk_del_reg = '0' and sclk = '1' then	--Count each rising edge of SCLK.
				sclk_count <= std_logic_vector(unsigned(sclk_count) + 1);
				
				if sclk_count = "00000000111" then	--On the eighth tick of SCK, signal do_valid and hold the address byte.
					do_valid <= '1';
					addr_hold <= spi_do;
				
				elsif sclk_count(2 downto 0) = "111" then	--After subsequent bytes are received, signal do_valid,
					do_valid <= '1';
					if addr_hold(7) = '0' then	--and write to FIFO if in write mode.
						fifo_wr_en <= '1';
					else
						addr_hold <= std_logic_vector(unsigned(addr_hold) + 1);	--Also increment address pointer now if in read mode.
					end if;
					
				end if;
				
			elsif do_valid_delay = '1' and unsigned(sclk_count) > 8 then	--Increment address pointer later if in write mode.
				if addr_hold(7) = '0' then
					addr_hold <= std_logic_vector(unsigned(addr_hold) + 1);	
				end if;
				
				--do_valid <= '0';		--Shouldn't be necessary.
				--fifo_wr_en <= '0';
			
			else
				do_valid <= '0';
				fifo_wr_en <= '0';
			end if;
			
		
			------------------------------------------------------------------------------------------
			--Handle writes from registers to SPI
			------------------------------------------------------------------------------------------
			spi_wr_en <= do_valid AND addr_hold(7);
			
			------------------------------------------------------------------------------------------
			--Handle writes from FIFO to registers
			------------------------------------------------------------------------------------------
			--If the fifo won't be empty after this cycle's read, then read.
			if fifo_empty = '0'  and not (fifo_read_en = '1' and fifo_almost_empty = '1') and not wr_en = '1' then	
				fifo_read_en <= '1';
			else
				fifo_read_en <= '0';
			end if;
			
			if fifo_read_en = '1' or (fifo_read_en_hold = '1' and wr_en = '1') then
				fifo_read_en_hold <= '1';
			else
				fifo_read_en_hold <= '0';
			end if;
			
			
			
			------------------------------------------------------------------------------------------
			--Handle regfile read requests from SPI and externally.
			------------------------------------------------------------------------------------------
			--Hold
			if rd_en = '1' then
				rd_en_hold <= rd_en AND do_valid;
				
			elsif rd_en_hold = '1' and do_valid = '0' then
				rd_en_hold <= '0';
				
			end if;
			
			rd_data_almost_ready <= (rd_en or rd_en_hold) and not do_valid;
			
			if rd_data_almost_ready = '1' then
				rd_data_out <= reg_rd_data;
				rd_data_ready_reg <= '1';
			else
				rd_data_ready_reg <= '0';
			end if;
				
			
			


		end if;
	end process;
	
	reg_rd_addr <=	addr_hold(6 downto 0) when do_valid = '1' else
						rd_addr;

	reg_rd_en <= (do_valid AND addr_hold(7)) OR rd_en OR rd_en_hold;

	spi_di <= reg_rd_data;
	
	rd_data <= rd_data_out;
	
	rd_data_ready <= rd_data_ready_reg;
	
	--Clock data from fifo into register file once the data is ready (one cycle after fifo_read_en).
	reg_wr_en <= fifo_read_en_hold OR wr_en;
	
	reg_wr_addr <= wr_addr when wr_en = '1' else
						fifo_out(14 downto 8);
	reg_wr_data <= wr_data when wr_en = '1' else
						fifo_out(7 downto 0);
	
	
	

end Behavioral;

