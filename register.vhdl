library ieee;
use ieee.std_logic_1164.all;

entity register is
port(	I:	in std_logic_vector (7 downto 0);
		clk:	in std_logic;
		O:	out std_logic_vector(7 downto 0)
);
end register;

architecture behav of register is
begin
process(clk) is
begin
	if(clk='1' and clk'event) then:
		O <= I;
	end if;
end process;
end behav;

