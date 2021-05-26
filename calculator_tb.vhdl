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
--The instructionFile located at instructions.txt contains the instructions:
--01000010   set reg1 to 2
--10000001   skip 1 line if reg1 == reg1 (true) (2 == 2)
--01000111   set reg1 to 7
--00000000   set reg1 to reg1 + reg1 (2 + 2 = 4)
--01110100   set reg4 to 4
--10000111   print reg1 (4)
--10000010   skip 2 lines if reg1 == reg4 (true) (4 = 4)
--10000011   print reg1 (4) (skipped)
--01000011   set reg1 to 3 (skipped)
--10001001   skip 1 line if reg1 == reg3 (false) (4 != 0)
--10010011   print reg2 (0)
--01101010   set reg3 to -6
--00101010   add reg3 to reg3 and put in reg3 (-6 + (-6) = -12)
--11001001   subtract reg3 from reg1 and put in reg1 (4 - (-12) = 16)
--10100011   print reg3 (-12)
--10010011   print reg1 (16)
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
