registerFile: registerFile.vhdl registerFile_tb.vhdl register.vhdl
	ghdl -a register.vhdl
	ghdl -a registerFile.vhdl
	ghdl -a registerFile_tb.vhdl
	ghdl -e registerFile_tb
	ghdl -r registerFile_tb

alu: alu.vhdl alu_tb.vhdl
	ghdl -a alu.vhdl
	ghdl -a alu_tb.vhdl
	ghdl -e alu_tb
	ghdl -r alu_tb