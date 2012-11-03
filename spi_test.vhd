--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:57:36 10/31/2012
-- Design Name:   
-- Module Name:   /home/jenn/quad/quad_fpga/spi_test.vhd
-- Project Name:  quad_fpga
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: spi_test_module
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
 
USE ieee.numeric_std.ALL;
 
ENTITY spi_test IS
END spi_test;
 
ARCHITECTURE behavior OF spi_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT spi_test_module
    PORT(
         sclk : IN  std_logic;
         ssel : IN  std_logic;
         miso : OUT  std_logic;
         mosi : IN  std_logic;
         clk : IN  std_logic;
			rst: in std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal sclk : std_logic := '1';
   signal ssel : std_logic := '1';
   signal mosi : std_logic := '0';
   signal clk : std_logic := '0';
	signal rst : std_logic := '0';

 	--Outputs
   signal miso : std_logic;

   -- Clock period definitions
   constant sclk_period : time := 125 ns; --8MHz
   constant clk_period : time := 20 ns;
	
	
	--Other signals!
	signal test_output: std_logic_vector(15 downto 0) := (others => '0');
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: spi_test_module PORT MAP (
          sclk => sclk,
          ssel => ssel,
          miso => miso,
          mosi => mosi,
          clk => clk,
			 rst => rst
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
      rst <= '1';
		wait for 100 ns;
		rst <= '0';
      wait for sclk_period*4;
				
				
		for j in 0 to 255 loop
			test_output <= std_logic_vector(to_unsigned(j, 8)) & std_logic_vector(to_unsigned(j, 8));
			ssel <= '0'; wait for sclk_period/4;
			for i in 15 downto 0 loop
				sclk <= '0';
				mosi <= test_output(i);
				wait for sclk_period/2;
				sclk <= '1';
				wait for sclk_period/2;		
			end loop;
			wait for sclk_period/4; ssel <= '1';
			wait for 513 ns;
		end loop;
		
		--Transmit write request on address 01 with data AA.
		test_output <= X"01AA";
		ssel <= '0'; wait for sclk_period/4;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';

		wait for 3*sclk_period;	

		--Transmit a read request on address 01
		test_output <= X"81AA";
		ssel <= '0'; wait for sclk_period/4;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';
		
		
		
		wait for 6*sclk_period;	

		--Transmit a read request on address 01
		test_output <= X"81AA";
		ssel <= '0'; wait for sclk_period/4;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';

		wait for 6*sclk_period;	

		--Transmit a read request on address 01
		test_output <= X"81AA";
		ssel <= '0'; wait for sclk_period/4;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';
		
				wait for 6*sclk_period;	

		--Transmit a read request on address 01
		test_output <= X"81AA";
		ssel <= '0'; wait for sclk_period/4;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';
		
				wait for 6*sclk_period;	

		--Transmit a read request on address 01
		test_output <= X"81AA";
		ssel <= '0'; wait for sclk_period/4;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';
		
				wait for 6*sclk_period;	

		--Transmit a read request on address 01
		test_output <= X"81AA";
		ssel <= '0'; wait for sclk_period/4;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';
		
				wait for 6*sclk_period;	

		--Transmit a read request on address 01
		test_output <= X"81AA";
		ssel <= '0'; wait for sclk_period/4;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';
		
				wait for 6*sclk_period;	

		--Transmit a read request on address 01
		test_output <= X"81AA";
		ssel <= '0'; wait for sclk_period/4;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';
		
				wait for 6*sclk_period;	

		--Transmit a read request on address 01
		test_output <= X"81AA";
		ssel <= '0'; wait for sclk_period/4;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';
		
				wait for 6*sclk_period;	

		--Transmit a read request on address 01
		test_output <= X"81AA";
		ssel <= '0'; wait for sclk_period/4;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';
		
				wait for 6*sclk_period;	

		--Transmit a read request on address 01
		test_output <= X"81AA";
		ssel <= '0'; wait for sclk_period/4;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';
		
				wait for 6*sclk_period;	

		--Transmit a read request on address 01
		test_output <= X"81AA";
		ssel <= '0'; wait for sclk_period/4;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';
		
				wait for 6*sclk_period;	

		--Transmit a read request on address 01
		test_output <= X"81AA";
		ssel <= '0'; wait for sclk_period/4;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';
		
				wait for 6*sclk_period;	

		--Transmit a read request on address 01
		test_output <= X"81AA";
		ssel <= '0'; wait for sclk_period/4;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';
		
				wait for 6*sclk_period;	

		--Transmit a read request on address 01
		test_output <= X"81AA";
		ssel <= '0'; wait for sclk_period/4;
		for i in 15 downto 0 loop
			sclk <= '0';
			mosi <= test_output(i);
			wait for sclk_period/2;
			sclk <= '1';
			wait for sclk_period/2;		
		end loop;
		wait for sclk_period/4; ssel <= '1';

      wait;
   end process;

END;
