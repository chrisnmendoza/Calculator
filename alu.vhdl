library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
port(	A:	in std_logic_vector (7 downto 0);
        B:	in std_logic_vector (7 downto 0);
		op: in std_logic_vector (1 downto 0); --00 = add, 01 = subtract, 10 = nothing, 11 = set on equal
		O:	out std_logic_vector(7 downto 0);
        EQ: out std_logic
);
end alu;

architecture behav of alu is
begin
process(A, B, op) is
begin
    EQ <= '0';
	if(op = "00") then
        O <= std_logic_vector(signed(A) + signed(B));
    elsif(op = "01") then
        O <= std_logic_vector(signed(A) + signed(not B) + 1);
    elsif(op = "10") then

    else
        if(A = B) then
            EQ <= '1';
        else  
            EQ <= '0';
        end if;
    end if;
end process;
end behav;

