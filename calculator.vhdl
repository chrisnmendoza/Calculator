library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity calculator is 
    port( --opcode key: ADD = 00, SUB = 11, LOAD = 01, CMP/PRINT = 10
        I: in std_logic_vector(7 downto 0) := "00000000"; --format is: opcode (7 downto 6), rs (5 downto 4), rt (3 downto 2), rd (1 downto 0) for rType, 
        clk: in std_logic                                 --opcode(7 downto 6), rd(5 downto 4), im (3 downto 0) for I-type
    );
end entity calculator;

architecture behavioral of calculator is
component alu is  --this is the alu need to add 1 because vhdl name
    port(	A:	in std_logic_vector (7 downto 0);
        B:	in std_logic_vector (7 downto 0);
		opField: in std_logic_vector (1 downto 0); --This corresponds to the opfield in the 8-bit ISA instruction
		O:	out std_logic_vector(7 downto 0);
        EQ: out std_logic
);
end component alu;

component registerFile is
    port(	rs1:	in std_logic_vector (1 downto 0); -- for loading addresses: 00 = register 1, 01 = register 2, 10 = register 3, 11 = register 4
		rs2: in std_logic_vector (1 downto 0); -- for loading addresses
		clk:    in std_logic;
        ws:        in std_logic_vector(1 downto 0); -- write selects address: 00 = register 1, 01 = register 2, 10 = register 3, 11 = register 4
		wd:		in std_logic_vector(7 downto 0); -- write data
        we:		in std_logic; -- positive level triggering in problem 3
		rd1:		out std_logic_vector (7 downto 0); -- 0: don't do anything; 1: shift_reg is enabled
        rd2:		out std_logic_vector (7 downto 0) -- 0: don't do anything; 1: shift_reg is enabled
);
end component registerFile;

signal regOut1, regOut2, regOut3, regOut4: std_logic_vector(7 downto 0);
signal we_signal : std_logic :='0'; --write enable = 1 for all except branch/compare
signal regIn1, regIn2, ws_signal :std_logic_vector(1 downto 0);


signal immediateOutput : std_logic_vector(7 downto 0) := "00000000";


signal regFileInputA, regFileInputB, regDest: std_logic_vector(1 downto 0);
signal regWrite : std_logic_vector(7 downto 0);
signal writeEnable : std_logic;
signal regFileOutputA, regFileOutputB: std_logic_vector(7 downto 0);
signal aluInputA, aluInputB: std_logic_vector(7 downto 0);
signal aluOpField: std_logic_vector(1 downto 0);
signal aluOutput : std_logic_vector(7 downto 0);
signal aluBranch: std_logic;
signal rType : std_logic; --signifies whether it is add/subtract (1) or load (0)
signal immExtend : std_logic_vector(7 downto 0); --immedate 0 or 1 padded
signal clk_signal, clk_signal2, clk_signal3 : std_logic;

--signal ws_signal : std_logic_vector (1 downto 0) := "00";
begin  
    regFile : registerFile port map(rs1 => regFileInputA, rs2 => regFileInputB, clk => clk_signal3, ws => regDest, wd=>regWrite, we => writeEnable,rd1 =>regFileOutputA, rd2 =>regFileOutputB  );
    alu1: alu port map(A => aluInputA, B => aluInputB, opField => aluOpField, O => aluOutput, EQ => aluBranch);

    with I(7 downto 6) select 
        rType <= '0' when "01", --load is i type
                 '0' when "10", --print i guess
                 '1' when others;
    
    with rType select
        regDest <= I(1 downto 0) when '1', --add/sub has regDest at last 2 bits
                   I(5 downto 4) when others; --load is at 2 bits 2 to the left 
    
    regFileInputA <= I(5 downto 4);

    with rType select
        regFileInputB <= I(3 downto 2) when '1', --add/sub format
                         I(5 downto 4) when others; --just to have an expected return value, the registerFile will select rd as its A and B input on load

    with rType select
        regWrite <= aluOutput when '1', --add/sub gets regWrite from alu
                    immExtend when others;
    
    with I(3) select
        immExtend <= "0000" & I(3 downto 0) when '0',
                     "1111" & I(3 downto 0) when others;

    aluOpField <= I(7 downto 6);

    aluInputA <= regFileOutputA;
    aluInputB <= regFileOutputB;

    with I(7 downto 6) select --right now ignores clock
        writeEnable <= '1' when "00",
                       '1' when "11",
                       '1' when "01",
                       '0' when others;
    
    





    process(clk)
    begin
        clk_signal <= clk;
    end process;

    process(clk_signal)
    begin
        clk_signal2 <= clk_signal;
    end process;

    process(clk_signal2)
    begin
        clk_signal3 <= clk_signal2;
        report "regWrite: " & integer'image(to_integer(signed(RegWrite))); 
    end process;


end architecture behavioral;