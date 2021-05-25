library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity calculator_controller_tb is
end calculator_controller_tb;

architecture behav of calculator_controller_tb is
--  Declaration of the component that will be instantiated.
component calculator_controller
    port( --opcode key: calculator controller relies on opfield and alu eq output of main alu
        opCode, imm: in std_logic_vector(1 downto 0);
        equals: in std_logic;
        rType, printing, branchConfirm: out std_logic
        );
end component;
--  Specifies which entity is bound with the component.
signal op, imm : std_logic_vector(1 downto 0);
signal eq, rType, printing, branchConfirm : std_logic;
begin
--  Component instantiation.
calc_controller: calculator_controller port map (opCode => op, imm => imm, equals => eq, rType => rType, printing => printing, branchConfirm => branchConfirm);

--  This process does the real job.
process
type pattern_type is record
--  The inputs of the shift_reg.
op, imm: std_logic_vector(1 downto 0);
eq, rType, printing, branchConfirm : std_logic;
end record;
--  The patterns to apply.
type pattern_array is array (natural range <>) of pattern_type;
constant patterns : pattern_array := -- Order goes: Upper, Lower, Output, Overflow, Underflow, Select
(
("00", "01", '0', '1', '0', '0'), --add instruction has rType = 1 and all other outputs = 0
("10", "10", '1', '0', '0', '1'), --a beq instruction where the alu eq output is 1 indicates we should branch
("10", "11", '1', '0', '1', '0'), --a beq instruction where immediate == 11 means it's a print, should not branch
("10", "01", '0', '0', '0', '0') --a beq instruction where the alu eq output is 0 indicates no branch
); --test 1 - 1 = 0
begin
--  Check each pattern.
for n in patterns'range loop
--  Set the inputs.
imm <= patterns(n).imm;
op <= patterns(n).op;
eq <= patterns(n).eq;
--  Wait for the results.
wait for 1 ns;
--  Check the outputs.
assert rType = patterns(n).rType
report "bad rType value" severity error;
assert printing = patterns(n).printing
report "bad printing value" severity error;
assert branchConfirm = patterns(n).branchConfirm
report "bad branchConfirm value" severity error;
end loop;
assert false report "end of test" severity note;
--  Wait forever; this will finish the simulation.
wait;
end process;
end behav;
