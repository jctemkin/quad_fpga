library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

--25 cycle latency from reset to result - arctan's latency is 22 cycles, DSP's is 3 cycles
--Sensor loop runs at 400Hz (every 2.5 ms)

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

	-- Constants!
	constant pi_32: signed(47 downto 0) := "000000000000001100100100001111110110101010001000"; --Pi, with 32 fractional places.
	constant ax_offset: std_logic_vector(17 downto 0) := "000000000000000000"; --std_logic_vector(to_signed(-430,18));
	constant ay_offset: std_logic_vector(17 downto 0) := "000000000000000000"; --std_logic_vector(to_signed(8, 18));
	constant az_offset: std_logic_vector(17 downto 0) := "000000000000000000"; --std_logic_vector(to_signed(85,18));
	
	constant gx_offset: std_logic_vector(17 downto 0) := "000000000000000000"; --std_logic_vector(to_signed(32,18));
	constant gy_offset: std_logic_vector(17 downto 0) := "000000000000000000"; --std_logic_vector(to_signed(28,18));
	constant gz_offset: std_logic_vector(17 downto 0) := "000000000000000000"; --std_logic_vector(to_signed(4,18));

	constant Dt: std_logic_vector(17 downto 0) := "010100011110101110"; --0.0025, 7 preceding fractional places (25 total); Time constant in s
	constant Kp: std_logic_vector(17 downto 0) := "011101000101110100"; --0.909090, 1 integer place; depends on Dt
	constant Kd: std_logic_vector(17 downto 0) := "000010111010001011"; --0.090909, 1 integer place depends on Dt
	
	--Scale gyro readings from 65.5 lsb/(deg/s) to rad/s
	constant gyro_scale: std_logic_vector(17 downto 0) := "010001011101100111";--0.00026646, 10 preceding fractional places (28 total)
	
	constant pitch_corr: std_logic_vector(47 downto 0) := std_logic_vector(to_signed(0,48));	--Correct when sensor mount is received.
	constant roll_corr: std_logic_vector(47 downto 0) := std_logic_vector(to_signed(0,48));
	
	
	--Calculation-related signals
	signal ax_raw, ay_raw, az_raw: std_logic_vector(17 downto 0);	--Raw accelerometer readins
	signal axc, ayc, azc: std_logic_vector(17 downto 0);				--Corrected readings for sensor deviation (acc_raw+acc_offset)
	signal axc_range, ayc_range, azc_range: std_logic_vector(17 downto 0);	--axyzc divided by two to be in range for arctan unit
	signal acc_pitch, acc_roll: std_logic_vector(17 downto 0);		--Arctans of xz and yz.
		
	signal gx_raw, gy_raw, gz_raw: std_logic_vector(17 downto 0);	--Raw gyro readings
	signal gx, gy, gz: std_logic_vector(47 downto 0);					--Gyro readings offset and scaled to millirad/s.
	signal gx_int, gy_int: std_logic_vector(47 downto 0);				--Integrated gyro readings (gxyz * Dt)
	
	signal last_pitch, last_roll: std_logic_vector(47 downto 0) := (others => '0');	--Result of last calculation iteration.
	signal p_pitch, p_roll: std_logic_vector(47 downto 0);			--Proportional terms (gxy_int + last_pr * Kp)
	signal pitch_raw, roll_raw: std_logic_vector(47 downto 0);		--Pitch and roll, before being brought into range
	signal pitch, roll: std_logic_vector(47 downto 0);
	signal m_pitch, m_roll: std_logic_vector(47 downto 0);			--Pitch and roll, corrected for mounting angle
	signal pitch_out, roll_out: std_logic_vector(15 downto 0);		--Correctly ranged and sized signals for writing to the regfile

	
	--Control signals
	signal atan_rdy1, atan_rdy2: std_logic;

	signal counter: integer range 0 to 262143 := 0;
	signal rst: std_logic;
	signal clk_en: std_logic := '0';
	signal atan_rst: std_logic;
	signal sync_rst: std_logic := '0';


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


	sync_proc: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' or counter = 249999 then
				counter <= 0;
				sync_rst <= '1';
				-- Load data from register file (and sign-extend)
				ax_raw <= std_logic_vector(resize(signed(read_regs(15 downto 0)), 18));
				ay_raw <= std_logic_vector(resize(signed(read_regs(31 downto 16)), 18));
				az_raw <= std_logic_vector(resize(signed(read_regs(47 downto 32)), 18));				
				gx_raw <= std_logic_vector(resize(signed(read_regs(63 downto 48)), 18));
				gy_raw <= std_logic_vector(resize(signed(read_regs(79 downto 64)), 18));
				gz_raw <= std_logic_vector(resize(signed(read_regs(95 downto 80)), 18));
			else
				counter <= counter + 1;
				sync_rst <= '0';
			end if;
			
			if counter = 26 then
				write_addr <= X"80";
				write_data <= pitch_out;
				write_en <= '1';
				last_pitch <= pitch;
			elsif counter = 27 then
				write_addr <= X"81";
				write_data <= roll_out;
				write_en <= '1';
				last_roll <= roll;
			else
				write_addr <= X"00";
				write_data <= X"0000";
				write_en <= '0';
			end if;
			
			if (counter = 24999) OR (counter < 26) then
				clk_en <= '1';
			else
				clk_en <= '0';
			end if;
		end if;
	end process;

	atan_rst <= reset OR sync_rst;
	rst <= reset OR sync_rst;	
	
	
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
			p => gx,	--rads/s, with 28 fractional places
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"11"
		);
	
	--Multiply-postadd: op=0x1D; P=c+(a*b) = (gx * Dt) + last_pitch
	dsp_gx2: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => gx(32 downto 15), 	--rads/s, with 13 fractional places
			b => Dt,						--s, with 25 fractional places
			c => last_pitch(41 downto 0) & "000000", --rads with 38 fractional places
			d => std_logic_vector(to_signed(0,18)),
			c_p_in => std_logic_vector(to_signed(0,48)),
			p => gx_int,	--rads, with 38 fractional places
			--gx_int: 	      7654321098.76543210987654321098765432109876543210
			--lp: 		7654321098765432.10987654321098765432109876543210000000
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"1D"	
		);
		
	
		
	--Multiply: op=0x01; C_P_out=a*b = gx_int * Kp (cascade to dsp_pitch)
	dsp_p_pitch: entity work.dsp48a1_wrapper(Behavioral)
		port map(
			a => gx_int(40 downto 23), --rads, with 15 fractional places
			b => Kp,							--constant, with 17 fractional places
			c => std_logic_vector(to_signed(0,48)),
			d => std_logic_vector(to_signed(0,18)),
			c_p_in => std_logic_vector(to_signed(0,48)),
			c_p_out => p_pitch,	--rads, with 32 fractional places
			
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
			c => last_roll(41 downto 0) & "000000",
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
			a => gy_int(40 downto 23),
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
			b => Kd,				--constant, with 17 fractional placees
			c => p_pitch, 		--rads, 32 fractional places
			d => std_logic_vector(to_signed(0,18)),
			c_p_in => std_logic_vector(to_signed(0,48)),
			p => pitch_raw,	--rads, with 32 fractional places
			
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
			c => p_pitch,
			d => std_logic_vector(to_signed(0,18)),
			c_p_in => std_logic_vector(to_signed(0,48)),
			p => roll_raw,
			
			rst => rst,
			clk => clk,
			clk_en => clk_en,
			opmode => X"0D"	
		);
	
	
	--Correct range of output
	pitch <= std_logic_vector(signed(pitch_raw) - signed(pi_32)) when signed(pitch_raw) > pi_32 else
				std_logic_vector(signed(pitch_raw) + signed(pi_32)) when signed(pitch_raw) < -pi_32 else
				pitch_raw;
				
	roll <= std_logic_vector(signed(roll_raw) - signed(pi_32)) when signed(roll_raw) > pi_32 else
				std_logic_vector(signed(roll_raw) + signed(pi_32)) when signed(roll_raw) < -pi_32 else
				roll_raw;
	
	--Correct for mounting angle
	m_pitch <= std_logic_vector(signed(pitch) + signed(pitch_corr));
	m_roll <= std_logic_vector(signed(roll) + signed(roll_corr));
	
	--Correct range here, again
	
	pitch_out <= m_pitch(34 downto 19);	--Radians, with thirteen fractional places
	roll_out <= m_roll(34 downto 19);	--Radians, with thirteen fractional places

	



end Behavioral;

