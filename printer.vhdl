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
    variable printVal : integer;
    begin
        if(clk'event and clk = '1' and en = '1') then
        printVal := to_integer(signed(I));
        if(printVal >= 0) then
          if(printVal < 10) then
            report "   " & integer'image(printVal) severity note;
          elsif(printVal < 100) then
            report "  " & integer'image(printVal) severity note;
          else
            report " " & integer'image(printVal) severity note;
          end if;
        else
          if(printVal > -10) then
            report "  " & integer'image(printVal) severity note;
          elsif(printVal > -100) then
            report " " & integer'image(printVal) severity note;
          else
            report integer'image(printVal) severity note;
          end if;
        end if;
        end if;
    end process;

end behav;

