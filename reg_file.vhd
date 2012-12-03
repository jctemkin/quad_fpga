library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Regs 0x00-0x7F writeable by SPI, regs 0x80-0xFF writeable by FPGA.
-- FPGA has read access to all regs, SPI has read access only to regs 0x80-0xFF.

entity reg_file is
	generic (
		addr_len: positive := 8;
		data_len: positive := 16;
		writers: positive := 2
	);
	port (
		reg_read: out std_logic_vector((((2 ** addr_len) * data_len) - 1) downto 0);

		write_data: in std_logic_vector(((writers * data_len) - 1) downto 0);
		write_addr: in std_logic_vector(((writers * addr_len) - 1) downto 0);
		write_en: in std_logic_vector((writers - 1) downto 0);
		clk : in  STD_LOGIC
	);
end reg_file;

architecture Behavioral of reg_file is

	type register_type is array(0 to ((2 ** addr_len) - 1)) of std_logic_vector((data_len - 1) downto 0);
	signal regs: register_type := (0 => (others => '1'), 1 => (others => '1'), 2 => (others => '1'), 3 => (others => '1'), 128 => X"ABCD", others => (others => '0'));


begin

	--Sequential
	write_proc: process (clk)
	begin
		if rising_edge(clk) then
			for i in 0 to (writers - 1) loop
				if write_en(i) = '1' then
					regs(to_integer(unsigned(write_addr))) <= write_data((((i + 1) * data_len) - 1) downto (i * data_len));
				end if;
			end loop;
		end if;
	end process;
	
	
	--Combinational
	read_proc: process (regs)
	begin
		for i in 0 to ((2 ** addr_len) - 1) loop
			reg_read ((((i + 1) * data_len) - 1) downto (i * data_len)) <= regs(i);
		end loop;
	end process;


end Behavioral;

