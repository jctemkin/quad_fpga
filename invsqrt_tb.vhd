LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY invsqrt_tb IS
END invsqrt_tb;
 
ARCHITECTURE behavior OF invsqrt_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT invsqrt
    PORT(
         x : IN  std_logic_vector(31 downto 0);
         clk : IN  std_logic;
         start : IN  std_logic;
         data_ready : OUT  std_logic;
         result : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal x : std_logic_vector(31 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal start : std_logic := '0';

 	--Outputs
   signal data_ready : std_logic;
   signal result : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: invsqrt PORT MAP (
          x => x,
          clk => clk,
          start => start,
          data_ready => data_ready,
          result => result
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
		start <= '0';
      wait for clk_period*10;

		x <= X"3F800000";	--1
		start <= '1';
		wait for clk_period;
		start <= '0';
		wait for clk_period * 30;
		--Result should be 1
		
		x <= X"40000000"; --2
		start <= '1';
		wait for clk_period;
		start <= '0';
		wait for clk_period * 30;
		--Result should be 0.7071067812 or so
		
		
		x <= X"43800000"; --256
		start <= '1';
		wait for clk_period;
		start <= '0';
		wait for clk_period * 30;
		--Result should be 0.625
		
		
		x <= X"40A00000"; --5
		start <= '1';
		wait for clk_period;
		start <= '0';
		wait for clk_period * 30;
		--Result should be 0.4472135955 or so
		
		
		
		
		
		
      wait;
   end process;

END;
