mux: 4to1_mux_tb.vhdl 4to1_mux.vhdl
	ghdl -a 4to1_mux.vhdl
	ghdl -a 4to1_mux_tb.vhdl
	ghdl -e mux_tb
	ghdl -r mux_tb --vcd=mux.vcd

shift_reg: shift_reg_tb.vhdl shift_reg.vhdl
	ghdl -a shift_reg.vhdl
	ghdl -a shift_reg_tb.vhdl
	ghdl -e shift_reg_tb
	ghdl -r shift_reg_tb

shift_reg_8bit: shift_reg_8bit_tb.vhdl shift_reg_8bit.vhdl
	ghdl -a shift_reg_8bit.vhdl
	ghdl -a shift_reg_8bit_tb.vhdl
	ghdl -e shift_reg_8bit_tb
	ghdl -r shift_reg_8bit_tb

adder_subtractor: adder_subtractor_tb.vhdl adder_subtractor.vhdl
	ghdl -a adder_subtractor.vhdl
	ghdl -a adder_subtractor_tb.vhdl
	ghdl -e adder_subtractor_tb
	ghdl -r adder_subtractor_tb