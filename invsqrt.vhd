library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity invsqrt is
	port ( 
		x : in  STD_LOGIC_VECTOR (31 downto 0);
		clk: in std_logic;
		start: in std_logic;
		data_ready: out std_logic := '0';
		result : out  STD_LOGIC_VECTOR (31 downto 0)
	);
end invsqrt;

architecture Behavioral of invsqrt is

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


	constant threehalfs: std_logic_vector(31 downto 0) := X"3FC00000";
	constant half: std_logic_vector(31 downto 0) := X"3F000000";
	constant magic: signed(31 downto 0) := X"5F375A86"; --See Chris Lomont's paper on Fast Inverse Square Root for derivation.

	signal mul_a1, mul_a2, sub_a, mul_b1, mul_b2, sub_b: std_logic_vector(31 downto 0) := X"00000000";
	signal mul_result1, mul_result2, sub_result: std_logic_vector(31 downto 0);
	signal mul_rdy1, mul_rdy2, sub_rdy: std_logic;
	signal mul_nd1, mul_nd2, sub_nd, sclr: std_logic := '0';
	signal ce: std_logic := '1';


	signal halfx: std_logic_vector(31 downto 0);
	signal x_reg: std_logic_vector(31 downto 0);
	signal state, next_state: std_logic_vector(3 downto 0) := X"0";

begin


	mult_1: float_mult
		port map (
			a => mul_a1,
			b => mul_b1,
			operation_nd => mul_nd1,
			clk => clk,
			sclr => sclr,
			ce => ce,
			result => mul_result1,
			rdy => mul_rdy1
		);

	mult_2: float_mult
		port map (
			a => mul_a2,
			b => mul_b2,
			operation_nd => mul_nd2,
			clk => clk,
			sclr => sclr,
			ce => ce,
			result => mul_result2,
			rdy => mul_rdy2
		);
		
	sub_1: float_addsub
		port map (
			a => sub_a,
			b => sub_b,
			operation => "000001",
			operation_nd => sub_nd,
			clk => clk,
			sclr => sclr,
			ce => ce,
			result => sub_result,
			rdy => sub_rdy
		);


	process (clk)
	begin
		if rising_edge(clk) then
			state <= next_state;
		end if;
	
	end process;

	process(state, start, mul_rdy1, mul_rdy2, sub_rdy)
	begin
	
		case state is
			
			when X"0" =>
				data_ready <= '0';
				mul_nd1 <= '0';
				mul_nd2 <= '0';
				sub_nd <= '0';
				sclr <= '0';
				ce <= '1';
				x_reg <= std_logic_vector(magic - signed('0' & x(31 downto 1)));
				
				if start = '1' then
					next_state <= X"1";
				else
					next_state <= X"0";
				end if;
			
			
			when X"1" =>
				data_ready <= '0';
				--x * 0.5
				mul_nd1 <= '1';
				mul_a1 <= x;
				mul_b1 <= half;
				
				--y^2
				mul_nd2 <= '1';
				mul_a2 <= x_reg;
				mul_b2 <= x_reg;
				
				next_state <= X"2";
				
			when X"2" =>
				mul_nd1 <= '0';
				mul_nd2 <= '0';
				
				if mul_rdy1 = '1' AND mul_rdy2 = '1' then
					next_state <= X"3";
				else
					next_state <= X"2";
				end if;
			
			
			when X"3" =>
				--0.5x * y^2
				mul_nd1 <= '1';
				mul_a1 <= mul_result1;
				mul_b1 <= mul_result2;
				
				next_state <= X"4";
			
			
			when X"4" =>
				mul_nd1 <= '0';
				
				if mul_rdy1 = '1' then
					next_state <= X"5";
				else
					next_state <= X"4";
				end if;
			
			
			when X"5" =>
				--1.5 - 0.5xy^2
				sub_nd <= '1';
				sub_a <= threehalfs;
				sub_b <= mul_result1;
				
				next_state <= X"6";
				
				
			when X"6" =>
				sub_nd <= '0';
				
				if sub_rdy = '1' then
					next_state <= X"7";
				else
					next_state <= X"6";
				end if;
				
				
			when X"7" =>
				--y * (1.5 - 0.5xy^2)
				mul_nd1 <= '1';
				mul_a1 <= x_reg;
				mul_b1 <= sub_result;
				
				next_state <= X"8";
				
				
			when X"8" =>
				mul_nd1 <= '0';
				
				if mul_rdy1 = '1' then
					next_state <= X"9";
				else
					next_state <= X"8";
				end if;
				
				
			when X"9" =>
				result <= mul_result1;
				data_ready <= '1';
				
				next_state <= X"0";
			
			when others =>
				next_state <= X"0";
				
		end case;
			
	
	end process;



end Behavioral;

