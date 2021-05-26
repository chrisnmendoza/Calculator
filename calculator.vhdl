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

component calculator_controller is
    port( --opcode key: calculator controller relies on opfield and alu eq output of main alu
        opCode, imm: in std_logic_vector(1 downto 0);
        equals: in std_logic;
        beqOutput: in std_logic_vector(7 downto 0);
        rType, printing, branchConfirm, writeEnable, noSkipPrint, clkSkip: out std_logic;
        regWriteSelector: out std_logic_vector (1 downto 0)
    );
end component;

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

component printer
port(	I: in std_logic_vector(7 downto 0);
        en: in std_logic;
        clk: in std_logic
);
end component;

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
signal regWriteSelector : std_logic_vector(1 downto 0);
signal printEnable : std_logic;

--beq signals
signal beqRegisterInputA, beqRegisterInputB, beqRegisterSelect : std_logic_vector (1 downto 0);
signal beqRegisterOutputA, beqRegisterOutputB, beqRegisterWrite, beqRegisterDecremented : std_logic_vector(7 downto 0);
signal branchCounter : std_logic_vector(1 downto 0) := "00";
signal IBuffer : std_logic_vector(7 downto 0);
signal clkSkip : std_logic;


--signal ws_signal : std_logic_vector (1 downto 0) := "00";
begin  

    beqRegisterFile : registerFile port map(rs1 => "00", rs2 => "01", clk => clk_sig5, ws => "00", wd=>beqRegisterWrite, we => '1',rd1 =>beqRegisterOutputA, rd2 =>beqRegisterOutputB  );


    --mux selected by aluBranchConfirm (from controller) to choose what to set the beqRegister to
    with aluBranchconfirm select
        beqRegisterWrite <= "000000" & I(1 downto 0) when '1',
                            beqRegisterDecremented when others;

    --mux-implemented decrementer
    with beqRegisterOutputA select
        beqRegisterDecremented <=   std_logic_vector(unsigned(beqRegisterOutputA) - 1) when "00000010", --two's complement subtraction
                                    std_logic_vector(unsigned(beqRegisterOutputA) - 1) when "00000001", --two's complement subtraction
                                    "00000000" when others;
    
    --beq can skip either 1 or 2, if skipping a line set the input to "00000000"
    with beqRegisterOutputA(1 downto 0) select
        IBuffer <=  I when "00",
                    "00000000" when others;


    regFile : registerFile port map(rs1 => IBuffer(5 downto 4), rs2 => IBuffer(3 downto 2), clk => clk_sig9, ws => regDest, wd=>regWrite, we => writeEnable,rd1 =>regFileOutputA, rd2 =>regFileOutputB  );
    alu1: alu port map(A => regFileOutputA, B => regFileOutputB, opField => IBuffer(7 downto 6), O => aluOutput, EQ => aluBranchOutput);
    controller: calculator_controller port map(opCode => I(7 downto 6), imm => I(1 downto 0), beqOutput => beqRegisterOutputA, equals => aluBranchOutput, rType => rType, printing => printing, branchConfirm => aluBranchConfirm, writeEnable => writeEnable, noSkipPrint => printEnable, clkSkip => clkSkip, regWriteSelector => regWriteSelector);
    printer1: printer port map(I => regWrite, en => printEnable, clk => clk);

    --controller changes the register being written to
    with rType select
        regDest <= IBuffer(1 downto 0) when '1', --add/sub has regDest at last 2 bits
                   IBuffer(5 downto 4) when others; --load is at 2 bits 2 to the left 
    
    --controller selects what to write to the register
    with regWriteSelector select
        regWrite <= aluOutput when "10", --add/sub gets regWrite from alu
                    immExtend when "00", --load gets regWrite from immediate field
                    regFileOutputA when others; --DO NOT CHANGE regWrite WHEN PRINTING = 1
    
    --sign extender
    with IBuffer(3) select
        immExtend <= "0000" & IBuffer(3 downto 0) when '0',
                     "1111" & IBuffer(3 downto 0) when others;

    process(clk)
    begin
        clk_sig1 <= clk;
    end process;

    clk_sig2 <= clk_sig1; --need to match delta delays for clock and all the logic
    clk_sig3 <= clk_sig2;
    clk_sig4 <= clk_sig3;
    clk_sig5 <= clk_sig4;
    clk_sig6 <= clk_sig5;
    clk_sig7 <= clk_sig6;


    process(clk_sig7)
    begin
        if(clkSkip = '0') then --controller determines whether or not registerFile gets input
            clk_sig8 <= clk_sig7;
        end if;
    end process;

    process(clk_sig8)
    begin
        clk_sig9 <= clk_sig8;
    end process;

end architecture behavioral;