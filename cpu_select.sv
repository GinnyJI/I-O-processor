
module Reg_in_sel(reg_in, ALU_out, mdr, opB, ir, opA, pc, reg_in_data);
	input  [2:0]  reg_in;
	input  [15:0] ALU_out, mdr, ir, opA, opB, pc;
	output logic [15:0] reg_in_data;

	// RegIn Sel
	always_comb begin
		case(reg_in)
			0: reg_in_data = ALU_out;
			1: reg_in_data = mdr;
			2: reg_in_data = opB;
			3: reg_in_data = {ir[15]?7'b1111111:7'd0, ir[15:8]}; // mvi 
			4: reg_in_data = {ir[15:8], opA[7:0]}; // mvhi
			5: reg_in_data = pc;
			default: reg_in_data = 0;
		endcase // reg_in
	end
endmodule

module Alu_1_sel(alu_1, pc, opA, alu_in_A);
	input  alu_1;
	input  [15:0] pc, opA;
	output logic [15:0] alu_in_A;
	// ALU 1 Sel
	always_comb begin
		case(alu_1)
			0: alu_in_A = pc;
			1: alu_in_A = opA;
		endcase // ALU_1_Sel
	end
endmodule

module Alu_2_sel(alu_2,opB,ir,alu_in_B);
	input  [1:0]  alu_2;
	input  [15:0] opB,ir;
	output logic [15:0] alu_in_B;
	// ALU 2 Sel
	always_comb begin
		case(alu_2)
			0: alu_in_B = 2;
			1: alu_in_B = opB;
			2: alu_in_B = ({ir[15]?4'b1111:4'd0, ir[15:5]} << 1); // imm11
			3: alu_in_B = {ir[15]?7'b1111111:7'd0, ir[15:8]}; // imm8
		endcase // ALU_2_Sel
	end
endmodule

module Addr_sel(addr_sel,pc,opB,mem_addr);
	input  addr_sel;
	input  [15:0] pc, opB;
	output logic [15:0] mem_addr;
	// ADDR Sel
	always_comb begin
		case(addr_sel)
			0: mem_addr = pc;
			1: mem_addr = opB;
		endcase // addr_sel
	end
endmodule

module Pc_sel(pc_sel,ALU_out_wire,opA,pc_wire);
	input  pc_sel;
	input  [15:0] ALU_out_wire, opA;
	output logic [15:0] pc_wire;
	// PC Sel
	always_comb begin
		case(pc_sel)
			0:  pc_wire = ALU_out_wire; // Normal PC increment, branch instruction not from register
			1:  pc_wire = opA; // Branch instruction from register
		endcase // addr_sel
	end
endmodule

module Reg_w_sel(reg_w_sel,ir,reg_w);
	input  reg_w_sel;
	input  [15:0] ir;
	output logic [2:0] reg_w;
	// Reg w Sel
	always_comb begin
		case(reg_w_sel)
			0:  reg_w = ir[7:5]; 
			1:  reg_w = 3'b111; // Select R7 to store PC
		endcase // addr_sel
	end
endmodule
