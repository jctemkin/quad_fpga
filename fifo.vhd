library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity fifo is
	generic (
		data_len: positive := 8;
		num_entries: positive := 8);
	port ( 
		data_in: in  STD_LOGIC_VECTOR ((data_len - 1) downto 0);
		data_out: out  STD_LOGIC_VECTOR ((data_len - 1) downto 0);
		rd_en: in  STD_LOGIC;
		wr_en: in  STD_LOGIC;
		clk: in std_logic;
		full: out  STD_LOGIC;
		empty: out  STD_LOGIC);
end fifo;

architecture Behavioral of fifo is

	type register_type is array(0 to num_entries) of std_logic_vector((data_len - 1) downto 0);
	signal regs: register_type := (others => (others => '0'));
	
	signal head_ptr: integer range (0 to (num_entries - 1)) := 0;
	signal tail_ptr: integer range (0 to (num_entries - 1)) := 0;
	
	signal full_reg: std_logic := 0;
	signal empty_reg: std_logic := 1;
	signal data_out_reg: std_logic_vector((data_len - 1) downto 0);
	

begin

	process(clk)
	begin
		if rising_edge(clk) then
			
			if rd_en = '1' then
				if full_reg = 
			
			end if;
			if wr_en = '1' then
			
			end if;
			
		end if;

	end process;
	
	
	
end Behavioral;

