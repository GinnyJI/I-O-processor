module ALU(clk,reset,in_A,in_B,flag_n,flag_z,ALU_op,ALU_out);
	input [15:0] in_A, in_B;
	input clk, reset;
	input ALU_op; // 0 for add, 1 for subtract
	output flag_n, flag_z;
	output reg [15:0] ALU_out;

	
	// ALU operation 
	always_comb begin
		case (ALU_op)
			0: ALU_out = in_A + in_B;
			1: ALU_out = in_A - in_B;
		endcase
	end

	// Flag assignment
	assign flag_z = (ALU_out == 0);
	assign flag_n = ALU_out[15];

	/*
	logic [15:0]c;

	full_adder fa_inst_0(
		.x(opA[0]),
		.y(opB[0] ^ ALU_sel),
		.cin(ALU_sel),
		.s(ALU_out[0]),
		.cout(c[1])
	);

	full_adder fa_inst_15(
		.x(opA[15]),
		.y(opB[15] ^ ALU_sel),
		.cin(c[15]),
		.s(ALU_out[0]),
		.cout()
	);

	genvar i;
	generate
		for(i = 1; i < 15; i++) begin
			full_adder fa_inst(
				.x(opA[i]),
				.y(opB[i] ^ ALU_sel),
				.cin(c[i]),
				.s(ALU_out[0]),
				.cout(c[i+1])
			);
		end
	endgenerate
	*/
endmodule // ALU