module cpu_rf(clk,reset,rf_write,reg_A,reg_B,reg_w,reg_A_data,reg_B_data,data_w);
	input clk,reset;
	input rf_write; // Write Enable
	input [2:0] reg_A, reg_B; // Select signal for registers
	input [2:0] reg_w; // Select signal for which register to write to
	input [15:0] data_w; // Data to be written into register selected by reg_w

	output logic [15:0] reg_A_data,reg_B_data; // Data in those 2 register

	logic [15:0] R0,R1,R2,R3,R4,R5,R6,R7;

	// Asynchronous Read
	always_comb begin
		case(reg_A)
			0: reg_A_data = R0;
			1: reg_A_data = R1;
			2: reg_A_data = R2;
			3: reg_A_data = R3;
			4: reg_A_data = R4;
			5: reg_A_data = R5;
			6: reg_A_data = R6;
			7: reg_A_data = R7;
		endcase // reg_A
		case(reg_B)
			0: reg_B_data = R0;
			1: reg_B_data = R1;
			2: reg_B_data = R2;
			3: reg_B_data = R3;
			4: reg_B_data = R4;
			5: reg_B_data = R5;
			6: reg_B_data = R6;
			7: reg_B_data = R7;
		endcase // reg_B
	end

	//Synchronous Write
	always_ff @(posedge clk or posedge reset) begin
		if(reset) begin
			R0 <= 0;
			R1 <= 0;
			R2 <= 0;
			R3 <= 0;
			R4 <= 0;
			R5 <= 0;
			R6 <= 0;
			R7 <= 0;
		end 
		else if(rf_write) begin
			case (reg_w)
				0: R0 <= data_w;
				1: R1 <= data_w;
				2: R2 <= data_w;
				3: R3 <= data_w;
				4: R4 <= data_w;
				5: R5 <= data_w;
				6: R6 <= data_w;
				7: R7 <= data_w;
			endcase
		end
	end

endmodule // RF