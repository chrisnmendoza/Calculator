library ieee;
use ieee.std_logic_1164.all;

entity registerFile is
port(	rs1:	in std_logic_vector (1 downto 0); -- for loading
		rs2: in std_logic_vector (1 downto 0); -- shifted in bit for both left and right
		clk:    in std_logic;
        ws:        in std_logic_vector(1 downto 0); -- write select
		wd:		in std_logic_vector(7 downto 0); -- write data
        we:		in std_logic; -- positive level triggering in problem 3
		rd1:		out std_logic_vector (7 downto 0); -- 0: don't do anything; 1: shift_reg is enabled
        rd2:		out std_logic_vector (7 downto 0)); -- 0: don't do anything; 1: shift_reg is enabled
);
end registerFile;


architecture behav of registerFile is

component register
port (	I:	in std_logic_vector (7 downto 0);
        clk:    in std_logic; 
        O:	out std_logic_vector(7 downto 0)
);
end component;

signal wd1: std_logic_vector(7 downto 0);
signal wd2: std_logic_vector(7 downto 0);
signal wd3: std_logic_vector(7 downto 0);
signal wd4: std_logic_vector(7 downto 0);
signal inshift0: std_logic;
signal inshift1: std_logic;
signal clockSig: std_logic;
begin

--  Component instantiation.
reg_1: register port map ( I => wd1, clk => clk, ); --left 4 bits
reg_2: register port map (I => I_8bit(3 downto 0), I_SHIFT_IN => inshift1, sel => sel_8bit, clock => clockSig, enable => enable_8bit, O => O_8bit(3 downto 0)); --right 4 bits
reg_3: register port map (I => I_8bit(7 downto 4), I_SHIFT_IN => inshift0, sel => sel_8bit, clock => clockSig, enable => enable_8bit, O => O_8bit(7 downto 4)); --left 4 bits
reg_4: register port map (I => I_8bit(3 downto 0), I_SHIFT_IN => inshift1, sel => sel_8bit, clock => clockSig, enable => enable_8bit, O => O_8bit(3 downto 0)); --right 4 bits

process(clk) is
begin

end process;

end behav;

