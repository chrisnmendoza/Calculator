library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


entity printer is
port(	I: in std_logic_vector(7 downto 0);
        en: in std_logic;
        clk: in std_logic
);
end printer;


architecture behav of printer is
begin
    process(clk)
    begin
        if(clk'event and clk = '1' and en = '1') then --print 
            report integer'image(to_integer(signed(I)));
        end if;
    end process;

end behav;

