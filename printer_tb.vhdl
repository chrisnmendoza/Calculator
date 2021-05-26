library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity printer_tb is
end printer_tb;

architecture behav of printer_tb is
--  Declaration of the component that will be instantiated.
component printer
port(	I: in std_logic_vector(7 downto 0);
        en: in std_logic;
        clk: in std_logic
);
end component;
--  Specifies which entity is bound with the component.
signal I : std_logic_vector(7 downto 0);
signal en, clk : std_logic;
begin
--  Component instantiation.
printer1: printer port map (I => I, en => en, clk => clk);

--  This process does the real job.
process
type pattern_type is record
--  The inputs of the shift_reg.
I : std_logic_vector(7 downto 0);
en, clk : std_logic;
end record;
--  The patterns to apply.
type pattern_array is array (natural range <>) of pattern_type; --let clock have period 4ns
constant patterns : pattern_array := -- Order goes: I, en, clk
(("00000111", '1', '1'), --print 7
 ("01111111", '1', '0'), --won't print on falling edge
 ("00000001", '0', '1'),  --won't print when enable = '0'
 ("00000111", '1', '0'),
 ("11111111", '1', '1')  --print -1
); --clock enable = 0, won't write to register
begin
--  Check each pattern.
for n in patterns'range loop
--  Set the inputs.
I <= patterns(n).I;
en <= patterns(n).en;
clk <= patterns(n).clk;

--  Wait for the results.
wait for 1 ns;
end loop;
assert false report "end of test" severity note;
--  Wait forever; this will finish the simulation.
wait;
end process;
end behav;
