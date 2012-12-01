library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity pcm_controller is
	Port ( 
		clk_100mhz : in std_logic;
		pw_req: out std_logic;
		pw_addr: out std_logic_vector(7 downto 0);
		pw_in: in std_logic_vector(9 downto 0);
		pw_ready: in std_logic;
		pcm_out: out std_logic_vector(3 downto 0)
	);
end pcm_controller;

architecture Behavioral of pcm_controller is

	type pcm_array_type is array (0 to 3) of std_logic_vector(9 downto 0);
	signal pcm_array: pcm_array_type := (others => (others => '0'));
	
	type state_type is (idle, read0, read1, read2, read3);
	signal state: state_type := idle;
	signal next_state: state_type := idle;
	signal last_state: state_type := idle;
	signal idle_counter: std_logic_vector(17 downto 0) := (others => '0');
	signal clk_1mhz_cnt: natural range 0 to 63 := 0;
	signal clk_1mhz: std_logic := '0';

begin

	pcms: for i in 0 to 3 generate
	begin
		pcm: entity work.pcm_gen(Behavioral)
			port map(
				pulse_width => pcm_array(i),
				clk_1mhz => clk_1mhz,
				pcm_out => pcm_out(i)
			);
	end generate pcms;


	clk_1mhz_proc: process(clk_100mhz)
	begin
		if rising_edge(clk_100mhz) then
			if clk_1mhz_cnt = 49 then
				clk_1mhz_cnt <= 0;
				clk_1mhz <= NOT clk_1mhz;
			else
				clk_1mhz_cnt <= clk_1mhz_cnt + 1;
			end if;
		end if;
	end process;
			

	fsm_sync: process (clk_100mhz)
	begin
		if rising_edge(clk_100mhz) then

			
			case (state) is
				when idle =>
					idle_counter <= std_logic_vector(unsigned(idle_counter) + 1);
			
				when read0 =>
					if last_state = idle then
						pw_req <= '1';
					else
						pw_req <= '0';
					end if;
					if pw_ready = '1' then
						pcm_array(0) <= rd_data(9 downto 0);
					end if;
				
				when read1 =>
					if last_state = read0 then
						pw_req <= '1';
					else
						pw_req <= '0';
					end if;
					if pw_ready = '1' then
						pcm_array(1) <= rd_data(9 downto 0);
					end if;
				
				when read2 =>
					if last_state = read1 then
						pw_req <= '1';
					else
						pw_req <= '0';
					end if;
					if pw_ready = '1' then
						pcm_array(2) <= rd_data(9 downto 0);
					end if;
				
				when read3 =>
					if last_state = read2 then
						pw_req <= '1';
					else
						pw_req <= '0';
					end if;
					if pw_ready = '1' then
						pcm_array(3) <= rd_data(9 downto 0);
					end if;
					
			end case;
			
			
			last_state <= state;
			state <= next_state;
			
			
			
		end if;
	end process;
	
	
	
	fsm_async: process (state, idle_counter, pw_ready)
	begin
		case (state) is
			
			when idle =>
				if unsigned(idle_counter) = "111111111111111111" then
					next_state <= read0;
				else
					next_state <= idle;
				end if;
				pw_addr <= X"00";
				
			when read0 =>
				if pw_ready = '1' then
					next_state <= read1;
				else
					next_state <= read0;
				end if;
				pw_addr <= X"00";
				
			when read1 =>
				if pw_ready = '1' then
					next_state <= read2;
				else
					next_state <= read1;
				end if;
				pw_addr <= X"01";
				
			when read2 =>
				if pw_ready = '1' then
					next_state <= read3;
				else
					next_state <= read2;
				end if;
				pw_addr <= X"02";
			
			when read3 =>
				if pw_ready = '1' then
					next_state <= idle;
				else
					next_state <= read3;
				end if;
				pw_addr <= X"03";
				
		end case;
	end process;


end Behavioral;

