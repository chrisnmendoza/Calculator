library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

--Things to add:
--Print command (10 same as beq) only time something gets displayed
--beq simply makes nothing get transmitted to registerFile, and nothing gets printed either
--We can make nothing get transmitted to registerFile by making a second signal
--for the inputs of registerFile and muxing that with itself and the updated instructions
--the select is a skip_signal which gets determined by the alu EQ output


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
signal aluOutput, aluOutputBuffer : std_logic_vector(7 downto 0);
signal aluBranch: std_logic;
signal rType : std_logic; --signifies whether it is add/subtract (1) or load (0)
signal immExtend : std_logic_vector(7 downto 0); --immedate 0 or 1 padded
signal opCodeAndClk: std_logic_vector(2 downto 0);
signal clk_sig1, clk_sig2, clk_sig3, clk_sig4, clk_sig5, clk_sig6, clk_sig7, clk_sig8, clk_sig9 : std_logic := '0';

--signal ws_signal : std_logic_vector (1 downto 0) := "00";
begin  
    regFile : registerFile port map(rs1 => regFileInputA, rs2 => regFileInputB, clk => clk_sig9, ws => regDest, wd=>regWrite, we => writeEnable,rd1 =>regFileOutputA, rd2 =>regFileOutputB  );
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

    with I(7 downto 6) select 
        writeEnable <= '1' when "00",
                       '1' when "11",
                       '1' when "01",
                       '0' when others;
    
    opCodeAndClk <= I(7 downto 6) & clk;


    process(clk)
    begin
        clk_sig1 <= clk;
    end process;

    process(clk_sig1)
    begin
        clk_sig2 <= clk_sig1;
    end process;

    process(clk_sig2)
    begin
        clk_sig3 <= clk_sig2;
    end process;

    process(clk_sig3)
    begin
        clk_sig4 <= clk_sig3;
    end process;

    process(clk_sig4)
    begin
        clk_sig5 <= clk_sig4;
    end process;

    process(clk_sig5)
    begin
        clk_sig6 <= clk_sig5;
    end process;

    process(clk_sig6)
    begin
        clk_sig7 <= clk_sig6;
    end process;

    process(clk_sig7)
    begin
        clk_sig8 <= clk_sig7;
    end process;

    process(clk_sig8)
    begin
        if(clk_sig8 = '1' and clk_sig8'event) then
            report "regWrite: " & integer'image(to_integer(signed(RegWrite))); 
        end if;
        clk_sig9 <= clk_sig8;
    end process;

end architecture behavioral;