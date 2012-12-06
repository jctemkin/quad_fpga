LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY attitude_calc_tb IS
END attitude_calc_tb;
 
ARCHITECTURE behavior OF attitude_calc_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT attitude_calc
    PORT(
         clk : IN  std_logic;
         read_regs : IN  std_logic_vector(143 downto 0);
         write_en : OUT  std_logic;
         write_addr : OUT  std_logic_vector(7 downto 0);
         write_data : OUT  std_logic_vector(15 downto 0);
			reset: in std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk, reset : std_logic := '0';
   signal read_regs : std_logic_vector(143 downto 0);
	signal ax, ay, az, gx, gy, gz: integer range -32768 to 32767 := 0;

 	--Outputs
   signal write_en : std_logic;
   signal write_addr : std_logic_vector(7 downto 0);
   signal write_data : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN

	--Connect test signals to regs
	read_regs(15 downto 0) <= std_logic_vector(to_signed(ax, 16));
	read_regs(31 downto 16) <= std_logic_vector(to_signed(ay, 16));
	read_regs(47 downto 32) <= std_logic_vector(to_signed(az, 16));
	read_regs(63 downto 48) <= std_logic_vector(to_signed(gx, 16));
	read_regs(79 downto 64) <= std_logic_vector(to_signed(gy, 16));
	read_regs(95 downto 80) <= std_logic_vector(to_signed(gz, 16));
 
	-- Instantiate the Unit Under Test (UUT)
   uut: attitude_calc PORT MAP (
          clk => clk,
          read_regs => read_regs,
          write_en => write_en,
          write_addr => write_addr,
          write_data => write_data,
			 reset => reset
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
		reset <= '1';
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;
      -- insert stimulus here 
		ax <= 0;
		ay <= 10;
		az <= 10;
		gx <= 1;
		gy <= 0;
		gz <= 0;
		wait for clk_period;
		reset <= '0';
		wait for clk_period*200;
		
		reset <= '1';
		ax <= 10;
		ay <= -10;
		az <= 0;
		gx <= -32767;
		wait for clk_period;
		reset <= '0';
		wait for clk_period*200;
		
		
		reset <= '1';
		ax <= 0;
		ay <= 0;
		az <= 10;
		gx <= 32767;
		wait for clk_period;
		reset <= '0';
		wait for clk_period*200;
		
		
		reset <= '1';
		ax <= 10;
		ay <= -4;
		wait for clk_period;
		reset <= '0';
		wait for clk_period*200;

      wait;
   end process;

END;
