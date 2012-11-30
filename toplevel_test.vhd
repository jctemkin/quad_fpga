-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

  -- Component Declaration
	COMPONENT toplevel
		Port ( 
			clk_12mhz : in  STD_LOGIC;
			ssel : in  STD_LOGIC;
			miso : out  STD_LOGIC;
			mosi : in  STD_LOGIC;
			sclk : in  STD_LOGIC;
			pcm_out : out  STD_LOGIC_VECTOR (3 downto 0)
		);
	end COMPONENT;

	signal clk_12mhz: std_logic;
	signal clk_100mhz: std_logic;
	signal ssel: std_logic := '1';
	signal miso: std_logic;
	signal mosi: std_logic := '0';
	signal sclk: std_logic := '1';
	signal pcm_out: std_logic_VECTOR (3 downto 0) := "1111";
	signal test_output: std_logic_vector(23 downto 0) := (others => '0');
   
	constant fastclk_period: time := 10 ns;
	constant clk_period: time := 83.3333 ns;
	constant sclk_period: time := 125 ns;
     
BEGIN

  -- Component Instantiation
	uut: toplevel port map(
		clk_12mhz => clk_12mhz,
		ssel => ssel,
		miso => miso,
		mosi => mosi,
		sclk => sclk,
		pcm_out => pcm_out
	);


   clk_process :process
   begin
		clk_12mhz <= '0';
		wait for clk_period/2;
		clk_12mhz <= '1';
		wait for clk_period/2;
   end process;


  
	tb : PROCESS
	BEGIN
		wait for 1 us; -- wait until global set/reset completes

		test_output <= X"000080";
		wait for 1 ps;
		ssel <= '0'; wait for sclk_period/4;
		for i in 23 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		test_output <= X"00aaaa";
		wait for 1 ps;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		test_output <= X"001234";
		wait for 1 ps;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		test_output <= X"00abcd";
		wait for 1 ps;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';



		wait for 3 ms;
		
		test_output <= X"80aaaa";
		ssel <= '0'; wait for sclk_period/4;
		for i in 23 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		test_output <= X"00aaaa";
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		test_output <= X"00aaaa";
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		test_output <= X"00aaaa";
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';
		

		wait;
	END PROCESS tb;

  END;
