library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity pcm_gen is
	port(
		pulse_width : in  STD_LOGIC_VECTOR (9 downto 0);
		clk_1mhz : in  STD_LOGIC;
		pcm_out : out STD_LOGIC);
end pcm_gen;

architecture Behavioral of pcm_gen is

	signal pcm_out_reg: std_logic := '1';
	signal pcm_count: std_logic_vector(11 downto 0) := (others => '0');
	signal pulse_width_reg: std_logic_vector(11 downto 0) := X"3FF";

begin
	process (clk_1mhz)
	begin
		-- Generate PCM
		if rising_edge(clk_1mhz) then		
		
			--Kind of important: if pulse width = 0x03FF, output 0
			if (unsigned(pcm_count) < (1000 + unsigned(pulse_width_reg))) AND (unsigned(pcm_count) < 1800) AND (unsigned(pulse_width_reg) < 1023) then
				pcm_out_reg <= '1';
			else
				pcm_out_reg <= '0';
			end if;
			
			-- Account for rollover
			if (unsigned(pcm_count) > 1999) then
				pcm_count <= (others => '0');
				pulse_width_reg <= "00" & pulse_width;
			else
				pcm_count <= std_logic_vector(unsigned(pcm_count) + 1);
			end if;
			
		end if;
			
	end process;

	pcm_out <= pcm_out_reg;

end Behavioral;
