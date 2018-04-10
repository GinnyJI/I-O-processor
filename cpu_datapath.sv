module cpu_datapath(
	clk, reset, alu_1, alu_2, ALU_op, reg_in, addr_sel,
	opA_wr, opB_wr, alu_out_wr,pc_sel, reg_w_sel,
	PC_wr, MDR_wr, ir_wr, flag_wr, RF_wr, data_in,
	mem_addr, data_out, instr, flag_n, flag_z
	);

	input clk, reset;
	
	// Input: Select signal
	input alu_1, ALU_op, addr_sel;
	input [1:0]alu_2;
	input [2:0]reg_in;
	input pc_sel, reg_w_sel;

	// Input: Register write signal
	input opA_wr, opB_wr, alu_out_wr;
	input PC_wr, MDR_wr, ir_wr, flag_wr;
	input RF_wr;

	// Input: Data
	input [15:0] data_in;

	output logic [15:0] mem_addr;
	output logic [15:0] data_out;
	output logic [4:0] instr;

	// Flag Registers
	output logic flag_n, flag_z;

	// Intermediate Registers
	logic [15:0] pc, mdr, ir; 
	logic [15:0] opA, opB, ALU_out;
	
	// Wire
	logic n_wire, z_wire;
	logic [15:0] reg_in_data, pc_wire;
	logic [15:0] in_A, in_B, alu_in_A, alu_in_B;
	logic [15:0] ALU_out_wire;
	logic [2:0] reg_w;
	
	// Assignment of output
	assign instr = ir[4:0];
	assign data_out = opA;

	// Instantiation of Blocks 
	ALU alu_inst(
		// Input of ALU
		.clk(clk), .reset(reset), .in_A(alu_in_A), .in_B(alu_in_B),
		.ALU_op(ALU_op),
		// Output of ALU
		.flag_n(n_wire), .flag_z(z_wire),.ALU_out(ALU_out_wire)
	);

	cpu_rf RF_inst(
		// Input of RF block
		.clk(clk), .reset(reset), .rf_write(RF_wr),
		// Register Select
		.reg_A(ir[7:5]), .reg_B(ir[10:8]),
		.reg_w(reg_w),
		// Reg Data Input
		.data_w(reg_in_data),
		// Output of RF block
		.reg_A_data(in_A), .reg_B_data(in_B)
	);

	// Registers
	always_ff @(posedge clk or posedge reset) begin
		if(reset) begin
			pc 		<= 0;
			mdr 	<= 0;
			ir 		<= 0; 
			opA 	<= 0;
			opB 	<= 0;
			ALU_out <= 0;
		end 
		else begin
			if(opA_wr) opA <= in_A;
			if(opB_wr) opB <= in_B;
			if(alu_out_wr) ALU_out <= ALU_out_wire;
			if(PC_wr) pc <= pc_wire;
			if(MDR_wr) mdr <= data_in;
			if(ir_wr) ir <= data_in;
			if(flag_wr) begin
				flag_z <= z_wire;
				flag_n <= n_wire;
			end
		end
	end

	// Select Signals
	Reg_in_sel reg_in_inst(.reg_in(reg_in), .ALU_out(ALU_out), 
						   .mdr(mdr), .opB(opB), .ir(ir), .opA(opA), 
						   .pc(pc), .reg_in_data(reg_in_data));

	Alu_1_sel alu_1_sel_inst(.alu_1(alu_1), .pc(pc), .opA(opA), .alu_in_A(alu_in_A));

	Alu_2_sel alu_2_sel_ins(.alu_2(alu_2), .opB(opB), .ir(ir), .alu_in_B(alu_in_B));

	Addr_sel addr_sel_inst(.addr_sel(addr_sel), .pc(pc), .opB(opB), .mem_addr(mem_addr));

	Pc_sel pc_sel_inst(.pc_sel(pc_sel), .ALU_out_wire(ALU_out_wire), .opA(opA), .pc_wire(pc_wire));

	Reg_w_sel reg_w_inst(.reg_w_sel(reg_w_sel), .ir(ir), .reg_w(reg_w));
endmodule // datapath
