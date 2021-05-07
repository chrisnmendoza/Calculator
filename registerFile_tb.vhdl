library ieee;
use ieee.std_logic_1164.all;

--  A testbench has no ports.
entity registerFile_tb is
end registerFile_tb;

architecture behav of registerFile_tb is
--  Declaration of the component that will be instantiated.
component registerFile
port(	rs1:	in std_logic_vector (1 downto 0); -- for loading addresses: 00 = register 1, 01 = register 2, 10 = register 3, 11 = register 4
		rs2: in std_logic_vector (1 downto 0); -- for loading addresses
		clk:    in std_logic;
        ws:        in std_logic_vector(1 downto 0); -- write selects address: 00 = register 1, 01 = register 2, 10 = register 3, 11 = register 4
		wd:		in std_logic_vector(7 downto 0); -- write data
        we:		in std_logic; -- positive level triggering in problem 3
		rd1:		out std_logic_vector (7 downto 0); -- 0: don't do anything; 1: shift_reg is enabled
        rd2:		out std_logic_vector (7 downto 0) -- 0: don't do anything; 1: shift_reg is enabled
);
end component;
--  Specifies which entity is bound with the component.
signal rs1, rs2, ws : std_logic_vector(1 downto 0);
signal rd1, rd2, wd : std_logic_vector(7 downto 0);
signal we, clk : std_logic;
begin
--  Component instantiation.
registerFile1: registerFile port map (rs1 => rs1, rs2 => rs2, clk => clk, ws => ws, wd => wd, we => we, rd1 => rd1, rd2 => rd2);

--  This process does the real job.
process
type pattern_type is record
--  The inputs of the shift_reg.
rs1, rs2, ws : std_logic_vector(1 downto 0);
rd1, rd2, wd : std_logic_vector(7 downto 0);
we, clk : std_logic;
end record;
--  The patterns to apply.
type pattern_array is array (natural range <>) of pattern_type;
constant patterns : pattern_array := -- Order goes: Input address rs1,rs2,ws ; input data rd1,rd2,wd ; we clk
(("00", "01", "00", "00000000","00000000","11111111",'1', '0'), --test nothing happens on clock falling edge
("00", "01", "00", "00000001","00000000","00000001",'1', '1'), --ws selects register1 and writes 00000001 to it
("00", "01", "00", "00000001","00000000","00000001",'0', '0'), --test nothing happens on clock falling edge
("00", "01", "00", "00000001","00000000","11111111",'0', '1'), --clock enable = 0, won't write to register
("00", "01", "00", "00000001","00000000","00000000",'0', '0'), --test nothing happens on clock falling edge
("10", "00", "10", "11111111","00000001","11111111",'1', '1'), --change what registers are at rs1 and rs2 and simultaneously change what's at rs1
("00", "01", "00", "11111111","00000001","00000000",'0', '0'), --test nothing happens on clock falling edge HOWEVER YOU ARE ABLE TO CHANGE WHAT RD AND RS IS
("00", "01", "00", "00001001","00000000","00001001",'1', '1'), --ws selects register1 and writes 00000001 to it
("00", "01", "00", "00001001","00000000","00001001",'0', '1')); --clock enable = 0, won't write to register
begin
--  Check each pattern.
for n in patterns'range loop
--  Set the inputs.
rs1 <= patterns(n).rs1;
rs2 <= patterns(n).rs2;
ws <= patterns(n).ws;
wd <= patterns(n).wd;
clk <= patterns(n).clk;
we <= patterns(n).we;

--  Wait for the results.
wait for 1 ns;
--  Check the outputs.
assert rd1 = patterns(n).rd1
report "bad output value rd1" severity error;
assert rd2 = patterns(n).rd2
report "bad output value rd2" severity error;
end loop;
assert false report "end of test" severity note;
--  Wait forever; this will finish the simulation.
wait;
end process;
end behav;
