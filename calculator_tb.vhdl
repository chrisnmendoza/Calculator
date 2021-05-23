library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

--  A testbench has no ports.
entity calculator_tb is
end calculator_tb;

architecture behav of calculator_tb is
--  Declaration of the component that will be instantiated.
component calculator
port(	I: in std_logic_vector(7 downto 0);
        clk: in std_logic
);
end component;
--  Specifies which entity is bound with the component.
signal I: std_logic_vector(7 downto 0);
signal clock: std_logic;
begin
--  Component instantiation.
calculator1 : calculator port map(I => I, clk => clock);

--  This process does the real job.
process
      file instructionFile : text is in "instructions.txt"; --Instructions in text(ASCII) file.
      variable vector : bit_vector(7 downto 0);
      variable lineNum : line;
    begin
      while (not(endfile(instructionFile))) loop --Loop to the end of the text file.
        clock <= '0';
        readline(instructionFile, lineNum); --Read instruction from file
        read(lineNum, vector); --Change to bit vector
        I <= to_stdlogicvector(vector); --change bitvector to std_logic_vector
        wait for 1 ns;
        clock <= '1';
        wait for 1 ns;
      end loop;
      wait;
    end process;
    end behav;
