--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:17:27 11/04/2012
-- Design Name:   
-- Module Name:   /home/jenn/quad/quad_fpga/mem_spi_test.vhd
-- Project Name:  quad_fpga
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: mem_spi
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY mem_spi_test IS
END mem_spi_test;
 
ARCHITECTURE behavior OF mem_spi_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT mem_spi
    PORT(
         clk : IN  std_logic;
         sclk : IN  std_logic;
         ssel : IN  std_logic;
         miso : OUT  std_logic;
         mosi : IN  std_logic;
         wr_en : IN  std_logic;
         wr_addr : IN  std_logic_vector(6 downto 0);
			wr_data: in std_logic_vector(7 downto 0);
         rd_en : IN  std_logic;
         rd_addr : IN  std_logic_vector(6 downto 0);
         rd_data : OUT  std_logic_vector(7 downto 0);
         rd_data_ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal sclk : std_logic := '1';
   signal ssel : std_logic := '1';
   signal mosi : std_logic := '1';
   signal wr_en : std_logic := '0';
   signal wr_addr : std_logic_vector(6 downto 0) := (others => '0');
   signal rd_en : std_logic := '0';
   signal rd_addr : std_logic_vector(6 downto 0) := (others => '0');
	signal wr_data: std_logic_Vector(7 downto 0) := (others => '0');

 	--Outputs
   signal miso : std_logic;
   signal rd_data : std_logic_vector(7 downto 0);
   signal rd_data_ready : std_logic;
   
	
	-- Clock period definitions
   constant sclk_period : time := 1 us;
   constant clk_period : time := 10 ns;
	
	
	--Other signals!
	signal test_output: std_logic_vector(15 downto 0) := (others => '0');
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: mem_spi PORT MAP (
          clk => clk,
          sclk => sclk,
          ssel => ssel,
          miso => miso,
          mosi => mosi,
          wr_en => wr_en,
          wr_addr => wr_addr,
			 wr_data => wr_data,
          rd_en => rd_en,
          rd_addr => rd_addr,
          rd_data => rd_data,
          rd_data_ready => rd_data_ready
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
	
		wait for 100 ns;
		
		--Stream write test
		test_output <= X"0000";
		ssel <= '0'; wait for sclk_period/4;
		for i in 7 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		
		for j in 0 to 50 loop
			test_output <= std_logic_vector(to_unsigned(j,16));
			for i in 7 downto 0 loop
				sclk <= '0';
				mosi <= test_output(i);
				wait for sclk_period/2;
				sclk <= '1';
				wait for sclk_period/2;		
			end loop;
		end loop;
		wait for sclk_period/4; ssel <= '1';	
		wait for 500 ns;
		
		
		
		--Stream read test
		test_output <= X"0083";
		ssel <= '0'; wait for sclk_period/4;
		for i in 7 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		
		for j in 0 to 50 loop
			test_output <= X"0000";
			for i in 7 downto 0 loop
				sclk <= '0';
				mosi <= test_output(i);
				wait for sclk_period/2;
				sclk <= '1';
				wait for sclk_period/2;		
			end loop;
		end loop;
		wait for sclk_period/4; ssel <= '1';	
		wait for 500 ns;

      wait;
   end process;
	
	
	--Simulate outside read/write requests
	process
	begin
	
	wait for 79875 ns;
	wr_en <= '1';
	wr_addr <= "0000111";
	wr_data <= X"AA";
	wait for clk_period;
	wr_en <= '0';
	
	wait for clk_period;
	wr_en <= '1';
	wr_addr <= "0000010";
	wr_data <= X"BB";
	wait for clk_period;
	wait for 1 ps;
	wr_en <= '0';
	
	
	
	wait;
	end process;

END;
