registerFile: registerFile.vhdl registerFile_tb.vhdl register.vhdl
	ghdl -a register.vhdl
	ghdl -a registerFile.vhdl
	ghdl -a registerFile_tb.vhdl
	ghdl -e registerFile_tb
	ghdl -r registerFile_tb

reg: register.vhdl register_tb.vhdl
	ghdl -a register.vhdl
	ghdl -a register_tb.vhdl
	ghdl -e reg_tb
	ghdl -r reg_tb

alu: alu.vhdl alu_tb.vhdl
	ghdl -a alu.vhdl
	ghdl -a alu_tb.vhdl
	ghdl -e alu_tb
	ghdl -r alu_tb

calculator: calculator.vhdl calculator_tb.vhdl
	ghdl -a calculator.vhdl
	ghdl -a calculator_tb.vhdl
	ghdl -e calculator_tb
	ghdl -r calculator_tb