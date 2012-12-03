
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


-- ==== Calculated values ====
-- 80: Pitch
-- 81: Roll
-- 82: Heading



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

	-- Register file and data path signals
	constant addr_len: positive := 8;
	constant data_len: positive := 16;
	constant writers: positive := 1;

	type wr_addr_type is array (0 to (writers - 1)) of std_logic_vector((addr_len - 1) downto 0);
	type wr_data_type is array (0 to (writers - 1)) of std_logic_vector((data_len - 1) downto 0);
	signal wr_addr: wr_addr_type := (others => (others => '0'));
	signal wr_data: wr_data_type := (others => (others => '0'));
	signal wr_en: std_logic_vector((writers - 1) downto 0) := (others => '0');
	signal read_regs: std_logic_vector((((2 ** addr_len) * data_len) - 1) downto 0);

	
	-- Convenience signals
	signal wr_addr_concat: std_logic_vector(((writers * addr_len) - 1) downto 0);
	signal wr_data_concat: std_logic_vector(((writers * data_len) - 1) downto 0);


	-- Clock-related signals
	signal clk: std_logic;
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
			CLK_OUT1 => clk,
			RESET  => clk_reset,
			LOCKED => clk_locked
		);
		
	clk_reset <= '0';


	pcm_controller_i: entity work.pcm_controller(Behavioral)
		port map(
			clk_100mhz => clk,
			pw_in => read_regs(63 downto 0),
			pcm_out => pcm_out
		);

	
	spi_controller_i: entity work.spi_controller(Behavioral)
		generic map(
			addr_len => addr_len,
			data_len => data_len
		)
		port map(
			clk => clk,
			sclk => sclk,
			ssel => ssel,
			miso => miso,
			mosi => mosi,
			write_en => wr_en(0),
			write_addr => wr_addr(0),
			write_data => wr_data(0), 
			read_regs => read_regs(2047 downto 0)
		);
		
	-- Concatenate write signals so they can be easily passed into register file.
	array_concat: process(wr_addr, wr_data)
	begin
		for i in 0 to (writers - 1) loop
			wr_addr_concat((((i + 1) * addr_len) - 1) downto (i * addr_len)) <= wr_addr(i);
			wr_data_concat((((i + 1) * data_len) - 1) downto (i * data_len)) <= wr_data(i);
		end loop;
	end process;
		
	reg_file_i: entity work.reg_file(Behavioral)
		generic map(
			addr_len => addr_len,
			data_len => data_len,
			writers => writers
		)
		port map(
			reg_read => read_regs,
			write_data => wr_data_concat,
			write_addr => wr_addr_concat,
			write_en => wr_en,
			clk  => clk
		);
		

		

end Behavioral;

