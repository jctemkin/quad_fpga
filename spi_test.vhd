LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY spi_test IS
END spi_test;
 
ARCHITECTURE behavior OF spi_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT spi_slave
    PORT(
         clk_i : IN  std_logic;
         spi_ssel_i : IN  std_logic;
         spi_sck_i : IN  std_logic;
         spi_mosi_i : IN  std_logic;
         spi_miso_o : OUT  std_logic;
         di_req_o : OUT  std_logic;
         di_i : IN  std_logic_vector(31 downto 0);
         wren_i : IN  std_logic;
         wr_ack_o : OUT  std_logic;
         do_valid_o : OUT  std_logic;
         do_o : OUT  std_logic_vector(31 downto 0);
         do_transfer_o : OUT  std_logic;
         wren_o : OUT  std_logic;
         rx_bit_next_o : OUT  std_logic;
         state_dbg_o : OUT  std_logic_vector(3 downto 0);
         sh_reg_dbg_o : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
	 
	 
	 component reg_file is
    Port ( rd_addr : in  STD_LOGIC_VECTOR (7 downto 0);
			  rd_en: in std_logic;
			  wr_addr : in  STD_LOGIC_VECTOR (7 downto 0);
           wr_data : in  STD_LOGIC_VECTOR (7 downto 0);
			  wr_en: in std_logic;
           clk : in  STD_LOGIC;
			  rd_data : out  STD_LOGIC_VECTOR (7 downto 0));
	end component;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal spi_ssel_i : std_logic := '0';
   signal spi_sck_i : std_logic := '0';
   signal spi_mosi_i : std_logic := '0';
   signal di_i : std_logic_vector(31 downto 0) := (others => '0');
   signal wren_i : std_logic := '0';

 	--Outputs
   signal spi_miso_o : std_logic;
   signal di_req_o : std_logic;
   signal wr_ack_o : std_logic;
   signal do_valid_o : std_logic;
   signal do_o : std_logic_vector(31 downto 0);
   signal do_transfer_o : std_logic;
   signal wren_o : std_logic;
   signal rx_bit_next_o : std_logic;
   signal state_dbg_o : std_logic_vector(3 downto 0);
   signal sh_reg_dbg_o : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_i_period : time := 10 ns;


	--regfile signals
	signal rf_rd_addr: std_logic_vector(7 downto 0);
	signal rf_wr_addr: std_logic_vector(7 downto 0);
	
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: spi_slave PORT MAP (
          clk_i => clk_i,
          spi_ssel_i => spi_ssel_i,
          spi_sck_i => spi_sck_i,
          spi_mosi_i => spi_mosi_i,
          spi_miso_o => spi_miso_o,
          di_req_o => di_req_o,
          di_i => di_i,
          wren_i => wren_i,
          wr_ack_o => wr_ack_o,
          do_valid_o => do_valid_o,
          do_o => do_o,
          do_transfer_o => do_transfer_o,
          wren_o => wren_o,
          rx_bit_next_o => rx_bit_next_o,
          state_dbg_o => state_dbg_o,
          sh_reg_dbg_o => sh_reg_dbg_o
        );

	regs: reg_file port map (
			 rd_addr => rf_rd_addr,
			 rd_en => di_req_o,
			 wr_addr => rf_wr_addr,
          wr_data => do_o,
			 wr_en => do_valid_o,
          clk => clk_i,
			 rd_data => di_i
			);


	--Read/write address reg control


   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_i_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
