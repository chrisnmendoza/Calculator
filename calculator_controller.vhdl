library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity calculator_controller is 
    port( --opcode key: calculator controller relies on opfield and alu eq output of main alu
        opCode, imm: in std_logic_vector(1 downto 0);
        equals: in std_logic;
        rType, printing, branchConfirm: out std_logic
    );
end entity calculator_controller;

architecture behavioral of calculator_controller is
begin
    rType <= (opCode(1) and opCode(0)) or (not opCode(1) and not opCode(0));

    branchConfirm <= equals and (imm(1) xor imm(0));

    printing <= (opCode(1) and not opCode(0)) and (imm(1) and imm(0)); -- printing means opcode 10 and immediate 11
end architecture behavioral;