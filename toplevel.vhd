library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity toplevel is
	Port ( 
		clk_12mhz : in  STD_LOGIC;
		ssel : in  STD_LOGIC;
		miso : out  STD_LOGIC;
		mosi : in  STD_LOGIC;
		sclk : in  STD_LOGIC;
		pcm_out : out  STD_LOGIC_VECTOR (3 downto 0)
	);
end toplevel;

architecture Behavioral of toplevel is

	signal wr_en: std_logic := '0';
	signal wr_addr: std_logic_vector(7 downto 0) := X"00"; --only bottom 7 bits are used; 8 bits used for convenience of notation
	signal wr_data: std_logic_vector(15 downto 0) := X"0000";
	signal rd_en: std_logic := '0';
	signal rd_addr: std_logic_vector(7 downto 0) := X"00";
	signal rd_data: std_logic_vector(15 downto 0) := X"0000";
	signal rd_data_ready: std_logic := '0';
	
	signal fastclk: std_logic;
	signal clk_reset: std_logic;
	signal clk_locked: std_logic;
	
	type pcm_array_type is array (0 to 3) of std_logic_vector(9 downto 0);
	signal pcm_array: pcm_array_type := (others => (others => '0'));
	
	type state_type is (idle, read0, read1, read2, read3);
	signal state: state_type := idle;
	signal next_state: state_type := idle;
	signal last_state: state_type := idle;
	--signal idle_counter: natural range 0 to 1048575 := 0;
	signal idle_counter: std_logic_vector(17 downto 0) := (others => '0');
	signal clk_1mhz_cnt: natural range 0 to 63 := 0;
	signal clk_1mhz: std_logic := '0';


	component clk_100mhz
		port (
			CLK_IN1           : in     std_logic;
			CLK_OUT1          : out    std_logic;
			RESET             : in     std_logic;
			LOCKED            : out    std_logic
		);
	end component;



begin

	clk_100mhz_i: clk_100mhz
		port map(
			CLK_IN1 => clk_12mhz,
			CLK_OUT1 => fastclk,
			RESET  => clk_reset,
			LOCKED => clk_locked
		);
		
	clk_reset <= '0';

	mem: entity work.mem_spi(Behavioral) 
		port map(
			clk => fastclk,
			sclk => sclk,
			ssel => ssel,
			miso => miso,
			mosi => mosi,
			wr_en => wr_en,
			wr_addr => wr_addr(6 downto 0),
			wr_data => wr_data,
			rd_en => rd_en,
			rd_addr => rd_addr(6 downto 0),
			rd_data => rd_data,
			rd_data_ready=> rd_data_ready
		);

	pcms: for i in 0 to 3 generate
	begin
		pcm: entity work.pcm_gen(Behavioral)
			port map(
				pulse_width => pcm_array(i),
				clk_1mhz => clk_1mhz,
				pcm_out => pcm_out(i)
			);
	end generate pcms;


	clk_1mhz_proc: process(fastclk)
	begin
		if rising_edge(fastclk) then
			if clk_1mhz_cnt = 49 then
				clk_1mhz_cnt <= 0;
				clk_1mhz <= NOT clk_1mhz;
			else
				clk_1mhz_cnt <= clk_1mhz_cnt + 1;
			end if;
		end if;
	end process;
			


	fsm_sync: process (fastclk)
	begin
		if rising_edge(fastclk) then

			
			case (state) is
				when idle =>
					idle_counter <= std_logic_vector(unsigned(idle_counter) + 1);
			
				when read0 =>
					if last_state = idle then
						rd_en <= '1';
					else
						rd_en <= '0';
					end if;
					if rd_data_ready = '1' then
						pcm_array(0) <= rd_data(9 downto 0);
					end if;
				
				when read1 =>
					if last_state = read0 then
						rd_en <= '1';
					else
						rd_en <= '0';
					end if;
					if rd_data_ready = '1' then
						pcm_array(1) <= rd_data(9 downto 0);
					end if;
				
				when read2 =>
					if last_state = read1 then
						rd_en <= '1';
					else
						rd_en <= '0';
					end if;
					if rd_data_ready = '1' then
						pcm_array(2) <= rd_data(9 downto 0);
					end if;
				
				when read3 =>
					if last_state = read2 then
						rd_en <= '1';
					else
						rd_en <= '0';
					end if;
					if rd_data_ready = '1' then
						pcm_array(3) <= rd_data(9 downto 0);
					end if;
					
			end case;
			
			
			last_state <= state;
			state <= next_state;
			
			
			
		end if;
	end process;
	
	
	
	fsm_async: process (state, idle_counter, rd_data_ready)
	begin
		case (state) is
			
			when idle =>
				if unsigned(idle_counter) = "111111111111111111" then
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
					next_state <= idle;
				else
					next_state <= read3;
				end if;
				rd_addr <= X"03";
				
		end case;
	end process;
	

end Behavioral;

