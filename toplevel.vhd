
-- Register map!

-- ==== Received values ====
-- 00 - 03: PCM width regs (range 0 to 800)
-- 04 - 06: Accelerometer X, Y, Z
-- 07 - 09: Gyro X, Y, Z
-- 0A - 0C: Magnetometer X, Y, Z
-- 0D: Target pitch
-- 0E: Target roll
-- 0F: Target heading
-- 10: Throttle
-- 11 - 1F: Reserved

-- ==== Calculated values ====
-- 20: Pitch
-- 21: Roll
-- 22: Heading



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
	signal wr_addr: std_logic_vector(7 downto 0) := X"00"; --only bottom 7 bits are used; 8 bits used here for convenience of notation
	signal wr_data: std_logic_vector(15 downto 0) := X"0000";
	signal rd_en: std_logic := '0';
	signal rd_addr: std_logic_vector(7 downto 0) := X"00";
	signal rd_data: std_logic_vector(15 downto 0) := X"0000";
	signal rd_data_ready: std_logic := '0';
	
	signal fastclk: std_logic;
	signal clk_reset: std_logic;
	signal clk_locked: std_logic;
	
	
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
	

end Behavioral;

