library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity reg_file is
	generic (
		addr_len: positive := 8;
		data_len: positive := 8);
	port (
		rd_addr : in  STD_LOGIC_VECTOR ((addr_len - 1) downto 0);
		rd_en: in std_logic;
		wr_addr : in  STD_LOGIC_VECTOR ((addr_len - 1) downto 0);
		wr_data : in  STD_LOGIC_VECTOR ((data_len - 1) downto 0);
		wr_en: in std_logic;
		clk : in  STD_LOGIC;		
		rd_data : out  STD_LOGIC_VECTOR ((data_len - 1) downto 0);
		
		--Asynchronous read
		rd_addr_a:	in STD_LOGIC_VECTOR((addr_len - 1) downto 0);
		rd_data_a:	out STD_LOGIC_VECTOR((data_len - 1) downto 0)
	);
end reg_file;

architecture Behavioral of reg_file is

	type register_type is array(0 to ((2 ** addr_len) - 1)) of std_logic_vector((data_len - 1) downto 0);
	signal regs: register_type := (0=>X"FF", 1=>X"FF", 2=>X"FF", 3=>X"FF", others => (others => '0'));
	
	signal rd_data_reg: std_logic_vector((data_len - 1) downto 0) := (others => '0');


begin

	process (clk)
	begin
		if rising_edge(clk) then
			if rd_en = '1' then
				rd_data_reg <= regs(to_integer(unsigned(rd_addr)));
			end if;
			
			if wr_en = '1' then
				regs(to_integer(unsigned(wr_addr))) <= wr_data;
			end if;
		end if;
		
	end process;
	
	rd_data <= rd_data_reg;
	rd_data_a <= regs(to_integer(unsigned(rd_addr_a)));
	

end Behavioral;

