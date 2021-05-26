library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity calculator_controller is 
    port( --opcode key: calculator controller relies on opfield and alu eq output of main alu
        opCode, imm: in std_logic_vector(1 downto 0);
        equals: in std_logic;
        beqOutput: in std_logic_vector(7 downto 0);
        rType, printing, branchConfirm, writeEnable, noSkipPrint: out std_logic;
        regWriteSelector: out std_logic_vector (1 downto 0)
    );
end entity calculator_controller;

architecture behavioral of calculator_controller is
signal printing_sig: std_logic;
begin
    rType <= (opCode(1) and opCode(0)) or (not opCode(1) and not opCode(0));

    branchConfirm <= equals and (imm(1) xor imm(0));

    printing_sig <= (opCode(1) and not opCode(0)) and (imm(1) and imm(0)); -- printing means opcode 10 and immediate 11

    printing <= printing_sig;

    noSkipPrint <= printing_sig and (not beqOutput(1) and not beqOutput(0));

    writeEnable <= not(opCode(1) and not opCode(0)); --writeEnable = 1 for all except beq and print (opcode == 10)

    regWriteSelector <= ((opCode(1) and opCode(0)) or (not opCode(1) and not opCode(0))) & ((opCode(1) and not opCode(0)) and (imm(1) and imm(0))); --rType and printing
end architecture behavioral;