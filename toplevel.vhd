library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity toplevel is
    Port ( clk : in  STD_LOGIC;
           ssel : in  STD_LOGIC;
           miso : in  STD_LOGIC;
           mosi : in  STD_LOGIC;
           sclk : in  STD_LOGIC;
           pcm_out : out  STD_LOGIC_VECTOR (3 downto 0));
end toplevel;

architecture Behavioral of toplevel is

	signal wr_en: std_logic := '0';
	signal wr_addr: std_logic_vector(7 downto 0) := X"00"; --only bottom 7 bits are used; 8 bits used for convenience of notation
	signal wr_data: std_logic_vector(7 downto 0) := X"00";
	signal rd_en: std_logic := '0';
	signal rd_addr: std_logic_vector(7 downto 0) := X"00";
	signal rd_data: std_logic_vector(7 downto 0) := X"00";
	signal rd_data_ready: std_logic := '0';
	
	type pcm_array_type is array (0 to 3) of std_logic_vector(9 downto 0);
	signal pcm_array: pcm_array_type := (others => (others => '0'));
	
	type state_type is (idle, read0, read1, read2, read3);
	signal state: state_type := idle;
	signal next_state: state_type := idle;
	signal idle_counter: integer range 0 to 1048575 := 0;

begin

	mem: work.mem_spi(Behavioral) 
		port map(
			clk => clk,
			sclk => sclk,
			ssel => ssel,
			miso => miso,
			mosi => mosi,
			wr_en => wr_en,
			wr_addr => wr_addr(6 downto 0),
			wr_data=> wr_data,
			rd_en => rd_en,
			rd_addr => rd_addr,
			rd_data => rd_data,
			rd_data_ready=>  rd_data_ready
		);

	pcms: for i in 0 to 3 generate
	begin
		pcm: work.pcm_gen(Behavioral)
			port map(
				pulse_width => pcm_array(i),
				clk_1mhz => clk_1mhz,
				pcm_out => pcm_out(i)
			);
	end generate pcms;


--clk_1mhz generator


	process (clk)
	begin
		if rising_edge(clk) then
			
			if state = idle then
				idle_counter <= idle_counter + 1;
			end if;
			
			case next_state is
				when idle =>
					if state = read3 then
						pcm_array(3) <= rd_data & (others => '0');
					end if;
					rd_en <= '0';
				
				when read0 =>
					if state = idle then
						rd_en <= '1';
					else
						rd_en <= '0';
					end if;
					
				when read1 =>
					if state = read0 then
						rd_en <= '1';
						pcm_array(0) <= rd_data & (others => '0');
					else
						rd_en <= '0';
					end if;
					
				when read2 =>
					if state = read1 then
						rd_en <= '1';
						pcm_array(1) <= rd_data & (others => '0');
					else
						rd_en <= '0';
					end if;
					
				when read3 =>
					if state = read2 then
						rd_en <= '1';
						pcm_array(2) <= rd_data & (others => '0');
					else
						rd_en <= '0';
					end if;
					
			end case;
			
			state <= next_state;
		
			
		end if;
	end process;
	
	
	
	process (state, idle_counter)
	begin
		case (state) is
			
			when idle =>
				if idle_counter = 0 then
					next_state <= read0;
				else
					next_state <= idle;
				end if;
				rd_addr <= X"00";
				
			when read0 =>
				if rd_data_ready = '1' then
					next_state <= read1;
				else
					next_state <= read0;
				end if;
				rd_addr <= X"00";
				
			when read1 =>
				if rd_data_ready = '1' then
					next_state <= read2;
				else
					next_state <= read1;
				end if;
				rd_addr <= X"01";
				
			when read2 =>
				if rd_data_ready = '1' then
					next_state <= read3;
				else
					next_state <= read2;
				end if;
				rd_addr <= X"02";
			
			when read3 =>
				if rd_data_ready = '1' then
					next_state <= read3;
				else
					next_state <= read2;
				end if;
				rd_addr <= X"03";
				
		end case;
	end process;
	

end Behavioral;

