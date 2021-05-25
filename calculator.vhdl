library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

--Things to add:
--make a vhdl file for the control
--Print statement: opcode == 10, rs == what's getting printed, rt == not used, rd MUST EQUAL 3, OR ELSE IT'S A BEQ

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

component reg is
    port(	I:	in std_logic_vector (7 downto 0) := "00000000";
            clk:	in std_logic;
            O:	out std_logic_vector(7 downto 0) := "00000000"
    );
end component reg;

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
signal aluBranchConfirm, aluBranchOutput: std_logic;
signal rType : std_logic; --signifies whether it is add/subtract (1) or load (0)
signal immExtend : std_logic_vector(7 downto 0); --immedate 0 or 1 padded
signal opCodeAndClk: std_logic_vector(2 downto 0);
signal clk_sig1, clk_sig2, clk_sig3, clk_sig4, clk_sig5, clk_sig6, clk_sig7, clk_sig8, clk_sig9 : std_logic := '0';
signal printOrBranch, printing : std_logic := '0';
signal rTypeAndPrinting : std_logic_vector(1 downto 0);

--beq signals
signal beqRegisterInputA, beqRegisterInputB, beqRegisterSelect : std_logic_vector (1 downto 0);
signal beqRegisterOutputA, beqRegisterOutputB, beqRegisterWrite, beqRegisterDecremented : std_logic_vector(7 downto 0);
signal branchCounter : std_logic_vector(1 downto 0) := "00";
signal IBuffer : std_logic_vector(7 downto 0);

--signal ws_signal : std_logic_vector (1 downto 0) := "00";
begin  

    beqRegisterFile : registerFile port map(rs1 => "00", rs2 => "01", clk => clk_sig5, ws => "00", wd=>beqRegisterWrite, we => '1',rd1 =>beqRegisterOutputA, rd2 =>beqRegisterOutputB  );

    --mux between 0 and alu eq value, select is I(1 downto 0)
    with I(1 downto 0) select
        aluBranchConfirm <= aluBranchOutput when "01",
                            aluBranchOutput when "10",
                            '0' when others;


    --mux selected by aluBranchConfirm, between I(1 downto 0) and the decrementer to choose what to set the beqRegister to
    with aluBranchconfirm select
        beqRegisterWrite <= "000000" & I(1 downto 0) when '1',
                            beqRegisterDecremented when others;

    with beqRegisterOutputA select
        beqRegisterDecremented <=   std_logic_vector(unsigned(beqRegisterOutputA) - 1) when "00000010", --two's complement subtraction
                                    std_logic_vector(unsigned(beqRegisterOutputA) - 1) when "00000001", --two's complement subtraction
                                    "00000000" when others;
    
    with beqRegisterOutputA select
        IBuffer <=  I when "00000000",
                    "00000000" when others;


    regFile : registerFile port map(rs1 => regFileInputA, rs2 => regFileInputB, clk => clk_sig9, ws => regDest, wd=>regWrite, we => writeEnable,rd1 =>regFileOutputA, rd2 =>regFileOutputB  );
    alu1: alu port map(A => aluInputA, B => aluInputB, opField => aluOpField, O => aluOutput, EQ => aluBranchOutput);

    with IBuffer(7 downto 6) select 
        rType <= '0' when "01", --load is i type
                 '0' when "10", --print i guess
                 '1' when others;
    
    with rType select
        regDest <= IBuffer(1 downto 0) when '1', --add/sub has regDest at last 2 bits
                   IBuffer(5 downto 4) when others; --load is at 2 bits 2 to the left 
    
    regFileInputA <= IBuffer(5 downto 4);

    with rType select
        regFileInputB <= IBuffer(3 downto 2) when '1', --add/sub format
                         IBuffer(3 downto 2) when others;

    with IBuffer(7 downto 6) select
        printOrBranch <= '1' when "10",
                         '0' when others;
    
    with IBuffer(1 downto 0) select
        printing <= printOrBranch when "11",
                    '0' when others;

    rTypeAndPrinting <= rType & printing;
    
    with rTypeAndPrinting select
        regWrite <= aluOutput when "10", --add/sub gets regWrite from alu
                    immExtend when "00", --load gets regWrite from immediate field
                    regFileOutputA when others; --DO NOT CHANGE regWrite WHEN PRINTING = 1
    
    with IBuffer(3) select
        immExtend <= "0000" & IBuffer(3 downto 0) when '0',
                     "1111" & IBuffer(3 downto 0) when others;

    aluOpField <= IBuffer(7 downto 6);

    aluInputA <= regFileOutputA;
    aluInputB <= regFileOutputB;

    with IBuffer(7 downto 6) select 
        writeEnable <= '1' when "00",
                       '1' when "11",
                       '1' when "01",
                       '0' when others;
    
    opCodeAndClk <= IBuffer(7 downto 6) & clk;


    process(clk)
    begin
        if(clk = '1' and clk'event and printing = '1') then
            report integer'image(to_integer(signed(RegWrite))); 
        end if;
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
        if(beqRegisterOutputA = "00000000") then
            clk_sig8 <= clk_sig7;
        end if;
    end process;

    process(clk_sig8)
    begin
        if(clk_sig8 = '1' and clk_sig8'event) then
            report "regWrite: " & integer'image(to_integer(signed(RegWrite))); --debugging for regWrite
        end if;
        clk_sig9 <= clk_sig8;
    end process;

end architecture behavioral;