library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity calculator is 
    port( --opcode key: ADD = 00, SUB = 11, LOAD = 01, CMP/PRINT = 10
        I: in std_logic_vector(7 downto 0) := "00000000"; --format is: opcode (7 downto 6), rd (5 downto 4), rs (3 downto 2), rt (1 downto 0)
        clk: in std_logic
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

signal regOut1, regOut2, RegWrite : std_logic_vector(7 downto 0) := "00000000";
signal branch, we_signal : std_logic :='0'; --write enable = 1 for all except branch/compare
signal regIn1, regIn2, ws_signal :std_logic_vector(1 downto 0);
signal aluOutput : std_logic_vector(7 downto 0) := "00000000";
signal rType : std_logic := '0'; --signifies whether it is add/subtract (1) or load (0)
signal immediateOutput : std_logic_vector(7 downto 0) := "00000000";
--signal ws_signal : std_logic_vector (1 downto 0) := "00";
begin  
    regFile : registerFile port map(rs1 => I(5 downto 4), rs2 => I(3 downto 2), clk => clk, ws => ws_signal, wd=>regWrite, we => we_signal,rd1 =>regOut1, rd2 =>regOut2  );
    alu1: alu port map(A => regOut1, B => regOut2, opField => I(7 downto 6), O => aluOutput, EQ => branch);
    we_signal <= (I(7) and I(6)) or (not I(7) and not I(6)) or (not I(7) and I(6)); --write enable for when add, sub, or load is called
    rType <= (I(7) and I(6)) or (not I(7) and not I(6)); --add or subtract makes it 1
    immediateOutput(3 downto 0) <= I(3 downto 0);
    with I(3) select immediateOutput(7 downto 4) <=
        "0000" when '0',
        "1111" when others;
    with rType select regWrite <=
        aluOutput when '1',
        immediateOutput when others;
    with rType select ws_signal <=
        I(5 downto 4) when '0',
        I(1 downto 0) when others;

        --PUT LOAD IN A PROCESS STATEMENT
    
    process(clk)
    begin
        report "Reg Output Value of ALU: " & integer'image(to_integer(signed(RegWrite)));
        --report "Reg Output Value of we_signal " & std_logic'image(we_signal);
    end process;


end architecture behavioral;