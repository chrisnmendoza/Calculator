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
type pattern_array is array (natural range <>) of pattern_type;
constant patterns : pattern_array := -- Order goes: Input address rs1,rs2,ws ; input data rd1,rd2,wd ; we clk
(("00000000", '0'),
("01010111", '1'),
("00000000", '0'),
("01001000", '1'),
("00000000", '0'),
("00000110", '1'),
("00000000", '0'),
("01000000", '1')); --clock enable = 0, won't write to register
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
