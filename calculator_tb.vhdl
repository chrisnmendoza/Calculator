library ieee;
use ieee.std_logic_1164.all;

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
signal i: std_logic_vector(7 downto 0);
signal clock: std_logic;
begin
--  Component instantiation.
calculator1 : calculator port map(I => I, clk => clock);

--  This process does the real job.
process
type pattern_type is record
--  The inputs of the shift_reg.
i: std_logic_vector(7 downto 0);
clock: std_logic;
end record;
--  The patterns to apply.
type pattern_array is array (natural range <>) of pattern_type; --let clock period = 4ns
constant patterns : pattern_array := -- Order goes: Input address rs1,rs2,ws ; input data rd1,rd2,wd ; we clk
(
("01000010", '0'), --nothing happens on falling edge
("01000010", '0'),
("01000010", '1'), --set r1 to 0010
("01000111", '1'), --can't edit registers on falling edge
("01000111", '0'),
("00000000", '0'),
("00000000", '1'), --add r1 and r1 to r1 (0010 + 0010 = 0100)
("01011010", '1'), --instruction at non-rising edge will be buffered to next clock cycle (if instruction is held)
("01011010", '0'),
("01011010", '0'),
("01011010", '1'), --set r2 to 1010
("01000111", '1'),
("00000000", '0'), --rapid changes when clock = 0 has no effect
("01100001", '0'),
("01100001", '1'), --set r3 to 0001
("01100001", '1'),
("00001001", '0'), 
("00001001", '0'),
("00001001", '1'), --add r1 and r3 and put it in r2 (0100 + 0001 = 0101)
("01000011", '1'),
("01000011", '0'),
("01110111", '0'),
("01110111", '1'), --set r4 to 0111
("01101011", '1')); 
begin
--  Check each pattern.
for n in patterns'range loop
--  Set the inputs.
i <= patterns(n).i;
clock <= patterns(n).clock;

--  Wait for the results.
wait for 1 ns;
--  Check the outputs.
end loop;
assert false report "end of test" severity note;
--  Wait forever; this will finish the simulation.
wait;
end process;
end behav;
