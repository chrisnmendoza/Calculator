library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity mux_tb is
end mux_tb;

architecture behav of mux_tb is
--  Declaration of the component that will be instantiated.
signal i1, i2, i3, i4, o : std_logic_vector(3 downto 0);
signal sel : std_logic_vector(1 downto 0);
component mux
generic (n: positive:=4);
port (	In1:	in std_logic_vector ((n-1) downto 0);
        In2:	in std_logic_vector ((n-1) downto 0);
        In3:	in std_logic_vector ((n-1) downto 0);
        In4:	in std_logic_vector ((n-1) downto 0);
		sel:        in std_logic_vector(1 downto 0);
		O:	out std_logic_vector((n-1) downto 0)
);
end component;
--  Specifies which entity is bound with the component.
-- for shift_reg_0: shift_reg use entity work.shift_reg(rtl);

begin
--  Component instantiation.

testMux: mux
generic map (n => 4)
port map (In1 => i1, In2 => i2, In3 => i3,In4 => i4, sel => sel, O => o);

--  This process does the real job.
process
type pattern_type is record -- pattern record follows: ("i1", "i2", "i3", "i4", "sel", "o")
--  The inputs of the shift_reg.
i1, i2, i3, i4: std_logic_vector (3 downto 0);
sel: std_logic_vector(1 downto 0);
--  The expected outputs of the shift_reg.
o: std_logic_vector (3 downto 0);
end record;
--  The patterns to apply.
type pattern_array is array (natural range <>) of pattern_type;
constant patterns : pattern_array :=
(("0001", "0010", "0100", "1000", "10", "0100"),
("0001", "0010", "0100", "1000", "00", "0001"),
("0000", "1010", "1001", "1110", "01", "1010"),
("0111", "1000", "1111", "1001", "11", "1001")); -- pattern 1 selects i3 which is "0100", pattern 2 selects i1 which is "0001", pattern 3 selects i2 which is "1010", pattern 4 selects i4 which is "1001"
begin
--  Check each pattern.
for p in patterns'range loop
--  Set the inputs.
i1 <= patterns(p).i1;
i2 <= patterns(p).i2;
i3 <= patterns(p).i3;
i4 <= patterns(p).i4;
sel <= patterns(p).sel;
--  Wait for the results.
wait for 1 ns;
--  Check the outputs.
assert o = patterns(p).o
report "bad output value" severity error;
end loop;
assert false report "end of test" severity note;
--  Wait forever; this will finish the simulation.
wait;
end process;
end behav;
