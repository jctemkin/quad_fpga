library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_receiver is
    Port ( sck : in  STD_LOGIC;
           cs : in  STD_LOGIC;
			  rst: in STD_LOGIC;
			  clk: in STD_LOGIC;	--must be at least twice sck
           data_in : in STD_LOGIC;
           data_ready : out STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (7 downto 0));
end spi_receiver;

architecture Behavioral of spi_receiver is


	type SPI_STATE is(
		S_IDLE,
		S_RECEIVING,
		S_COMPLETE);
		
	signal data_reg: std_logic_vector(7 downto 0);
	signal data_shift_reg: std_logic_vector(7 downto 0);
	signal data_ready_reg: std_logic;
	signal bits_received: integer range 0 to 15;
	signal state: SPI_STATE := S_IDLE;
	signal next_state: SPI_STATE := S_IDLE;
	signal last_sck: std_logic;
	

begin

	process (clk, rst)
	begin
		if rst then
			data_reg <= 0;
			bits_received <= 0;
		elsif rising_edge(clk) then



	process (clk, rst)
	begin
	
		if (rst) then
			data_reg <= 0;
			state <= S_IDLE;
		elsif rising_edge(clk) then
			state <= next_state;
			
			-- State machine effects
			case (state) is
				when S_IDLE =>
					bits_received := 0;
				when S_RECEIVING =>
					if (last_sck = '0' and sck = '1') then
						data_shift_reg := data_shift_reg(6 downto 0) & data_in;
						bits_received := bits_received + 1;
					else
						data_shift_reg := data_shift_reg;
						bits_received := bits_received;
					end if;
				when S_COMPLETE =>
					data_ready_reg := '1';
					data_reg := data_shift_reg;
			end case;
				
			-- Save the last state of sck
			last_sck <= sck;
			
		end if;
		
	end process;
	
	
	-- Next state equations
	process(state, cs, bits_received, rst)
	begin
		if rst then
			next_state <= S_IDLE;
		else
			case(state) is
				when S_IDLE =>
					if cs then
						next_state <= S_RECEIVING;
					else
						next_state <= S_IDLE;
					end if;
				when S_RECEIVING =>
					if bits_received = "8" then
						next_state <= S_COMPLETE;
					elsif not cs then
						next_state <= S_IDLE;
					else
						next_state <= S_RECEIVING;
					end if;
				when S_COMPLETE =>
					next_state <= S_IDLE;
			end case;
		end if;
	end process;
	
	
	data_ready <= data_ready_reg;
	data_out <= data_reg;
	
	
	
end Behavioral;

