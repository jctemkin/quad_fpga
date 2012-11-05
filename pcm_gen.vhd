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

	signal pcm_count: integer range 0 to 2047 := 0;
	signal pulse_width_reg: std_logic_vector(9 downto 0) := (others => '0');

begin
	process (clk_1mhz)
	begin
		-- Generate PCM
		if rising_edge(clk_1mhz) then		
		
			if ((pcm_count < (1000 + pulse_width_reg)) AND (pcm_count < 1800)) OR (pcm_count < 1000) then
				pcm_out <= 1;
			else
				pcm_out <= 0;
			end if;
			
			-- Account for rollover
			if (pcm_count > 1999) then
				pcm_count <= 0;
				pulse_width_reg <= pulse_width;
			else
				pcm_count <= pcm_count + 1;
			end if;
			
		end if;
			
	end process;


end Behavioral;

