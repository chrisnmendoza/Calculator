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
    variable int_val : integer;
    begin
        if(clk'event and clk = '1' and en = '1') then
        int_val := to_integer(signed(I));
        if(int_val >= 0) then
          if(int_val < 10) then
            report "   " & integer'image(int_val) severity note;
          elsif(int_val < 100) then
            report "  " & integer'image(int_val) severity note;
          else
            report " " & integer'image(int_val) severity note;
          end if;
        else
          if(int_val > -10) then
            report "  " & integer'image(int_val) severity note;
          elsif(int_val > -100) then
            report " " & integer'image(int_val) severity note;
          else
            report integer'image(int_val) severity note;
          end if;
        end if;
        end if;
    end process;

end behav;

