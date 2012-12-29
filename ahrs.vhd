library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity ahrs is
	port ( 
		gx, gy, gz : in  STD_LOGIC_VECTOR (15 downto 0);
		ax, ay, az : in  STD_LOGIC_VECTOR (15 downto 0);
		mx, my, mz : in  STD_LOGIC_VECTOR (15 downto 0);
		gx_scale, gy_scale, gz_scale: in std_logic_vector(31 downto 0);
		ax_scale, ay_scale, az_scale: in std_logic_vector(31 downto 0);
		mx_scale, my_scale, mz_scale: in std_logic_vector(31 downto 0);
		gx_off, gy_off, gz_off: in std_logic_vector(31 downto 0);
		ax_off, ay_off, az_off: in std_logic_vector(31 downto 0);
		mx_off, my_off, mz_off: in std_logic_vector(31 downto 0);
		dt_in, Ki_in, Kp_in: in STD_LOGIC_VECTOR(31 downto 0);
		clk: in std_logic;
		start: in std_logic;
		
		q0: out std_logic_vector(31 downto 0);
		q1: out std_logic_vector(31 downto 0);
		q2: out std_logic_vector(31 downto 0);
		q3: out std_logic_vector(31 downto 0);
		ready: out std_logic
	);
end ahrs;

architecture Behavioral of ahrs is

component float_addsub
	port (
		a: in std_logic_vector(31 downto 0);
		b: in std_logic_vector(31 downto 0);
		operation: in std_logic_vector(5 downto 0);
		operation_nd: in std_logic;
		clk: in std_logic;
		sclr: in std_logic;
		ce: in std_logic;
		result: out std_logic_vector(31 downto 0);
		underflow: out std_logic;
		overflow: out std_logic;
		invalid_op: out std_logic;
		rdy: out std_logic
	);
end component;

component float_mult
	port (
		a: in std_logic_vector(31 downto 0);
		b: in std_logic_vector(31 downto 0);
		operation_nd: in std_logic;
		clk: in std_logic;
		sclr: in std_logic;
		ce: in std_logic;
		result: out std_logic_vector(31 downto 0);
		underflow: out std_logic;
		overflow: out std_logic;
		invalid_op: out std_logic;
		rdy: out std_logic
	);
end component;

component fixed16_to_float
	port (
		a: in std_logic_vector(15 downto 0);
		operation_nd: in std_logic;
		clk: in std_logic;
		sclr: in std_logic;
		ce: in std_logic;
		result: out std_logic_vector(31 downto 0);
		rdy: out std_logic
	);
end component;

component float_sqrt
	port (
		a: in std_logic_vector(31 downto 0);
		operation_nd: in std_logic;
		clk: in std_logic;
		sclr: in std_logic;
		ce: in std_logic;
		result: out std_logic_vector(31 downto 0);
		invalid_op: out std_logic;
		rdy: out std_logic
	);
end component;
	
	constant one_half: std_logic_vector(31 downto 0) := X"3F000000";
	constant two: std_logic_vector(31 downto 0) := X"40000000";
	
	type triple_16b is array (0 to 2) of std_logic_vector(15 downto 0);
	type triple_32b is array (0 to 2) of std_logic_vector(31 downto 0);
	
	signal axyz_raw, gxyz_raw, mxyz_raw: triple_16b;
	signal axyz_scale, gxyz_scale, mxyz_scale: triple_32b;
	signal axyz_off, gxyz_off, mxyz_off: triple_32b;
	
	signal Kp, Ki, dt: std_logic_vector(31 downto 0);
	
	signal f2f_fixed: triple_16b;
	signal f2f_float: triple_32b;
	signal f2f_nd: std_logic_vector(2 downto 0) := "000";
	signal f2f_rdy: std_logic_vector(2 downto 0);
	
	
	type reg_type is array(0 to 31) of std_logic_vector(31 downto 0);
	signal reg: reg_type := (others => (others => '0'));
	
	type dest_type_4 is array (3 downto 0) of integer range 0 to 31;
	type dest_type_3 is array (2 downto 0) of integer range 0 to 31;
	signal mul_dest_reg, addsub_dest_reg, mov_dest_reg: dest_type_4 := (others => 0);
	signal f2f_dest_reg: dest_type_3 := (others => 0);
	signal invsqrt_dest_reg: integer range 0 to 31 := 0;
	signal sqrt_dest_reg: integer range 0 to 31 := 0;
	
	signal mul_dest: dest_type_4;
	signal addsub_dest: dest_type_4;
	signal f2f_dest: dest_type_3;
	signal invsqrt_dest: integer range 0 to 31;
	signal sqrt_dest: integer range 0 to 31;
	signal mov_dest: dest_type_4;
	
	type float_arr is array (0 to 3) of std_logic_vector(31 downto 0);
	type fixed_arr is array (0 to 3) of std_logic_vector(15 downto 0);
	signal mul_a, mul_b, addsub_a, addsub_b, mul_result, addsub_result, mov_src: float_arr;
	signal mul_rdy, addsub_rdy: std_logic_vector(3 downto 0);
	signal mul_nd, addsub_nd, mov_nd, addsub_op: std_logic_vector(3 downto 0) := X"0";	--Addsub_op of 0 means add, 1 means subtract.
	
	signal sqrt_in, sqrt_result, invsqrt_in, invsqrt_result: std_logic_vector(31 downto 0);
	signal sqrt_rdy, invsqrt_rdy: std_logic;
	signal sqrt_nd, invsqrt_nd: std_logic := '0';
	
	signal sclr: std_logic := '0';
	signal ce: std_logic := '1';
	
	signal op_ch: std_logic_vector(16 downto 0) := (others => '0');
	signal op_complete: std_logic_vector(16 downto 0) := (others => '0');	
	
	type pipeline_stage_type is (s_idle, s_int, s_issue, s_execute, s_writeback);
	signal pipeline_state: pipeline_stage_type := s_idle;
	signal next_pipeline_state: pipeline_stage_type;
	signal state: natural range 0 to 255;
	signal state_v: unsigned(7 downto 0);	--For readability, because isim won't let you change the radix on integers.
	
	
	signal q: float_arr := (others => (others => '0'));
	signal ready_reg: std_logic := '0';

	
begin

	--Wire up various combinational things.
	q0 <= q(0);
	q1 <= q(1);
	q2 <= q(2);
	q3 <= q(3);
	ready <= ready_reg;
	state_v <= to_unsigned(state, 8);
	

	--Instantiate functional units.
	f2fs: for i in 0 to 2 generate
	begin
		f2f: fixed16_to_float 
		port map (
			a => f2f_fixed(i),
			operation_nd => f2f_nd(i),
			clk => clk,
			sclr => sclr,
			ce => ce,
			result => f2f_float(i),
			rdy => f2f_rdy(i)
		);
	end generate f2fs;

	mults: for i in 0 to 3 generate
	begin
		mult: float_mult
		port map (
			a => mul_a(i),
			b => mul_b(i),
			operation_nd => mul_nd(i),
			clk => clk,
			sclr => sclr,
			ce => ce,
			result => mul_result(i),
			rdy => mul_rdy(i)
		);	
	end generate mults;
	
	addsubs: for i in 0 to 3 generate
	begin
		addsub: float_addsub
		port map (
			a => addsub_a(i),
			b => addsub_b(i),
			operation => "00000" & addsub_op(i),
			operation_nd => addsub_nd(i),
			clk => clk,
			sclr => sclr,
			ce => ce,
			result => addsub_result(i),
			rdy => addsub_rdy(i)
		);
	end generate addsubs;

	sqrt: float_sqrt
		port map (
			a => sqrt_in,
			operation_nd => sqrt_nd,
			clk => clk,
			sclr => sclr,
			ce => ce,
			result => sqrt_result,
			rdy => sqrt_rdy
		);

	invsqrt_i: entity work.invsqrt(Behavioral)
		port map (
			x => invsqrt_in,
			clk => clk,
			start => invsqrt_nd,
			data_ready => invsqrt_rdy,
			result => invsqrt_result
		);
	
	
	--Synchronous controls.
	process(clk)
	begin
		if rising_edge(clk) then
			
			pipeline_state <= next_pipeline_state;
			
			if state = 37 AND pipeline_state = s_writeback then
				ready_reg <= '1';
				state <= 0;
			elsif (next_pipeline_state = s_issue OR next_pipeline_state = s_int) then
				ready_reg <= '0';
				state <= state + 1;
			end if;
			
			-- Remember which operations we need to check for completion, and write results back to appropriate registers.
			if pipeline_state = s_issue then
				op_ch <= mov_nd & f2f_nd & mul_nd & addsub_nd & invsqrt_nd & sqrt_nd;
				mul_dest_reg <= mul_dest;
				addsub_dest_reg <= addsub_dest;
				f2f_dest_reg <= f2f_dest;
				invsqrt_dest_reg <= invsqrt_dest;
				sqrt_dest_reg <= sqrt_dest;
				mov_dest_reg <= mov_dest;
				op_complete <= (others => '0');
			elsif pipeline_state = s_execute then
				op_complete <= op_complete OR ("1111" & f2f_rdy & mul_rdy & addsub_rdy & invsqrt_rdy & sqrt_rdy);
			elsif pipeline_state = s_writeback then
				for i in 0 to 16 loop
					if op_ch(i) = '1' then
						case i is
							when 0 =>
								reg(sqrt_dest_reg) <= sqrt_result;
							when 1 =>
								reg(invsqrt_dest_reg) <= invsqrt_result;
							when 2 =>
								reg(addsub_dest_reg(0)) <= addsub_result(0);
							when 3 =>
								reg(addsub_dest_reg(1)) <= addsub_result(1);
							when 4 =>
								reg(addsub_dest_reg(2)) <= addsub_result(2);
							when 5 =>
								reg(addsub_dest_reg(3)) <= addsub_result(3);
							when 6 =>
								reg(mul_dest_reg(0)) <= mul_result(0);
							when 7 =>
								reg(mul_dest_reg(1)) <= mul_result(1);
							when 8 =>
								reg(mul_dest_reg(2)) <= mul_result(2);
							when 9 =>
								reg(mul_dest_reg(3)) <= mul_result(3);
							when 10 =>
								reg(f2f_dest_reg(0)) <= f2f_float(0);
							when 11 =>
								reg(f2f_dest_reg(1)) <= f2f_float(1);
							when 12 =>
								reg(f2f_dest_reg(2)) <= f2f_float(2);
							when 13 => 
								reg(mov_dest_reg(0)) <= mov_src(0);
							when 14 => 
								reg(mov_dest_reg(1)) <= mov_src(1);
							when 15 => 
								reg(mov_dest_reg(2)) <= mov_src(2);
							when 16 => 
								reg(mov_dest_reg(3)) <= mov_src(3);
						end case;
					end if;
				end loop;
				op_ch <= (others => '0');
				
			end if;
			
			
			if state = 1 then
				axyz_raw(0) <= ax; axyz_raw(1) <= ay; axyz_raw(2) <= az;
				gxyz_raw(0) <= gx; gxyz_raw(1) <= gy; gxyz_raw(2) <= gz;
				mxyz_raw(0) <= mx; mxyz_raw(1) <= my; mxyz_raw(2) <= mz;
				axyz_scale(0) <= ax_scale; axyz_scale(1) <= ay_scale; axyz_scale(2) <= az_scale;
				gxyz_scale(0) <= gx_scale; gxyz_scale(1) <= gy_scale; gxyz_scale(2) <= gz_scale;
				mxyz_scale(0) <= mx_scale; mxyz_scale(1) <= my_scale; mxyz_scale(2) <= mz_scale;
				axyz_off(0) <= ax_off; axyz_off(1) <= ay_off; axyz_off(2) <= az_off;
				gxyz_off(0) <= gx_off; gxyz_off(1) <= gy_off; gxyz_off(2) <= gz_off;
				mxyz_off(0) <= mx_off; mxyz_off(1) <= my_off; mxyz_off(2) <= mz_off;
				Kp <= Kp_in;
				Ki <= Ki_in;
				dt <= dt_in;
				
			elsif state = 38 then
				q(0) <= reg(15);
				q(1) <= reg(16);
				q(2) <= reg(17);
				q(3) <= reg(18);
				
			end if;

		end if;
	end process;


	--Controls the pipeline stages.
	process(pipeline_state, start, op_ch, op_complete, state)
	begin
		case pipeline_state is
			when s_idle =>
				if start = '1' then
					next_pipeline_state <= s_int;
				else
					next_pipeline_state <= s_idle;
				end if;
				
				
			when s_int =>
				next_pipeline_state <= s_issue;
			
			
			when s_issue =>
				next_pipeline_state <= s_execute;
			
			
			-- Check if all operations requested have completed.
			when s_execute =>
				if (op_ch AND (op_complete OR ("1111" & f2f_rdy & mul_rdy & addsub_rdy & invsqrt_rdy & sqrt_rdy))) = op_ch then
					next_pipeline_state <= s_writeback;
				else
					next_pipeline_state <= s_execute;
				end if;
				
				
			when s_writeback =>
				if state = 37 then
					next_pipeline_state <= s_idle;
				else
					next_pipeline_state <= s_issue;
				end if;
				
		end case;
		
	end process;
	
	
	
	--Instructions. Consider creating machine code for this.
	process(state, pipeline_state)
	begin
		if pipeline_state = s_issue then
			case state is
				when 2 =>
					f2f_fixed(0) <= mxyz_raw(0); f2f_dest(0) <= 23;
					f2f_fixed(1) <= mxyz_raw(1); f2f_dest(1) <= 24;
					f2f_fixed(2) <= mxyz_raw(2); f2f_dest(2) <= 25;
					f2f_nd <= "111";
				
				when 3 =>
					f2f_fixed(0) <= axyz_raw(0); f2f_dest(0) <= 28;
					f2f_fixed(1) <= axyz_raw(1); f2f_dest(1) <= 27;
					f2f_fixed(2) <= axyz_raw(2); f2f_dest(2) <= 26;
					f2f_nd <= "111";
					
					addsub_a(0) <= reg(23);
					addsub_b(0) <= mxyz_off(0);
					addsub_op(0) <= '1';	addsub_dest(0) <= 23;
					
					addsub_a(1) <= reg(24);
					addsub_b(1) <= mxyz_off(1);
					addsub_op(1) <= '1';	addsub_dest(1) <= 24;
					
					addsub_a(2) <= reg(25);
					addsub_b(2) <= mxyz_off(2);
					addsub_op(2) <= '1';	addsub_dest(2) <= 25;
					addsub_nd(2 downto 0) <= "111";
					
				when 4 =>
					f2f_fixed(0) <= gxyz_raw(0); f2f_dest(0) <= 29;
					f2f_fixed(1) <= gxyz_raw(1); f2f_dest(1) <= 30;
					f2f_fixed(2) <= gxyz_raw(2); f2f_dest(2) <= 31;
					f2f_nd <= "111";
					
					addsub_a(0) <= reg(26);
					addsub_b(0) <= axyz_off(2);
					addsub_op(0) <= '1';	addsub_dest(0) <= 26;
					
					addsub_a(1) <= reg(27);
					addsub_b(1) <= axyz_off(1);
					addsub_op(1) <= '1';	addsub_dest(1) <= 27;
					
					addsub_a(2) <= reg(28);
					addsub_b(2) <= axyz_off(0);
					addsub_op(2) <= '1';	addsub_dest(2) <= 28;
					addsub_nd(2 downto 0) <= "111";
					
					mul_a(0) <= reg(23);
					mul_b(0) <= mxyz_scale(0);
					mul_dest(0) <= 23;
					
					mul_a(1) <= reg(24);
					mul_b(1) <= mxyz_scale(1);
					mul_dest(1) <= 24;
					
					mul_a(2) <= reg(25);
					mul_b(2) <= mxyz_scale(2);
					mul_dest(2) <= 25;
					mul_nd(2 downto 0) <= "111";
					
					
				when 5 =>
					addsub_a(0) <= reg(29);
					addsub_b(0) <= gxyz_off(0);
					addsub_op(0) <= '1';	addsub_dest(0) <= 29;
					
					addsub_a(1) <= reg(30);
					addsub_b(1) <= gxyz_off(1);
					addsub_op(1) <= '1';	addsub_dest(1) <= 30;
					
					addsub_a(2) <= reg(31);
					addsub_b(2) <= gxyz_off(2);
					addsub_op(2) <= '1';	addsub_dest(2) <= 31;
					addsub_nd(2 downto 0) <= "111";
					
					mul_a(0) <= reg(26);
					mul_b(0) <= axyz_scale(2);
					mul_dest(0) <= 26;
					
					mul_a(1) <= reg(27);
					mul_b(1) <= axyz_scale(1);
					mul_dest(1) <= 27;
					
					mul_a(2) <= reg(28);
					mul_b(2) <= axyz_scale(0);
					mul_dest(2) <= 28;
					mul_nd(2 downto 0) <= "111";
					
					
				when 6 =>
					mul_a(0) <= reg(29);
					mul_b(0) <= gxyz_scale(0);
					mul_dest(0) <= 29;
					
					mul_a(1) <= reg(30);
					mul_b(1) <= gxyz_scale(1);
					mul_dest(1) <= 30;
					
					mul_a(2) <= reg(31);
					mul_b(2) <= gxyz_scale(2);
					mul_dest(2) <= 31;
					mul_nd(2 downto 0) <= "111";
					
					
				when 7 =>
					mul_a(0) <= reg(23);
					mul_b(0) <= reg(23);
					mul_dest(0) <= 0;
					
					mul_a(1) <= reg(24);
					mul_b(1) <= reg(24);
					mul_dest(1) <= 1;
					
					mul_a(2) <= reg(25);
					mul_b(2) <= reg(25);
					mul_dest(2) <= 2;
					mul_nd(2 downto 0) <= "111";
					
					
				when 8 =>
					addsub_a(0) <= reg(0);
					addsub_b(0) <= reg(1);
					addsub_op(0) <= '0'; addsub_dest(0) <= 0;
					addsub_nd(0) <= '1';
					
					mul_a(0) <= q(0);
					mul_b(0) <= q(2);
					mul_dest(0) <= 6;
					
					mul_a(1) <= q(1);
					mul_b(1) <= q(1);
					mul_dest(1) <= 7;
					
					mul_a(2) <= q(1);
					mul_b(2) <= q(3);
					mul_dest(2) <= 8;
					
					mul_a(3) <= q(2);
					mul_b(3) <= q(2);
					mul_dest(3) <= 9;
					mul_nd <= "1111";
					
					
				when 9 =>
					addsub_a(0) <= reg(0);
					addsub_b(0) <= reg(2);
					addsub_op(0) <= '0'; addsub_dest(0) <= 0;
				
					addsub_a(1) <= reg(6);
					addsub_b(1) <= reg(8);
					addsub_op(1) <= '0'; addsub_dest(0) <= 6;
					
					addsub_a(2) <= one_half;
					addsub_b(2) <= reg(7);
					addsub_op(2) <= '1'; addsub_dest(0) <= 7;
					
					addsub_a(3) <= reg(8);
					addsub_b(3) <= reg(6);
					addsub_op(3) <= '1'; addsub_dest(0) <= 8;
					addsub_nd <= "1111";
				
					mul_a(0) <= reg(27);
					mul_b(0) <= reg(27);
					mul_dest(0) <= 4;
					
					mul_a(1) <= q(0);
					mul_b(1) <= q(3);
					mul_dest(1) <= 10;
					
					mul_a(2) <= q(1);
					mul_b(2) <= q(2);
					mul_dest(2) <= 11;
					
					mul_a(3) <= q(3);
					mul_b(3) <= q(3);
					mul_dest(3) <= 16;
					mul_nd <= "1111";
					
					
				when 10 =>
					invsqrt_in <= reg(0);
					invsqrt_nd <= '1';
					invsqrt_dest <= 0;
					
					addsub_a(0) <= reg(7);
					addsub_b(0) <= reg(9);
					addsub_op(0) <= '1'; addsub_dest(0) <= 7;
				
					addsub_a(1) <= reg(10);
					addsub_b(1) <= reg(11);
					addsub_op(1) <= '0'; addsub_dest(0) <= 10;
					
					addsub_a(2) <= reg(11);
					addsub_b(2) <= reg(10);
					addsub_op(2) <= '1'; addsub_dest(0) <= 11;
					
					addsub_a(3) <= reg(7);
					addsub_b(3) <= reg(16);
					addsub_op(3) <= '1'; addsub_dest(0) <= 15;
					addsub_nd <= "1111";
				
					mul_a(0) <= reg(27);
					mul_b(0) <= reg(27);
					mul_dest(0) <= 4;
					
					mul_a(1) <= q(0);
					mul_b(1) <= q(3);
					mul_dest(1) <= 10;
					
					mul_a(2) <= q(1);
					mul_b(2) <= q(2);
					mul_dest(2) <= 11;
					
					mul_a(3) <= q(3);
					mul_b(3) <= q(3);
					mul_dest(3) <= 16;
					mul_nd <= "1111";
					
					mov_src(0) <= reg(6);
					mov_dest(0) <= 17;
					
					mov_src(1) <= reg(8);
					mov_dest(1) <= 18;
					mov_nd(1 downto 0) <= "11";
					
			
				when 11 =>
					addsub_a(0) <= one_half;
					addsub_b(0) <= reg(9);
					addsub_op(0) <= '1'; addsub_dest(0) <= 9;
				
					addsub_a(1) <= reg(12);
					addsub_b(1) <= reg(13);
					addsub_op(1) <= '0'; addsub_dest(0) <= 12;
					
					addsub_a(2) <= reg(13);
					addsub_b(2) <= reg(12);
					addsub_op(2) <= '1'; addsub_dest(0) <= 13;
					
					addsub_a(3) <= reg(14);
					addsub_b(3) <= one_half;
					addsub_op(3) <= '1'; addsub_dest(0) <= 14;
					addsub_nd <= "1111";
				
					mul_a(0) <= reg(23);
					mul_b(0) <= reg(0);
					mul_dest(0) <= 0;
					
					mul_a(1) <= reg(24);
					mul_b(1) <= reg(0);
					mul_dest(1) <= 1;
					
					mul_a(2) <= reg(25);
					mul_b(2) <= reg(0);
					mul_dest(2) <= 2;
					
					mul_a(3) <= reg(26);
					mul_b(3) <= reg(26);
					mul_dest(3) <= 3;
					mul_nd <= "1111";
					
					mov_src(0) <= reg(11);
					mov_dest(0) <= 19;
					
					mov_src(1) <= reg(7);
					mov_dest(1) <= 20;
					mov_nd(1 downto 0) <= "11";
					

				when 12 =>
					addsub_a(0) <= reg(5);
					addsub_b(0) <= reg(4);
					addsub_op(0) <= '0'; addsub_dest(0) <= 5;
				
					addsub_a(1) <= reg(9);
					addsub_b(1) <= reg(16);
					addsub_op(1) <= '1'; addsub_dest(0) <= 9;
					
					addsub_a(2) <= reg(14);
					addsub_b(2) <= reg(16);
					addsub_op(2) <= '0'; addsub_dest(0) <= 14;
					addsub_nd(2 downto 0) <= "111";
				
					mul_a(0) <= reg(6);
					mul_b(0) <= reg(2);
					mul_dest(0) <= 6;
					
					mul_a(1) <= reg(10);
					mul_b(1) <= reg(0);
					mul_dest(1) <= 10;
					
					mul_a(2) <= reg(11);
					mul_b(2) <= reg(1);
					mul_dest(2) <= 11;
					
					mul_a(3) <= reg(15);
					mul_b(3) <= reg(1);
					mul_dest(3) <= 15;
					mul_nd <= "1111";
					
					mov_src(0) <= reg(12);
					mov_dest(0) <= 11;
					mov_nd(0) <= '1';
					
					
				when 13 =>
					addsub_a(0) <= reg(5);
					addsub_b(0) <= reg(3);
					addsub_op(0) <= '0'; addsub_dest(0) <= 5;
				
					addsub_a(1) <= reg(10);
					addsub_b(1) <= reg(15);
					addsub_op(1) <= '0'; addsub_dest(0) <= 10;
					
					addsub_a(2) <= reg(11);
					addsub_b(2) <= reg(6);
					addsub_op(2) <= '0'; addsub_dest(0) <= 11;
					addsub_nd(2 downto 0) <= "111";
				
					mul_a(0) <= reg(7);
					mul_b(0) <= reg(2);
					mul_dest(0) <= 7;
					
					mul_a(1) <= reg(8);
					mul_b(1) <= reg(0);
					mul_dest(1) <= 8;
					
					mul_a(2) <= reg(9);
					mul_b(2) <= reg(0);
					mul_dest(2) <= 9;
					
					mul_a(3) <= reg(13);
					mul_b(3) <= reg(2);
					mul_dest(3) <= 13;
					mul_nd <= "1111";
					
					mov_src(0) <= reg(9);
					mov_dest(0) <= 21;
					mov_nd(0) <= '1';
					
					
				when 14 =>
					invsqrt_in <= reg(5);
					invsqrt_nd <= '1';
					invsqrt_dest <= 5;
					
					addsub_a(0) <= reg(7);
					addsub_b(0) <= reg(8);
					addsub_op(0) <= '0'; addsub_dest(0) <= 7;
				
					addsub_a(1) <= reg(10);
					addsub_b(1) <= reg(13);
					addsub_op(1) <= '0'; addsub_dest(0) <= 10;
					
					addsub_a(2) <= reg(11);
					addsub_b(2) <= reg(9);
					addsub_op(2) <= '0'; addsub_dest(0) <= 11;
					addsub_nd(2 downto 0) <= "111";
				
					mul_a(0) <= reg(12);
					mul_b(0) <= reg(1);
					mul_dest(0) <= 12;
					mul_nd(0) <= '1';
					
					
				when 15 =>
					addsub_a(0) <= reg(7);
					addsub_b(0) <= reg(12);
					addsub_op(0) <= '0'; addsub_dest(0) <= 7;
					addsub_nd(0) <= '1';
				
					mul_a(0) <= reg(5);
					mul_b(0) <= reg(27);
					mul_dest(0) <= 4;
					
					mul_a(1) <= reg(5);
					mul_b(1) <= reg(28);
					mul_dest(1) <= 5;
					
					mul_a(2) <= reg(10);
					mul_b(2) <= two;
					mul_dest(2) <= 10;
					
					mul_a(3) <= reg(11);
					mul_b(3) <= two;
					mul_dest(3) <= 11;
					mul_nd <= "1111";
					
					
				when 16 =>
					mul_a(0) <= reg(5);
					mul_b(0) <= reg(26);
					mul_dest(0) <= 3;
					
					mul_a(1) <= reg(7);
					mul_b(1) <= two;
					mul_dest(1) <= 7;
					
					mul_a(2) <= reg(10);
					mul_b(2) <= reg(10);
					mul_dest(2) <= 10;
					
					mul_a(3) <= reg(11);
					mul_b(3) <= reg(11);
					mul_dest(3) <= 11;
					mul_nd <= "1111";
				
				
				when 17 =>
					addsub_a(0) <= reg(10);
					addsub_b(0) <= reg(11);
					addsub_op(0) <= '0'; addsub_dest(0) <= 10;
					addsub_nd(0) <= '1';
				
					mul_a(0) <= reg(5);
					mul_b(0) <= reg(22);
					mul_dest(0) <= 12;
					
					mul_a(1) <= reg(4);
					mul_b(1) <= reg(14);
					mul_dest(1) <= 13;
					
					mul_a(2) <= reg(3);
					mul_b(2) <= reg(18);
					mul_dest(2) <= 15;
					mul_nd(2 downto 0) <= "111";
					
				
				when 18 =>
					sqrt_in <= reg(10);
					sqrt_dest <= 10;
					sqrt_nd <= '1';
				
					mul_a(0) <= reg(7);
					mul_b(0) <= reg(18);
					mul_dest(0) <= 6;
					
					mul_a(1) <= reg(7);
					mul_b(1) <= reg(20);
					mul_dest(1) <= 7;
					
					mul_a(2) <= reg(7);
					mul_b(2) <= reg(22);
					mul_dest(2) <= 8;
					mul_nd(2 downto 0) <= "111";
					
					
				when 19 =>
					mul_a(0) <= reg(10);
					mul_b(0) <= reg(21);
					mul_dest(0) <= 9;
					
					mul_a(1) <= reg(10);
					mul_b(1) <= reg(19);
					mul_dest(1) <= 10;
					
					mul_a(2) <= reg(10);
					mul_b(2) <= reg(17);
					mul_dest(2) <= 11;
					mul_nd(2 downto 0) <= "111";
					
					
				when 20 =>
					addsub_a(0) <= reg(9);
					addsub_b(0) <= reg(6);
					addsub_op(0) <= '0'; addsub_dest(0) <= 9;
				
					addsub_a(1) <= reg(10);
					addsub_b(1) <= reg(8);
					addsub_op(1) <= '0'; addsub_dest(0) <= 10;
					
					addsub_a(2) <= reg(11);
					addsub_b(2) <= reg(7);
					addsub_op(2) <= '0'; addsub_dest(0) <= 11;
					addsub_nd(2 downto 0) <= "111";
					
					mul_a(0) <= reg(5);
					mul_b(0) <= reg(14);
					mul_dest(0) <= 16;
					
					mul_a(1) <= reg(4);
					mul_b(1) <= reg(18);
					mul_dest(1) <= 17;
					
					mul_a(2) <= reg(3);
					mul_b(2) <= reg(22);
					mul_dest(2) <= 18;
					mul_nd(2 downto 0) <= "111";
					
				
				when 21 =>
					mul_a(0) <= reg(9);
					mul_b(0) <= reg(1);
					mul_dest(0) <= 3;
					
					mul_a(1) <= reg(9);
					mul_b(1) <= reg(2);
					mul_dest(1) <= 4;
					
					mul_a(2) <= reg(10);
					mul_b(2) <= reg(0);
					mul_dest(2) <= 6;
					
					mul_a(3) <= reg(10);
					mul_b(3) <= reg(2);
					mul_dest(3) <= 7;
					mul_nd <= "1111";
					
					addsub_a(0) <= reg(12);
					addsub_b(0) <= reg(17);
					addsub_op(0) <= '1'; addsub_dest(0) <= 12;
				
					addsub_a(1) <= reg(13);
					addsub_b(1) <= reg(18);
					addsub_op(1) <= '1'; addsub_dest(0) <= 13;
					
					addsub_a(2) <= reg(15);
					addsub_b(2) <= reg(16);
					addsub_op(2) <= '1'; addsub_dest(0) <= 14;
					addsub_nd(2 downto 0) <= "111";
				
				
				when 22 =>
					mul_a(0) <= reg(11);
					mul_b(0) <= reg(1);
					mul_dest(0) <= 9;
					
					mul_a(1) <= reg(11);
					mul_b(1) <= reg(0);
					mul_dest(1) <= 10;
					mul_nd(1 downto 0) <= "11";
					
				
				when 23 =>
					addsub_a(0) <= reg(4);
					addsub_b(0) <= reg(10);
					addsub_op(0) <= '1'; addsub_dest(0) <= 4;
				
					addsub_a(1) <= reg(6);
					addsub_b(1) <= reg(3);
					addsub_op(1) <= '1'; addsub_dest(0) <= 6;
					
					addsub_a(2) <= reg(9);
					addsub_b(2) <= reg(7);
					addsub_op(2) <= '1'; addsub_dest(0) <= 9;
					addsub_nd(2 downto 0) <= "111";
					
					mul_a(0) <= dt;
					mul_b(0) <= one_half;
					mul_dest(0) <= 15;
					
					mul_a(1) <= Ki;
					mul_b(1) <= two;
					mul_dest(1) <= 16;
					
					mul_a(2) <= Kp;
					mul_b(2) <= two;
					mul_dest(2) <= 17;
					mul_nd(2 downto 0) <= "111";
				
				
				when 24 =>
					addsub_a(0) <= reg(4);
					addsub_b(0) <= reg(14);
					addsub_op(0) <= '0'; addsub_dest(0) <= 4;
				
					addsub_a(1) <= reg(6);
					addsub_b(1) <= reg(12);
					addsub_op(1) <= '0'; addsub_dest(0) <= 6;
					
					addsub_a(2) <= reg(9);
					addsub_b(2) <= reg(13);
					addsub_op(2) <= '0'; addsub_dest(0) <= 9;
					addsub_nd(2 downto 0) <= "111";
					
					mul_a(0) <= dt;
					mul_b(0) <= reg(16);
					mul_dest(0) <= 16;
					mul_nd(0) <= '1';
				
				
				when 25 =>
					mul_a(0) <= reg(4);
					mul_b(0) <= reg(16);
					mul_dest(0) <= 3;
					
					mul_a(1) <= reg(6);
					mul_b(1) <= reg(16);
					mul_dest(1) <= 7;
					
					mul_a(2) <= reg(9);
					mul_b(2) <= reg(16);
					mul_dest(2) <= 10;
					mul_nd(2 downto 0) <= "111";
					
					
				when 26 =>
					addsub_a(0) <= reg(3);
					addsub_b(0) <= reg(30);
					addsub_op(0) <= '0'; addsub_dest(0) <= 3;
				
					addsub_a(1) <= reg(7);
					addsub_b(1) <= reg(31);
					addsub_op(1) <= '0'; addsub_dest(0) <= 7;
					
					addsub_a(2) <= reg(10);
					addsub_b(2) <= reg(28);
					addsub_op(2) <= '0'; addsub_dest(0) <= 10;
					addsub_nd(2 downto 0) <= "111";
					
					mul_a(0) <= reg(4);
					mul_b(0) <= reg(17);
					mul_dest(0) <= 4;
					
					mul_a(1) <= reg(6);
					mul_b(1) <= reg(17);
					mul_dest(1) <= 6;
					
					mul_a(2) <= reg(9);
					mul_b(2) <= reg(17);
					mul_dest(2) <= 9;
					mul_nd(2 downto 0) <= "111";
					
				
				when 27 =>
					addsub_a(0) <= reg(3);
					addsub_b(0) <= reg(4);
					addsub_op(0) <= '0'; addsub_dest(0) <= 3;
				
					addsub_a(1) <= reg(7);
					addsub_b(1) <= reg(6);
					addsub_op(1) <= '0'; addsub_dest(0) <= 7;
					
					addsub_a(2) <= reg(10);
					addsub_b(2) <= reg(9);
					addsub_op(2) <= '0'; addsub_dest(0) <= 10;
					addsub_nd(2 downto 0) <= "111";
				
				
				when 28 =>
					mul_a(0) <= reg(3);
					mul_b(0) <= reg(15);
					mul_dest(0) <= 3;
					
					mul_a(1) <= reg(7);
					mul_b(1) <= reg(15);
					mul_dest(1) <= 7;
					
					mul_a(2) <= reg(10);
					mul_b(2) <= reg(15);
					mul_dest(2) <= 10;
					mul_nd(2 downto 0) <= "111";
				
				
				when 29 =>
					mul_a(0) <= reg(10);
					mul_b(0) <= q(0);
					mul_dest(0) <= 10;
					
					mul_a(1) <= reg(10);
					mul_b(1) <= q(1);
					mul_dest(1) <= 11;
					
					mul_a(2) <= reg(10);
					mul_b(2) <= q(2);
					mul_dest(2) <= 12;
					
					mul_a(3) <= reg(10);
					mul_b(3) <= q(3);
					mul_dest(3) <= 13;
					mul_nd <= "1111";
					
				
				when 30 =>
					addsub_a(0) <= q(0);
					addsub_b(0) <= reg(11);
					addsub_op(0) <= '1'; addsub_dest(0) <= 15;
				
					addsub_a(1) <= q(1);
					addsub_b(1) <= reg(10);
					addsub_op(1) <= '0'; addsub_dest(0) <= 16;
					
					addsub_a(2) <= q(2);
					addsub_b(2) <= reg(13);
					addsub_op(2) <= '0'; addsub_dest(0) <= 17;
					
					addsub_a(3) <= q(3);
					addsub_b(3) <= reg(12);
					addsub_op(3) <= '1'; addsub_dest(0) <= 18;
					addsub_nd <= "1111";
					
					mul_a(0) <= reg(3);
					mul_b(0) <= q(0);
					mul_dest(0) <= 0;
					
					mul_a(1) <= reg(3);
					mul_b(1) <= q(1);
					mul_dest(1) <= 1;
					
					mul_a(2) <= reg(3);
					mul_b(2) <= q(2);
					mul_dest(2) <= 2;
					
					mul_a(3) <= reg(3);
					mul_b(3) <= q(3);
					mul_dest(3) <= 3;
					mul_nd <= "1111";
					
				
				when 31 =>
					addsub_a(0) <= reg(15);
					addsub_b(0) <= reg(2);
					addsub_op(0) <= '1'; addsub_dest(0) <= 15;
				
					addsub_a(1) <= reg(16);
					addsub_b(1) <= reg(3);
					addsub_op(1) <= '1'; addsub_dest(0) <= 16;
					
					addsub_a(2) <= reg(17);
					addsub_b(2) <= reg(0);
					addsub_op(2) <= '0'; addsub_dest(0) <= 17;
					
					addsub_a(3) <= reg(18);
					addsub_b(3) <= reg(1);
					addsub_op(3) <= '0'; addsub_dest(0) <= 18;
					addsub_nd <= "1111";
					
					mul_a(0) <= reg(7);
					mul_b(0) <= q(0);
					mul_dest(0) <= 5;
					
					mul_a(1) <= reg(7);
					mul_b(1) <= q(1);
					mul_dest(1) <= 6;
					
					mul_a(2) <= reg(7);
					mul_b(2) <= q(2);
					mul_dest(2) <= 7;
					
					mul_a(3) <= reg(7);
					mul_b(3) <= q(3);
					mul_dest(3) <= 8;
					mul_nd <= "1111";
					
					
				when 32 =>
					addsub_a(0) <= reg(15);
					addsub_b(0) <= reg(8);
					addsub_op(0) <= '1'; addsub_dest(0) <= 15;
				
					addsub_a(1) <= reg(16);
					addsub_b(1) <= reg(7);
					addsub_op(1) <= '0'; addsub_dest(0) <= 16;
					
					addsub_a(2) <= reg(17);
					addsub_b(2) <= reg(6);
					addsub_op(2) <= '1'; addsub_dest(0) <= 17;
					
					addsub_a(3) <= reg(18);
					addsub_b(3) <= reg(5);
					addsub_op(3) <= '0'; addsub_dest(0) <= 18;
					addsub_nd <= "1111";
					
					
				when 33 =>
					mul_a(0) <= reg(15);
					mul_b(0) <= reg(15);
					mul_dest(0) <= 0;
					
					mul_a(1) <= reg(16);
					mul_b(1) <= reg(16);
					mul_dest(1) <= 1;
					
					mul_a(2) <= reg(17);
					mul_b(2) <= reg(17);
					mul_dest(2) <= 2;
					
					mul_a(3) <= reg(18);
					mul_b(3) <= reg(18);
					mul_dest(3) <= 3;
					mul_nd <= "1111";
				
				
				when 34 =>
					addsub_a(0) <= reg(0);
					addsub_b(0) <= reg(1);
					addsub_op(0) <= '0'; addsub_dest(0) <= 0;
				
					addsub_a(1) <= reg(2);
					addsub_b(1) <= reg(3);
					addsub_op(1) <= '0'; addsub_dest(0) <= 2;
					addsub_nd(1 downto 0) <= "11";
					
					
				when 35 =>
					addsub_a(0) <= reg(0);
					addsub_b(0) <= reg(2);
					addsub_op(0) <= '0'; addsub_dest(0) <= 1;
					addsub_nd(0) <= '1';
					
				
				when 36 =>
					invsqrt_in <= reg(1);
					invsqrt_dest <= 1;
					invsqrt_nd <= '1';
					
					
				when 37 =>
					mul_a(0) <= reg(15);
					mul_b(0) <= reg(1);
					mul_dest(0) <= 15;
					
					mul_a(1) <= reg(16);
					mul_b(1) <= reg(1);
					mul_dest(1) <= 16;
					
					mul_a(2) <= reg(17);
					mul_b(2) <= reg(1);
					mul_dest(2) <= 17;
					
					mul_a(3) <= reg(18);
					mul_b(3) <= reg(1);
					mul_dest(3) <= 18;
					mul_nd <= "1111";
				
					
				when others =>
					f2f_nd <= "000";
					addsub_nd <= "0000";
					mul_nd <= "0000";
					invsqrt_nd <= '0';
					sqrt_nd <= '0';
					mov_nd <= "0000";
	
			end case;
			
		else
			f2f_nd <= "000";
			addsub_nd <= "0000";
			mul_nd <= "0000";
			invsqrt_nd <= '0';
			sqrt_nd <= '0';		
		end if;
	end process;

end Behavioral;

--Addsub, mult, fixed-to-float have latency of 5
--sqrt and div have latency of 20
--sin/cos lut has latency of 7
--arctan has latency of 22
--invsqrt has latency of 26

