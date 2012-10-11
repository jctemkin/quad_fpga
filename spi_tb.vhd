
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;


ENTITY spi_tb IS
END spi_tb;
 
ARCHITECTURE behavior OF spi_tb IS 
 
    COMPONENT spi_module
    PORT(
         sck : IN  std_logic;
         cs : IN  std_logic;
         mosi : IN  std_logic;
         miso : OUT  std_logic;
         rst : IN  std_logic;
         clk : IN  std_logic;
         read_addr : OUT  std_logic_vector(5 downto 0);
         read_data : IN  std_logic_vector(7 downto 0);
         write_addr : OUT  std_logic_vector(5 downto 0);
         write_data : OUT  std_logic_vector(7 downto 0);
         write_enable : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal sck : std_logic := '0';
   signal cs : std_logic := '0';
   signal mosi : std_logic := '0';
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal read_data : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal miso : std_logic;
   signal read_addr : std_logic_vector(5 downto 0);
   signal write_addr : std_logic_vector(5 downto 0);
   signal write_data : std_logic_vector(7 downto 0);
   signal write_enable : std_logic;

   -- Clock period definitions
   constant clk_period : time := 84 ns;
	constant sckp : time := 125 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: spi_module PORT MAP (
          sck => sck,
          cs => cs,
          mosi => mosi,
          miso => miso,
          rst => rst,
          clk => clk,
          read_addr => read_addr,
          read_data => read_data,
          write_addr => write_addr,
          write_data => write_data,
          write_enable => write_enable
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
		-- hold reset state for 100 ns.
      wait for 100 ns;	
		
		sck <= '1';
		cs <= '1';
		mosi <= '1';
		read_data <= 0x"AC";
		
      wait for 2*sckp;
		cs <= '0'; wait for 50 ns;
		
		sck <= '0';
		mosi <= '1'; wait for sckp; sck <= '1'; wait for sckp; sck <= '0';
		mosi <= '1'; wait for sckp; sck <= '1'; wait for sckp; sck <= '0';
		mosi <= '0'; wait for sckp; sck <= '1'; wait for sckp; sck <= '0';
		mosi <= '1'; wait for sckp; sck <= '1'; wait for sckp; sck <= '0';
		mosi <= '0'; wait for sckp; sck <= '1'; wait for sckp; sck <= '0';
		mosi <= '0'; wait for sckp; sck <= '1'; wait for sckp; sck <= '0';
		mosi <= '1'; wait for sckp; sck <= '1'; wait for sckp; sck <= '0';
		mosi <= '1'; wait for sckp; sck <= '1'; wait for sckp; sck <= '0';
		
		wait for sckp; sck <= '1'; wait for sckp; sck <= '0';
		wait for sckp; sck <= '1'; wait for sckp; sck <= '0';
		wait for sckp; sck <= '1'; wait for sckp; sck <= '0';
		wait for sckp; sck <= '1'; wait for sckp; sck <= '0';
		wait for sckp; sck <= '1'; wait for sckp; sck <= '0';
		wait for sckp; sck <= '1'; wait for sckp; sck <= '0';
		wait for sckp; sck <= '1'; wait for sckp; sck <= '0';
		wait for sckp; sck <= '1'; wait for sckp;
		
		wait for 50 ns; cs <= '1';
      wait;
		
   end process;

END;
