library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity reg_tb is
end reg_tb;

architecture behav of reg_tb is
--  Declaration of the component that will be instantiated.
component reg
port(	I:	in std_logic_vector (7 downto 0);
		clk:	in std_logic;
		O:	out std_logic_vector(7 downto 0)
);
end component;
--  Specifies which entity is bound with the component.
signal i, o : std_logic_vector(7 downto 0);
signal clk : std_logic;
begin
--  Component instantiation.
reg1: reg port map (I => i, clk => clk, O => o);

--  This process does the real job.
process
type pattern_type is record
--  The inputs of the shift_reg.
i, o: std_logic_vector (7 downto 0);
clk: std_logic;
end record;
--  The patterns to apply.
type pattern_array is array (natural range <>) of pattern_type;
constant patterns : pattern_array := -- Order goes: Upper, Lower, Output, Overflow, Underflow, Select
(("00000000", "00000000", '0'), --test both initialized to 0
("00000001", "00000001", '1')); --both get 1
begin
--  Check each pattern.
for n in patterns'range loop
--  Set the inputs.
i <= patterns(n).i;
clk <= patterns(n).clk;
--  Wait for the results.
wait for 1 ns;
--  Check the outputs.
assert o = patterns(n).o
report "bad output value" severity error;
end loop;
assert false report "end of test" severity note;
--  Wait forever; this will finish the simulation.
wait;
end process;
end behav;
