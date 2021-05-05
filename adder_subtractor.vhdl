library ieee;
use ieee.std_logic_1164.all;

entity adder_subtractor is
port(	upperInput: in std_logic_vector (3 downto 0);
        lowerInput: in std_logic_vector (3 downto 0); --this input gets inverted for a subtraction
		O:	out std_logic_vector(3 downto 0); -- output
        overflow: out std_logic; --1 signifies overflow
        underflow: out std_logic; --1 signifies underflow
        sel: in std_logic -- 0 signifies addition, 1 signifies subtraction. when subtracting, lowerInput gets inverted
);
end adder_subtractor;

architecture behav of adder_subtractor is
    signal lowerModifiedInput : std_logic_vector(3 downto 0);  --the possibly inverted version of lowerInput
    signal carry : std_logic_vector(4 downto 0); --this is the carry-in and carry-out
begin
    process(upperInput, lowerInput, sel, carry, lowerModifiedInput) is
    begin
        lowerModifiedInput(0) <= lowerInput(0) xor sel; --xor sel will successfully invert if sel == 1 (subtraction)
        lowerModifiedInput(1) <= lowerInput(1) xor sel;
        lowerModifiedInput(2) <= lowerInput(2) xor sel;
        lowerModifiedInput(3) <= lowerInput(3) xor sel;
        carry(0) <= sel; --when sel == 1 this signifies subtraction, and according to 2's complement must add 1 to LSB
        carry(3 downto 1) <= ((upperInput(2 downto 0) and carry(2 downto 0)) or (upperInput(2 downto 0) and lowerModifiedInput(2 downto 0))) or (lowerModifiedInput(2 downto 0) and carry(2 downto 0));
        carry(4) <= (upperInput(3) xor lowerModifiedInput(3)) xor carry(3);	--this carry 4 will be used to check overflow/underflow, this is the same as O(3)
        O <= (upperInput xor lowerModifiedInput) xor carry(3 downto 0);
        overflow <= (not (upperInput(3) xor lowerModifiedInput(3))) and (carry(4)) and (upperInput(3) xor carry(4));
        underflow <= (not (upperInput(3) xor lowerModifiedInput(3))) and (not carry(4)) and (upperInput(3) xor carry(4));
    end process;
end behav;

