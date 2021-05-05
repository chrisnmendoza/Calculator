library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity shift_reg_tb is
end shift_reg_tb;

architecture behav of shift_reg_tb is
--  Declaration of the component that will be instantiated.
component shift_reg
port (	I:	in std_logic_vector (3 downto 0);
		I_SHIFT_IN: in std_logic;
		sel:        in std_logic_vector(1 downto 0); -- 00:hold; 01: shift left; 10: shift right; 11: load
		clock:		in std_logic; 
		enable:		in std_logic;
		O:	out std_logic_vector(3 downto 0)
);
end component;
--  Specifies which entity is bound with the component.
-- for shift_reg_0: shift_reg use entity work.shift_reg(rtl);
signal i, o : std_logic_vector(3 downto 0);
signal i_shift_in, clk, enable : std_logic;
signal sel : std_logic_vector(1 downto 0);
begin
--  Component instantiation.
shift_reg_0: shift_reg port map (I => i, I_SHIFT_IN => i_shift_in, sel => sel, clock => clk, enable => enable, O => o);

--  This process does the real job.
process
type pattern_type is record
--  The inputs of the shift_reg.
i: std_logic_vector (3 downto 0);
i_shift_in, clock, enable: std_logic;
sel: std_logic_vector(1 downto 0);
--  The expected outputs of the shift_reg.
o: std_logic_vector (3 downto 0);
end record;
--  The patterns to apply.
type pattern_array is array (natural range <>) of pattern_type;
constant patterns : pattern_array := --WRONG test vectors. replace with your own.

(("0100", '0', '1', '1', "11", "0100"), --Test needs rising edge to react
("0100", '0', '0', '1', "11", "0100"), 
("0000", '0', '1', '1', "11", "0000"),--Load test
("0000", '0', '0', '1', "11", "0000"),
("1111", '0', '1', '0', "11", "0000"),--enable bit = 0, do nothing (load)
("1111", '0', '0', '0', "11", "0000"),
("0000", '1', '1', '1', "10", "1000"),
("0000", '1', '0', '1', "10", "1000"),
("1111", '1', '1', '1', "10", "1100"), --continued right shift test (fill bit = 1)
("1111", '1', '0', '1', "10", "1100"),
("1111", '1', '1', '0', "10", "1100"), --enable bit = 0, do nothing (right shift fill bit = 1)
("1111", '1', '0', '0', "10", "1100"),
("0000", '0', '1', '1', "10", "0110"), --continued right shift test (fill bit = 0)
("0000", '0', '0', '1', "10", "0110"),
("1111", '0', '1', '1', "10", "0011"), 
("1111", '0', '0', '1', "10", "0011"),
("1111", '0', '1', '0', "10", "0011"), --enable bit = 0, do nothing (right shift fill bit = 0)
("1111", '0', '0', '0', "10", "0011"),
("0000", '0', '1', '1', "10", "0001"),
("0000", '0', '0', '1', "10", "0001"),
("1111", '0', '1', '1', "10", "0000"),
("1111", '0', '0', '1', "10", "0000"),
("0100", '0', '1', '1', "11", "0100"),
("0100", '0', '0', '1', "11", "0100"),
("0100", '0', '1', '1', "00", "0100"),  --hold test 
("0100", '0', '0', '1', "11", "0100"),
("0100", '0', '1', '0', "00", "0100"),  --hold test with enable set to 0, do nothing
("0100", '0', '0', '0', "11", "0100"),
("0100", '1', '1', '1', "10", "1010"),
("0100", '1', '0', '1', "10", "1010"),
("0100", '1', '1', '0', "10", "1010"), --enable bit = 0, do nothing (right shift fill bit = 1)
("0100", '1', '0', '0', "10", "1010"),
("0110", '1', '1', '1', "10", "1101"),
("0110", '1', '0', '1', "10", "1101"),
("1111", '1', '1', '1', "11", "1111"),
("1111", '1', '0', '1', "11", "1111"),
("1111", '0', '1', '1', "01", "1110"), --continued left shift test (fill bit = 0)
("1111", '0', '0', '1', "01", "1110"),
("1111", '0', '1', '0', "01", "1110"), --enable bit = 0, do nothing (left shift fill bit = 0)
("1111", '0', '0', '0', "01", "1110"),
("1111", '1', '1', '1', "01", "1101"), --continued left shift test (fill bit = 1)
("1111", '1', '0', '1', "01", "1101"),
("1111", '1', '1', '0', "01", "1101"), --enable bit = 0, do nothing (left shift fill bit = 1)
("1111", '1', '0', '0', "01", "1101"),
("1110", '0', '1', '1', "11", "1110"),
("1110", '0', '0', '1', "11", "1110"),
("1100", '0', '1', '1', "11", "1100"),
("1100", '0', '0', '1', "11", "1100"),
("1100", '0', '1', '1', "10", "0110"), --more right shift testing
("1100", '0', '0', '1', "10", "0110"),
("1110", '0', '1', '1', "10", "0011"),
("1110", '0', '0', '1', "10", "0011"),
("1100", '0', '1', '1', "10", "0001"),
("1100", '0', '0', '1', "10", "0001"),
("1111", '1', '1', '1', "11", "1111")); -- Need two vectors to simulate an edge.
begin
--  Check each pattern.
for n in patterns'range loop
--  Set the inputs.
i <= patterns(n).i;
i_shift_in <= patterns(n).i_shift_in;
sel <= patterns(n).sel;
clk <= patterns(n).clock;
enable <= patterns(n).enable;
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
