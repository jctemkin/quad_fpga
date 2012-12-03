library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity pcm_controller is
	Port ( 
		clk_100mhz : in std_logic;
		pw_in: in std_logic_vector(63 downto 0);
		pcm_out: out std_logic_vector(3 downto 0)
	);
end pcm_controller;

architecture Behavioral of pcm_controller is

	signal clk_1mhz_cnt: natural range 0 to 63 := 0;
	signal clk_1mhz: std_logic := '0';

begin

	pcms: for i in 0 to 3 generate
	begin
		pcm: entity work.pcm_gen(Behavioral)
			port map(
				pulse_width => pw_in(((i + 1) * 16) - 7 downto (i * 16)),
				clk_1mhz => clk_1mhz,
				pcm_out => pcm_out(i)
			);
	end generate pcms;


	clk_1mhz_proc: process(clk_100mhz)
	begin
		if rising_edge(clk_100mhz) then
			if clk_1mhz_cnt = 49 then
				clk_1mhz_cnt <= 0;
				clk_1mhz <= NOT clk_1mhz;
			else
				clk_1mhz_cnt <= clk_1mhz_cnt + 1;
			end if;
		end if;
	end process;

end Behavioral;

