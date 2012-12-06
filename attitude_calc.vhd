library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;


entity attitude_calc is
	port (
		clk : in  STD_LOGIC;
		read_regs : in  STD_LOGIC_VECTOR (143 downto 0);
		write_en : out  STD_LOGIC;
		write_addr : out  STD_LOGIC_VECTOR (7 downto 0);
		write_data : out  STD_LOGIC_VECTOR (15 downto 0);
		reset: in std_logic
	);
end attitude_calc;

architecture Behavioral of attitude_calc is
	constant ax_offset: std_logic_vector(17 downto 0) := "000000000000000000"; --std_logic_vector(to_signed(-430,18));
	constant ay_offset: std_logic_vector(17 downto 0) := "000000000000000000"; --std_logic_vector(to_signed(8, 18));
	constant az_offset: std_logic_vector(17 downto 0) := "000000000000000000"; --std_logic_vector(to_signed(85,18));
	
	constant gx_offset: std_logic_vector(17 downto 0) := "000000000000000000"; --std_logic_vector(to_signed(32,18));
	constant gy_offset: std_logic_vector(17 downto 0) := "000000000000000000"; --std_logic_vector(to_signed(28,18));
	constant gz_offset: std_logic_vector(17 downto 0) := "000000000000000000"; --std_logic_vector(to_signed(4,18));


	constant Dt: std_logic_vector(17 downto 0) := "010100111110001011"; -- * 2^-38 = 0.0000025; Time constant in s / 1000 (from millirads)
	constant Kp: std_logic_vector(17 downto 0) := "011111001110000011"; --0.9756098, 1 integer place; depends on Dt
	constant Kd: std_logic_vector(17 downto 0) := "000000110001111101"; --0.0243902, 1 integer place depends on Dt
	
	--Scale gyro readings from 65.5 lsb/(deg/s) to milliradians/s
	constant gyro_scale: std_logic_vector(17 downto 0) := "010001000011011011";-- * 2^-18 = 0.266462;
	
	constant pitch_corr: std_logic_vector(17 downto 0) := std_logic_vector(to_signed(0,18));
	constant roll_corr: std_logic_vector(17 downto 0) := std_logic_vector(to_signed(0,18));
	

	signal ax_raw, ay_raw, az_raw: std_logic_vector(17 downto 0);
	signal axc, ayc, azc: std_logic_vector(17 downto 0);
	signal axc_range, ayc_range, azc_range: std_logic_vector(17 downto 0);
	signal acc_pitch, acc_roll: std_logic_vector(17 downto 0);
		
	signal gx_raw, gy_raw, gz_raw: std_logic_vector(17 downto 0); --*2^0
	signal gx, gy, gz: std_logic_vector(47 downto 0); --todo: find exponent for this
	signal gx_int, gy_int: std_logic_vector(47 downto 0);
	
	
	signal last_pitch, last_roll: std_logic_vector(47 downto 0) := (others => '0');
	signal p_pitch, d_pitch: std_logic_vector(47 downto 0);	
	signal p_roll, d_roll: std_logic_vector(47 downto 0);
	signal pitch, roll: std_logic_vector(47 downto 0);
	signal m_pitch, m_roll: std_logic_vector(47 downto 0);

	signal atan_rdy1, atan_rdy2: std_logic;

	signal rst: std_logic;
	signal clk_en: std_logic := '1';
	signal atan_rst: std_logic;
	
	--latency is 22 cycles
	--latency of DSP slice is 3 cycles
	component arctan
		port (
			x_in : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
			y_in : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
			phase_out : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
			rdy : OUT STD_LOGIC;
			clk : IN STD_LOGIC;
			sclr : IN STD_LOGIC	--Active high
		);
	end component;

begin

	atan_rst <= reset;
	rst <= reset;
	--=======================--
	-- Load data from register file (and sign-extend)
	ax_raw <= std_logic_vector(resize(signed(read_regs(15 downto 0)), 18));
	ay_raw <= std_logic_vector(resize(signed(read_regs(31 downto 16)), 18));
	az_raw <= std_logic_vector(resize(signed(read_regs(47 downto 32)), 18));
	
	gx_raw <= std_logic_vector(resize(signed(read_regs(63 downto 48)), 18));
	gy_raw <= std_logic_vector(resize(signed(read_regs(79 downto 64)), 18));
	gz_raw <= std_logic_vector(resize(signed(read_regs(95 downto 80)), 18));
	
	
	--=======================--
	-- Gyro processing section
	-- Pitch:
	
	--Preadd-multiply: op=0x11; P=a*(b+d) = (gx_raw + gx_offset) * gx_scale
	dsp_gx1: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => gyro_scale,
			b => gx_raw,
			c => std_logic_vector(to_signed(0,48)),
			d => gx_offset,
			c_p_in => std_logic_vector(to_signed(0,48)),
			p => gx,	--millirads/s, with 18 fractional places
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"11"
		);
	
	--Multiply-postadd: op=0x1D; P=c+(a*b) = (gx * Dt) + last_pitch
	dsp_gx2: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => gx(32 downto 15), --millirads/s, with 3 fractional places
			b => Dt,
			c => last_pitch,
			d => std_logic_vector(to_signed(0,18)),
			c_p_in => std_logic_vector(to_signed(0,48)),
			p => gx_int,	--rads, with 38 fractional places
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"1D"	
		);
		
	--Multiply: op=0x01; C_P_out=a*b = gx_int * Kp (cascade to dsp_pitch)
	dsp_p_pitch: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => gx_int(33 downto 16), --rads, with 4 additional fractional places preceding
			b => Kp,
			c => std_logic_vector(to_signed(0,48)),
			d => std_logic_vector(to_signed(0,18)),
			c_p_in => std_logic_vector(to_signed(0,48)),
			c_p_out => p_pitch,	--rads, with 39 fractional places (point between bits 39 and 38)
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"01"
		);
		
		
	------------------------
	--Roll:

	--Preadd-multiply: op=0x11; P=a*(b+d) = (gy_raw + gy_offset) * gy_scale
	dsp_gy1: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => gyro_scale,
			b => gy_raw,
			c => std_logic_vector(to_signed(0,48)),
			d => gy_offset,
			c_p_in => std_logic_vector(to_signed(0,48)),
			p => gy,
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"11"
		);
	
	--Multiply-postadd: op=0x1D; P=c+(a*b) = (gy * Dt) + last_roll
	dsp_gy2: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => gy(32 downto 15),
			b => Dt,
			c => last_roll,
			d => std_logic_vector(to_signed(0,18)),
			c_p_in => std_logic_vector(to_signed(0,48)),
			p => gy_int,
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"1D"	
		);
	
	--Multiply: op=0x01; C_P_out=a*b = gy_int * Kp (cascade to dsp_roll)
	dsp_p_roll: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => gy_int(33 downto 16),
			b => Kp,
			c => std_logic_vector(to_signed(0,48)),
			d => std_logic_vector(to_signed(0,18)),
			c_p_in => std_logic_vector(to_signed(0,48)),
			c_p_out => p_roll,
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"01"
		);
	
	
	
	--=========================--
	-- Accelerometer section
	
	--Add stage: add constants to raw sensor values
	axc <= std_logic_vector(signed(ax_raw) + signed(ax_offset));
	ayc <= std_logic_vector(signed(ay_raw) + signed(ay_offset));
	azc <= std_logic_vector(signed(az_raw) + signed(az_offset));
	
	--Shift accelerometer readings into range for arctan
	axc_range <= std_logic_vector(signed(shift_right(signed(axc),1)));
	ayc_range <= std_logic_vector(signed(shift_right(signed(ayc),1)));
	azc_range <= std_logic_vector(signed(shift_right(signed(azc),1)));
	
	--Trig stage: take arctangent of offset sensor values
	arctan_i1: arctan
		port map(
			x_in => azc_range,
			y_in => axc_range,
			phase_out => acc_pitch,
			rdy => atan_rdy1,
			clk => clk,
			sclr => atan_rst
		);
		
	arctan_i2: arctan
		port map(
			x_in => azc_range,
			y_in => ayc_range,
			phase_out => acc_roll,
			rdy => atan_rdy2,
			clk => clk,
			sclr => atan_rst
		);
	
	
	
	
	--=========================--
	-- Combine gyro and accelerometer data
	
	--Multiply-postadd: op=0x0D; P=C+(a*b) = (atan_out1 * Kd) + p_pitch
	dsp_pitch: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => acc_pitch,	--rads, with 15 fractional places
			b => Kd,
			c => std_logic_vector(resize(signed(p_pitch(39 downto 7)), 48)),
			d => std_logic_vector(to_signed(0,18)),
			c_p_in => std_logic_vector(to_signed(0,48)),
			p => pitch,	--rads, with 32 fractional places (point between bits 32 and 31)
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"0D"
		);
		
	--Multiply-postadd: op=0x0D; P=C+(a*b) = (atan_out2 * Kd) + p_roll
	dsp_roll: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => acc_roll,
			b => Kd,
			c => std_logic_vector(resize(signed(p_pitch(39 downto 7)), 48)),
			d => std_logic_vector(to_signed(0,18)),
			c_p_in => std_logic_vector(to_signed(0,48)),
			p => roll,
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"0D"	
		);
	
	--Add stage: correct for mounting angle
	m_pitch <= std_logic_vector(signed(pitch) + signed(pitch_corr));
	m_roll <= std_logic_vector(signed(roll) + signed(roll_corr));
	
	
	pitch_out <= pitch(34 downto 19);	--Radians, with fifteen fractional places




end Behavioral;

