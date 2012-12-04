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
		write_data : out  STD_LOGIC_VECTOR (15 downto 0)
	);
end attitude_calc;

architecture Behavioral of attitude_calc is

	signal ax_offset, ay_offset, az_offset: std_logic_vector(17 downto 0);
	signal gx_offset, gy_offset, gz_offset: std_logic_vector(17 downto 0);
	signal Dt: std_logic_vector(17 downto 0);
	signal Kd: std_logic_vector(17 downto 0);
	signal Kp: std_logic_vector(17 downto 0);
	

	signal ax_raw, ayraw, azraw: std_logic_vector(17 downto 0);
	signal axc, ayc, azc: std_logic_vector(17 downto 0);
	signal acc_pitch, acc_roll: std_logic_vector(17 downto 0);
		
	signal gx_raw, gy_raw, gz_raw: std_logic_vector(17 downto 0);
	signal gx_scale, gy_scale, gz_scale: std_logic_vector(17 downto 0);	--scale gyro readings to be radians / ms, with 3 integer places (counting sign bit)
	signal gx, gy, gz: std_logic_vector(17 downto 0);
	signal gx_int, gy_int: std_logic_vector(17 downto 0);
	
	
	signal last_pitch, last_roll: std_logic_vector(17 downto 0);
	signal p_pitch, d_pitch: std_logic_vector(17 downto 0);	
	signal p_roll, d_roll: std_logic_vector(17 downto 0);
	signal pitch, roll: std_logic_vector(17 downto 0);
	signal m_pitch, m_roll: std_logic_vector(17 downto 0);

	signal atan_rdy1, atan_rdy2: std_logic;
	
	
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
	--=======================--
	-- Load data from register file
	ax_raw <= std_logic_vector(resize(signed(read_regs(15 downto 0)), 18));
	ay_raw <= std_logic_vector(resize(signed(read_regs(31 downto 16)), 18));
	az_raw <= std_logic_vector(resize(signed(read_regs(47 downto 32)), 18));
	
	
	
	
	
	
	
	
	--=======================--
	-- Gyro processing section
	-- Pitch:
	
	--Preadd-multiply: op=0x11; P=a*(b+d) = (gx_raw + gx_offset) * gx_scale
	--TODO: correct for overflow
	dsp_gx1: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => gx_scale,
			b => gx_raw,
			d => gx_offset,
			p => gx,
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"11"	
		);
	
	--Multiply-postadd: op=0x1D; P=c+(a*b) = (gx * Dt) + last_pitch
	dsp_gx2: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => gx,
			b => Dt,
			c => last_pitch,
			p => gx_int,
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"1D"	
		);
		
	--Multiply: op=0x01; C_P_out=a*b = gx_int * Kp (cascade to dsp_pitch)
	dsp_p_pitch: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => gx_int,
			b => Kp,
			c_p_out => p_pitch,
			
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
			a => gy_scale,
			b => gy_raw,
			d => gy_offset,
			p => gy,
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"11"
		);
	
	--Multiply-postadd: op=0x1D; P=c+(a*b) = (gy * Dt) + last_roll
	dsp_gy2: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => gy,
			b => Dt,
			c => last_roll,
			p => gy_int,
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"1D"	
		);
	
	--Multiply: op=0x01; C_P_out=a*b = gy_int * Kp (cascade to dsp_roll)
	dsp_p_roll: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => gy_int,
			b => Kp,
			c_p_out => p_roll,
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"01"	
		);
	
	
	
	--=========================--
	-- Accelerometer section
	
	--Add stage: add constants to raw sensor values
	--TODO: prevent overflow
	axc <= signed(ax_raw) + signed(ax_offset);
	ayc <= signed(ay_raw) + signed(ay_offset);
	azc <= signed(az_raw) + signed(az_offset);
	
	--Trig stage: take arctangent of offset sensor values
	arctan_i1: arctan
		port map(
			x_in => axc,
			y_in => azc,
			phase_out => acc_pitch,
			rdy => atan_rdy1,
			clk => clk
		);
		
	arctan_i2: arctan
		port map(
			x_in => ayc,
			y_in => azc,
			phase_out => acc_roll,
			rdy => atan_rdy2,
			clk => clk
		);
	
	
	
	
	--=========================--
	-- Combine gyro and accelerometer data
	
	--Cascade multiply-postadd: op=0x05; P=P_in+(a*b) = (atan_out1 * Kd) + p_pitch
	dsp_pitch: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => acc_pitch,
			b => Kd,
			c_p_in => p_pitch,
			p => pitch,
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"05"	
		);
		
	--Cascade multiply-postadd: op=0x05; P=P_in+(a*b) = (atan_out2 * Kd) + p_roll
	dsp_roll: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => acc_roll,
			b => Kd,
			c_p_in => p_roll,
			p => roll,
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"05"	
		);
	
	--Add stage: correct for mounting angle
	--TODO: overflow
	m_pitch <= signed(pitch) + signed(pitch_corr);
	m_roll <= signed(roll) + signed(roll_corr);
	
	





end Behavioral;

