--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:04:13 12/27/2012
-- Design Name:   
-- Module Name:   /home/jenn/quad/quad_fpga/ahrs_tb.vhd
-- Project Name:  quad_fpga
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ahrs
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
--USE ieee.numeric_std.ALL;
 
ENTITY ahrs_tb IS
END ahrs_tb;
 
ARCHITECTURE behavior OF ahrs_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ahrs
    PORT(
         gx : IN  std_logic_vector(15 downto 0);
         gy : IN  std_logic_vector(15 downto 0);
         gz : IN  std_logic_vector(15 downto 0);
         ax : IN  std_logic_vector(15 downto 0);
         ay : IN  std_logic_vector(15 downto 0);
         az : IN  std_logic_vector(15 downto 0);
         mx : IN  std_logic_vector(15 downto 0);
         my : IN  std_logic_vector(15 downto 0);
         mz : IN  std_logic_vector(15 downto 0);
         gx_scale : IN  std_logic_vector(31 downto 0);
         gy_scale : IN  std_logic_vector(31 downto 0);
         gz_scale : IN  std_logic_vector(31 downto 0);
         ax_scale : IN  std_logic_vector(31 downto 0);
         ay_scale : IN  std_logic_vector(31 downto 0);
         az_scale : IN  std_logic_vector(31 downto 0);
         mx_scale : IN  std_logic_vector(31 downto 0);
         my_scale : IN  std_logic_vector(31 downto 0);
         mz_scale : IN  std_logic_vector(31 downto 0);
         gx_off : IN  std_logic_vector(31 downto 0);
         gy_off : IN  std_logic_vector(31 downto 0);
         gz_off : IN  std_logic_vector(31 downto 0);
         ax_off : IN  std_logic_vector(31 downto 0);
         ay_off : IN  std_logic_vector(31 downto 0);
         az_off : IN  std_logic_vector(31 downto 0);
         mx_off : IN  std_logic_vector(31 downto 0);
         my_off : IN  std_logic_vector(31 downto 0);
         mz_off : IN  std_logic_vector(31 downto 0);
         dt_in : IN  std_logic_vector(31 downto 0);
         Ki_in : IN  std_logic_vector(31 downto 0);
         Kp_in : IN  std_logic_vector(31 downto 0);
         clk : IN  std_logic;
         start : IN  std_logic;
         q0 : OUT  std_logic_vector(31 downto 0);
         q1 : OUT  std_logic_vector(31 downto 0);
         q2 : OUT  std_logic_vector(31 downto 0);
         q3 : OUT  std_logic_vector(31 downto 0);
         ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal gx : std_logic_vector(15 downto 0) := (others => '0');
   signal gy : std_logic_vector(15 downto 0) := (others => '0');
   signal gz : std_logic_vector(15 downto 0) := (others => '0');
   signal ax : std_logic_vector(15 downto 0) := (others => '0');
   signal ay : std_logic_vector(15 downto 0) := (others => '0');
   signal az : std_logic_vector(15 downto 0) := (others => '0');
   signal mx : std_logic_vector(15 downto 0) := (others => '0');
   signal my : std_logic_vector(15 downto 0) := (others => '0');
   signal mz : std_logic_vector(15 downto 0) := (others => '0');
   signal gx_scale : std_logic_vector(31 downto 0) := (others => '0');
   signal gy_scale : std_logic_vector(31 downto 0) := (others => '0');
   signal gz_scale : std_logic_vector(31 downto 0) := (others => '0');
   signal ax_scale : std_logic_vector(31 downto 0) := (others => '0');
   signal ay_scale : std_logic_vector(31 downto 0) := (others => '0');
   signal az_scale : std_logic_vector(31 downto 0) := (others => '0');
   signal mx_scale : std_logic_vector(31 downto 0) := (others => '0');
   signal my_scale : std_logic_vector(31 downto 0) := (others => '0');
   signal mz_scale : std_logic_vector(31 downto 0) := (others => '0');
   signal gx_off : std_logic_vector(31 downto 0) := (others => '0');
   signal gy_off : std_logic_vector(31 downto 0) := (others => '0');
   signal gz_off : std_logic_vector(31 downto 0) := (others => '0');
   signal ax_off : std_logic_vector(31 downto 0) := (others => '0');
   signal ay_off : std_logic_vector(31 downto 0) := (others => '0');
   signal az_off : std_logic_vector(31 downto 0) := (others => '0');
   signal mx_off : std_logic_vector(31 downto 0) := (others => '0');
   signal my_off : std_logic_vector(31 downto 0) := (others => '0');
   signal mz_off : std_logic_vector(31 downto 0) := (others => '0');
   signal dt_in : std_logic_vector(31 downto 0) := (others => '0');
   signal Ki_in : std_logic_vector(31 downto 0) := (others => '0');
   signal Kp_in : std_logic_vector(31 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal start : std_logic := '0';

 	--Outputs
   signal q0 : std_logic_vector(31 downto 0);
   signal q1 : std_logic_vector(31 downto 0);
   signal q2 : std_logic_vector(31 downto 0);
   signal q3 : std_logic_vector(31 downto 0);
   signal ready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ahrs PORT MAP (
          gx => gx,
          gy => gy,
          gz => gz,
          ax => ax,
          ay => ay,
          az => az,
          mx => mx,
          my => my,
          mz => mz,
          gx_scale => gx_scale,
          gy_scale => gy_scale,
          gz_scale => gz_scale,
          ax_scale => ax_scale,
          ay_scale => ay_scale,
          az_scale => az_scale,
          mx_scale => mx_scale,
          my_scale => my_scale,
          mz_scale => mz_scale,
          gx_off => gx_off,
          gy_off => gy_off,
          gz_off => gz_off,
          ax_off => ax_off,
          ay_off => ay_off,
          az_off => az_off,
          mx_off => mx_off,
          my_off => my_off,
          mz_off => mz_off,
          dt_in => dt_in,
          Ki_in => Ki_in,
          Kp_in => Kp_in,
          clk => clk,
          start => start,
          q0 => q0,
          q1 => q1,
          q2 => q2,
          q3 => q3,
          ready => ready
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
      wait for clk_period*10;

		
		mx <= X"0005";
		my <= X"0005";
		mz <= X"0005";
		mx_scale <= X"40000000";
		my_scale <= X"40000000";
		mz_scale <= X"40000000";
		mx_off <= X"3F800000";
		my_off <= X"3F800000";
		mz_off <= X"3F800000";
		
		
		start <= '1';
		wait for clk_period;
		start <= '0';
      -- insert stimulus here 

      wait;
   end process;

END;
