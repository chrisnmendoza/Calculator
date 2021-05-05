library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity alu_tb is
end alu_tb;

architecture behav of alu_tb is
--  Declaration of the component that will be instantiated.
component alu
port(	A:	in std_logic_vector (7 downto 0);
        B:	in std_logic_vector (7 downto 0);
		op: in std_logic_vector (1 downto 0); --00 = add, 01 = subtract, 10 = nothing, 11 = set on equal
		O:	out std_logic_vector(7 downto 0);
        EQ: out std_logic
);
end component;
--  Specifies which entity is bound with the component.
signal a, b, o : std_logic_vector(7 downto 0);
signal op : std_logic_vector(1 downto 0);
signal eq : std_logic;
begin
--  Component instantiation.
alu1: alu port map (A => a, B => b, op => op, O => o, EQ => eq);

--  This process does the real job.
process
type pattern_type is record
--  The inputs of the shift_reg.
a, b, o: std_logic_vector (7 downto 0);
op: std_logic_vector(1 downto 0);
eq: std_logic;
end record;
--  The patterns to apply.
type pattern_array is array (natural range <>) of pattern_type;
constant patterns : pattern_array := -- Order goes: Upper, Lower, Output, Overflow, Underflow, Select
(("00000001", "00000001", "00000010", "00", '0'), --test 1 + 1 = 2
("00000001", "00000001", "00000000", "01", '0')); --test 1 - 1 = 0
begin
--  Check each pattern.
for n in patterns'range loop
--  Set the inputs.
a <= patterns(n).a;
b <= patterns(n).b;
op <= patterns(n).op;
--  Wait for the results.
wait for 1 ns;
--  Check the outputs.
assert o = patterns(n).o
report "bad output value" severity error;
assert eq = patterns(n).eq
report "bad eq value" severity error;
end loop;
assert false report "end of test" severity note;
--  Wait forever; this will finish the simulation.
wait;
end process;
end behav;
