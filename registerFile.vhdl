library ieee;
use ieee.std_logic_1164.all;

entity registerFile is
port(	rs1:	in std_logic_vector (1 downto 0); -- for loading addresses: 00 = register 1, 01 = register 2, 10 = register 3, 11 = register 4
		rs2: in std_logic_vector (1 downto 0); -- for loading addresses
		clk:    in std_logic;
        ws:        in std_logic_vector(1 downto 0); -- write selects address: 00 = register 1, 01 = register 2, 10 = register 3, 11 = register 4
		wd:		in std_logic_vector(7 downto 0); -- write data
        we:		in std_logic; -- positive level triggering in problem 3
		rd1:		out std_logic_vector (7 downto 0) := "00000000"; -- 0: don't do anything; 1: shift_reg is enabled
        rd2:		out std_logic_vector (7 downto 0) := "00000000" -- 0: don't do anything; 1: shift_reg is enabled
);
end registerFile;


architecture behav of registerFile is

component reg
port (	I:	in std_logic_vector (7 downto 0) := "00000000";
        clk:    in std_logic; 
        O:	out std_logic_vector(7 downto 0) := "00000000"
);
end component;

signal i1: std_logic_vector(7 downto 0) := "00000000";
signal i2: std_logic_vector(7 downto 0) := "00000000";
signal i3: std_logic_vector(7 downto 0) := "00000000";
signal i4: std_logic_vector(7 downto 0) := "00000000";
signal o1: std_logic_vector(7 downto 0) := "00000000";
signal o2: std_logic_vector(7 downto 0) := "00000000";
signal o3: std_logic_vector(7 downto 0) := "00000000";
signal o4: std_logic_vector(7 downto 0) := "00000000";
signal clockSig: std_logic;
begin

--  Component instantiation.
reg_1: reg port map ( I => i1, clk => clockSig, O => o1); --left 4 bits
reg_2: reg port map ( I => i2, clk => clockSig, O => o2); --right 4 bits
reg_3: reg port map ( I => i3, clk => clockSig, O => o3); --right 4 bits
reg_4: reg port map ( I => i4, clk => clockSig, O => o4); --right 4 bits

process(clk) is
begin
    if(clk='1' and clk'event) then
        if(we='1') then
            if(ws="00") then --set i2 to wd
                i1 <= wd;
            elsif(ws="01") then --set i2 to wd
               i2 <= wd;
            elsif(ws="10") then --set i3 to wd
                i3 <= wd;
            else --set i4 to wd
                i4 <= wd;
            end if;
        end if;

    end if;
    clockSig <= clk;

end process;

process(o1, o2, o3, o4) is
begin
    if(clk='1') then
        if(rs1="00") then --rd1 should output register 1 
        rd1 <= o1; 

        elsif(rs1="01") then --rd1 should output register 2 
        rd1 <= o2; 
        
        elsif(rs1="10") then --rd1 should output register 3 
        rd1 <= o3; 
        
        else --rd1 should output register 1 
        rd1 <= o4; 
        
        end if; 
        if(rs2="00") then --rd2 should output register 1 
        rd2 <= o1; 

        elsif(rs2="01") then --rd2 should output register 2 
        rd2 <= o2; 
        
        elsif(rs2="10") then --rd2 should output register 3 
        rd2 <= o3; 
        
        else --rd2 should output register 1 
        rd2 <= o4; 
        end if;
    end if;
end process;



end behav;

