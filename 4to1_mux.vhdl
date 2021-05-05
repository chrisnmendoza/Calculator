library ieee;
use ieee.std_logic_1164.all;

entity mux is
generic(n: positive:=2);
port(	In1:	in std_logic_vector ((n-1) downto 0);
		In2:	in std_logic_vector ((n-1) downto 0);
		In3:	in std_logic_vector ((n-1) downto 0);
		In4:	in std_logic_vector ((n-1) downto 0);
		sel:        in std_logic_vector(1 downto 0);
		O:	out std_logic_vector((n-1) downto 0) -- output
		-- SHIFT_OUT : out std_logic;
);
end mux;

architecture behav of mux is
begin
process(In1, In2, In3, In4, sel) is
begin
	if (sel="00") then
		O <= In1;
	elsif (sel="01") then
		O <= In2;
	elsif (sel="10") then
		O <= In3;
	else
		O <= In4;
	end if;
end process;
		


end behav;

