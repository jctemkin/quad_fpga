library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity attitude_calc is
	port (
		clk : in  STD_LOGIC;
		read_regs : in  STD_LOGIC_VECTOR (143 downto 0);
		write_en : out  STD_LOGIC;
		write_addr : out  STD_LOGIC_VECTOR (7 downto 0);
		write_data : out  STD_LOGIC_VECTOR (15 downto 0)
	);
end attitude_calc;

architecture Behavioral of attitude_calc is

	signal ax_raw: std_logic_vector(15 downto 0);
	signal ay_raw: std_logic_vector(15 downto 0);
	signal az_raw: std_logic_vector(15 downto 0);
	
	signal ax_offset: std_logic_vector(15 downto 0);
	signal ay_offset: std_logic_vector(15 downto 0);
	signal az_offset: std_logic_vector(15 downto 0);
	
	signal axc: std_logic_vector(15 downto 0);
	signal ayc: std_logic_vector(15 downto 0);
	signal azc: std_logic_vector(15 downto 0);
	
	signal acc_pitch: std_logic_vector(15 downto 0);
	signal acc_roll: std_logic_vector(15 downto 0);
	
	
	
	signal gx_raw: std_logic_vector(15 downto 0);
	signal gy_raw: std_logic_vector(15 downto 0);
	signal gz_raw: std_logic_vector(15 downto 0);
	
	signal gx_offset: std_logic_vector(15 downto 0);
	signal gy_offset: std_logic_vector(15 downto 0);
	signal gz_offset: std_logic_vector(15 downto 0);
	
	signal gxc: std_logic_vector(15 downto 0);
	signal gyc: std_logic_vector(15 downto 0);
	signal gzc: std_logic_vector(15 downto 0);
	
	signal gx_scale: std_logic_vector(15 downto 0);
	signal gy_scale: std_logic_vector(15 downto 0);
	signal gz_scale: std_logic_vector(15 downto 0);
	
	signal gx: std_logic_vector(15 downto 0);
	signal gy: std_logic_vector(15 downto 0);
	signal gz: std_logic_vector(15 downto 0);
	
	
	signal Dt: std_logic_vector(15 downto 0);
	
	signal gxt: std_logic_vector(15 downto 0);
	signal gyt: std_logic_vector(15 downto 0);
	
	
	signal last_pitch: std_logic_vector(15 downto 0);
	signal last_roll: std_logic_vector(15 downto 0);
	
	signal gx_int: std_logic_vector(15 downto 0);
	signal gy_int: std_logic_vector(15 downto 0);
	
	
	signal Kd: std_logic_vector(15 downto 0);
	signal Kp: std_logic_vector(15 downto 0);
	
	signal p_pitch: std_logic_vector(15 downto 0);
	signal d_pitch: std_logic_vector(15 downto 0);
	
	signal p_roll: std_logic_vector(15 downto 0);
	signal d_roll: std_logic_vector(15 downto 0);
	
	signal pitch: std_logic_vector(15 downto 0);
	signal roll: std_logic_vector(15 downto 0);
	
	signal atan_x: std_logic_vector(15 downto 0);	--X and Y must have same binary point location.
	signal atan_y: std_logic_vector(15 downto 0);
	signal atan_out: std_logic_vector(15 downto 0);	--Output in fixed-point 2's complement radians, with 3 integer places.
	signal atan_rdy: std_logic;
	
	
	component arctan
		port (
			x_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			y_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			phase_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			rdy : OUT STD_LOGIC;
			clk : IN STD_LOGIC
		);
	end component;

begin
	
	
	--
	--Add stage: add constants to raw sensor values	
	gxc <= gx_raw + gx_offset;
	gyc <= gy_raw + gy_offset;
	
	--Multiply stage: scale gyro readings
	gx <= gxc * gx_scale;
	gy <= gyc * gy_scale;
	
	
	
	--Multiply stage: multiply gyro readings by time
	gxt <= gx_scale * Dt;
	gyt <= gy_scale * Dt;
	
	--Add stage: add gyro*time readings to last recorded attitude
	gx_int <= gxt + last_pitch;
	gy_int <= gxy + last_roll;
	
	--Multiply stage: Multiply by complimentary filter constants
	p_pitch <= gx_int * Kp;
	p_roll <= gy_int * Kp;
	
	
	--=========================--
	
	--Add stage: add constants to raw sensor values	
	axc <= ax_raw + ax_offset;
	ayc <= ay_raw + ay_offset;
	azc <= az_raw + az_offset;
	
	--Trig stage: take arctangent of offset sensor values
	atan_x1 <= axc;
	atan_y1 <= azc;
	atan_x2 <= ayc;
	atan_y2 <= azc;
	
	--Multiply stage: Multiply by complimentary filter constants
	d_pitch <= atan_out1 * Kd;
	d_roll <= atan_out2 * Kd;
	
	
	--=========================--
	
	--Add stage: Add P and D terms to obtain final pitch and roll
	pitch <= p_pitch + d_pitch;
	roll <= p_roll + d_roll;
	
	
	
	arctan_i1: arctan
		port map(
			x_in => atan_x1,
			y_in => atan_y1,
			phase_out => atan_out1,
			rdy => atan_rdy1,
			clk => clk
		);
		
	arctan_i2: arctan
		port map(
			x_in => atan_x2,
			y_in => atan_y2,
			phase_out => atan_out2,
			rdy => atan_rdy2,
			clk => clk
		);




end Behavioral;

