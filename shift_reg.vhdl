library ieee;
use ieee.std_logic_1164.all;

entity shift_reg is
port(	I:	in std_logic_vector (3 downto 0); -- for loading
		I_SHIFT_IN: in std_logic; -- shifted in bit for both left and right
		sel:        in std_logic_vector(1 downto 0); -- 00:hold; 01: shift left; 10: shift right; 11: load
		clock:		in std_logic; -- positive level triggering in problem 3
		enable:		in std_logic; -- 0: don't do anything; 1: shift_reg is enabled
		O:	out std_logic_vector(3 downto 0) -- output the current register content. HINT: should be combinational.
		-- SHIFT_OUT : out std_logic;
);
end shift_reg;

architecture behav of shift_reg is
signal values : std_logic_vector (3 downto 0);	--saved values before it gets loaded into O
begin

process(clock) is
begin
	if (clock='1' and enable='1') then
		if (sel="00") then
			-- do nothing
			O(3) <= values(3);
			O(2) <= values(2);
			O(1) <= values(1);
			O(0) <= values(0);
		
		elsif (sel ="01") then    --left shift
			O(3) <= values(2);
			O(2) <= values(1);
			O(1) <= values(0);
			O(0) <= I_SHIFT_IN;
			values(3) <= values(2);
			values(2) <= values(1);
			values(1) <= values(0);
			values(0) <= I_SHIFT_IN;

		elsif (sel="10") then   --right shift
			O(3) <= I_SHIFT_IN;
			O(2) <= values(3);
			O(1) <= values(2);
			O(0) <= values(1);
			values(0) <= values(1);
			values(1) <= values(2);
			values(2) <= values(3);
			values(3) <= I_SHIFT_IN;
		
		elsif (sel="11") then
			O(3) <= I(3);
			O(2) <= I(2);
			O(1) <= I(1);
			O(0) <= I(0);
			values(0) <= I(0);
			values(1) <= I(1);
			values(2) <= I(2);
			values(3) <= I(3);
		end if;
		
		
	end if;
end process;

end behav;

