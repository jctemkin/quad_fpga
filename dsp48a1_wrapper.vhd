----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:12:03 12/04/2012 
-- Design Name: 
-- Module Name:    dsp48a1_wrapper - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity dsp48a1_wrapper is
	port (
		--Fabric ports
		a: in std_logic_vector(17 downto 0);
		b: in std_logic_vector(17 downto 0);
		c: in std_logic_vector(47 downto 0);
		d: in std_logic_vector(17 downto 0);
		p: out std_logic_vector(47 downto 0);
		c_out: out std_logic;
		m: out std_logic_vector(35 downto 0);	--Output of pre-add and multiply
		
		--Cascade ports
		c_p_in: in std_logic_vector(47 downto 0);		--Input to post-adder
		c_p_out: out std_logic_vector(47 downto 0);	--Output of post-adder
		
		--Control ports
		rst: in std_logic;
		clk: in std_logic;
		clk_en: in std_logic;
		opmode: in std_logic_vector(7 downto 0)
	);
end dsp48a1_wrapper;

architecture Behavioral of dsp48a1_wrapper is

begin


	DSP48A1_inst : DSP48A1
		generic map (
			A0REG => 0,              -- First stage A input pipeline register (0/1)
			A1REG => 1,              -- Second stage A input pipeline register (0/1)
			B0REG => 0,              -- First stage B input pipeline register (0/1)
			B1REG => 1,              -- Second stage B input pipeline register (0/1)
			CARRYINREG => 0,         -- CARRYIN input pipeline register (0/1)
			CARRYINSEL => "OPMODE5", -- Specify carry-in source, "CARRYIN" or "OPMODE5" 
			CARRYOUTREG => 1,        -- CARRYOUT output pipeline register (0/1)
			CREG => 1,               -- C input pipeline register (0/1)
			DREG => 1,               -- D pre-adder input pipeline register (0/1)
			MREG => 1,               -- M pipeline register (0/1)
			OPMODEREG => 1,          -- Enable=1/disable=0 OPMODE input pipeline registers
			PREG => 1,					 -- P output pipeline register (0/1)
			RSTTYPE => "SYNC"        -- Specify reset type, "SYNC" or "ASYNC" 
		)
		port map (
			-- Cascade Ports: 18-bit (each) output: Ports to cascade from one DSP48 to another
			--BCOUT => BCOUT,           -- 18-bit output: B port cascade output
			PCOUT => c_p_out,           -- 48-bit output: P cascade output (if used, connect to PCIN of another DSP48A1)
			
			-- Data Ports: 1-bit (each) output: Data input and output ports
			--CARRYOUT => c_carry_out,     -- 1-bit output: carry output (if used, connect to CARRYIN pin of another DSP48A1)
			CARRYOUTF => c_out,   -- 1-bit output: fabric carry output
			M => m,                   -- 36-bit output: fabric multiplier data output
			P => p,                   -- 48-bit output: data output
			
			-- Cascade Ports: 48-bit (each) input: Ports to cascade from one DSP48 to another
			PCIN => c_p_in,             -- 48-bit input: P cascade input (if used, connect to PCOUT of another DSP48A1)
			
			-- Control Input Ports: 1-bit (each) input: Clocking and operation mode
			CLK => clk,               -- 1-bit input: clock input
			OPMODE => opmode,         -- 8-bit input: operation mode input
			
			-- Data Ports: 18-bit (each) input: Data input and output ports
			A => a,                   -- 18-bit input: A data input
			B => b,                   -- 18-bit input: B data input (connected to fabric or BCOUT of adjacent DSP48A1)
			C => c,                   -- 48-bit input: C data input
			--CARRYIN => c_carry_in,       -- 1-bit input: carry input signal (if used, connect to CARRYOUT pin of another DSP48A1)
			D => d,                   -- 18-bit input: B pre-adder data input
			
			-- Reset/Clock Enable Input Ports: 1-bit (each) input: Reset and enable input ports
			CEA => clk_en,               -- 1-bit input: active high clock enable input for A registers
			CEB => clk_en,               -- 1-bit input: active high clock enable input for B registers
			CEC => clk_en,               -- 1-bit input: active high clock enable input for C registers
			CECARRYIN => clk_en,		-- 1-bit input: active high clock enable input for CARRYIN registers
			CED => clk_en,               -- 1-bit input: active high clock enable input for D registers
			CEM => clk_en,               -- 1-bit input: active high clock enable input for multiplier registers
			CEOPMODE => clk_en,     -- 1-bit input: active high clock enable input for OPMODE registers
			CEP => clk_en,               -- 1-bit input: active high clock enable input for P registers
			RSTA => rst,             -- 1-bit input: reset input for A pipeline registers
			RSTB => rst,             -- 1-bit input: reset input for B pipeline registers
			RSTC => rst,             -- 1-bit input: reset input for C pipeline registers
			RSTCARRYIN => rst, -- 1-bit input: reset input for CARRYIN pipeline registers
			RSTD => rst,             -- 1-bit input: reset input for D pipeline registers
			RSTM => rst,             -- 1-bit input: reset input for M pipeline registers
			RSTOPMODE => rst,   -- 1-bit input: reset input for OPMODE pipeline registers
			RSTP => rst              -- 1-bit input: reset input for P pipeline registers
		);

end Behavioral;

