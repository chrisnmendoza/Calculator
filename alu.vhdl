library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
port(	A:	in std_logic_vector (7 downto 0);
        B:	in std_logic_vector (7 downto 0);
		opField: in std_logic_vector (1 downto 0); --This corresponds to the opfield in the 8-bit ISA instruction
		O:	out std_logic_vector(7 downto 0);
        EQ: out std_logic
);
end alu;

architecture behav of alu is
signal temp: std_logic_vector(1 downto 0);
signal sum: std_logic_vector(7 downto 0);
begin
process(A, B, opField, temp, sum) is
begin
    temp(1) <= opField(1) xor opField(0);
    temp(0) <= (opField(1) and opField(0)) or (opField(1) and not opField(0));

    EQ <= '0';
	if(temp = "00") then
        sum <= std_logic_vector(signed(A) + signed(B));
        O <= sum;
    elsif(temp = "01") then
        sum <= std_logic_vector(signed(A) + signed(not B) + 1);
        O <= sum;
    elsif(temp = "10") then
       --O <= oPrev;
       --O <= A;
    else
        if(A = B) then
            EQ <= '1';
        else  
            EQ <= '0';
        end if;
    end if;
end process;
end behav;

