module cpu(clk,reset,o_mem_addr,o_mem_rd,i_mem_rddata,
		   o_mem_wr,o_mem_wrdata, i_mem_wait,i_mem_rddatavalid);
	input clk;
	input reset;
	input [15:0] i_mem_rddata;
	input i_mem_wait, i_mem_rddatavalid;

	output [15:0] o_mem_addr;
	output [15:0] o_mem_wrdata;
	output o_mem_wr;
	output o_mem_rd;

	// Wires
	logic [4:0] instr;
	logic flag_n, flag_z;

	logic alu_1, ALU_op, addr_sel;
	logic [1:0] alu_2;
	logic [2:0] reg_in;
	logic pc_sel, reg_w_sel;

	logic opA_wr, opB_wr, alu_out_wr;
	logic PC_wr, MDR_wr, ir_wr, flag_wr;
	logic RF_wr;

	cpu_datapath dp_inst(.clk(clk), .reset(reset), .alu_1(alu_1), .alu_2(alu_2), .ALU_op(ALU_op), 
		.reg_in(reg_in), .addr_sel(addr_sel),
		.opA_wr(opA_wr), .opB_wr(opB_wr), .alu_out_wr(alu_out_wr),
		.PC_wr(PC_wr), .MDR_wr(MDR_wr), .ir_wr(ir_wr), .flag_wr(flag_wr), .RF_wr(RF_wr), .data_in(i_mem_rddata),
		.mem_addr(o_mem_addr), .data_out(o_mem_wrdata), .instr(instr), .flag_n(flag_n), .flag_z(flag_z),
		.pc_sel(pc_sel), .reg_w_sel(reg_w_sel));

	cpu_control ctl_inst( .clk(clk), .reset(reset),
		.instr(instr), .flag_n(flag_n), .flag_z(flag_z),
		.alu_1(alu_1), .ALU_op(ALU_op), .addr_sel(addr_sel), 
		.alu_2(alu_2), .reg_in(reg_in), .pc_sel(pc_sel), .reg_w_sel(reg_w_sel),
		.mem_wait(i_mem_wait), .mem_rddatavalid(i_mem_rddatavalid),
		.mem_read(o_mem_rd), .mem_wr(o_mem_wr),
		.opA_wr(opA_wr), .opB_wr(opB_wr), .alu_out_wr(alu_out_wr), .PC_wr(PC_wr), .MDR_wr(MDR_wr), 
		.ir_wr(ir_wr), .flag_wr(flag_wr), .RF_wr(RF_wr)
	);


endmodule // cpu