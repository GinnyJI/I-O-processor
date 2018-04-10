module cpu_control(
	clk, reset,
	instr, flag_n, flag_z,
	alu_1, ALU_op, addr_sel, 
	alu_2,reg_in, pc_sel, reg_w_sel,
	mem_wait, mem_rddatavalid,

	mem_read, mem_wr,
	opA_wr, opB_wr, alu_out_wr, PC_wr, MDR_wr, ir_wr, flag_wr, RF_wr
);
	input clk, reset;
	input [4:0] instr;
	input flag_n, flag_z;
	input mem_wait, mem_rddatavalid;

	output logic alu_1, ALU_op, addr_sel;
	output logic [1:0] alu_2;
	output logic [2:0] reg_in;
	output logic pc_sel, reg_w_sel;

	output logic mem_read,mem_wr;

	// Input: Register write signal
	output logic opA_wr, opB_wr, alu_out_wr;
	output logic PC_wr, MDR_wr, ir_wr, flag_wr;
	output logic RF_wr;

	enum int unsigned
	{	
		s_reset, c0,
		c1, c2, c3_mv, c3_asc, c4_as,
		c3_st, c3_ld, c4_ld, c5_ld, c3_mvi, 
		c3_asci, c4_asi, c3_mvhi, 
		c3_jr, c3_jznr, c3_callr, c4_callr,
		c3_j, c3_jzn, c3_call, c4_call
	} state, nextstate;

	always_ff @ (posedge clk or posedge reset) begin
		if (reset) state <= s_reset;// TODO: choose initial reset state
		else state <= nextstate;
	end

	always_comb begin
		nextstate = state;

		alu_1      = 0;
		ALU_op     = 0;
		addr_sel   = 0;
		alu_2      = 0;
		reg_in     = 0;
		pc_sel     = 0;
		reg_w_sel  = 0;
		opA_wr     = 0;
		opB_wr     = 0;
		alu_out_wr = 0;
		PC_wr      = 0;
		MDR_wr     = 0;
		ir_wr      = 0;
		flag_wr    = 0;
		RF_wr      = 0;
		mem_read   = 0;
		mem_wr     = 0;

		case(state)
			s_reset: begin
				nextstate = c0;
			end
			c0: begin // Get instruction from memory
				if(mem_wait == 1) nextstate = c0; // If wait is high, repeat request
				else nextstate = c1;
				mem_read   = 1;
			end
			c1: begin // Increment PC by 2
				if(mem_rddatavalid == 0) nextstate = c1; // If valid is low, wait for valid to go high
				else begin // When data is valid, increment PC, store instr into IR
					nextstate = c2;
					// Datapath Signal
					alu_1      = 0; // Select PC
					ALU_op     = 0; // Select add
					addr_sel   = 0; // Select PC
					alu_2      = 0; // Select 2
					pc_sel     = 0; // Select alu_out_wire
					PC_wr      = 1;
					ir_wr      = 1; // Write instr from memory to IR
				end
			end
			c2: begin // Read from RF and store into opA, opB
				if(instr == 5'b00000) nextstate = c3_mv;
				else if(instr == 5'b00001 || instr == 5'b00010 || instr == 5'b00011) nextstate = c3_asc;
				else if(instr == 5'b00100) nextstate = c3_ld;
				else if(instr == 5'b00101) nextstate = c3_st;
				else if(instr == 5'b10000) nextstate = c3_mvi;
				else if(instr == 5'b10001 || instr == 5'b10010 || instr == 5'b10011) nextstate = c3_asci;
				else if(instr == 5'b10110) nextstate = c3_mvhi;
				else if(instr == 5'b01000) nextstate = c3_jr;
				else if(instr == 5'b01001 || instr == 5'b01010) nextstate = c3_jznr;
				else if(instr == 5'b01100) nextstate = c3_callr;
				else if(instr == 5'b11000) nextstate = c3_j;
				else if(instr == 5'b11001 || instr == 5'b11010) nextstate = c3_jzn;
				else if(instr == 5'b11100) nextstate = c3_call;
				// Datapath Signal
				reg_w_sel  = 0; // Select IR[7:5]
				opA_wr     = 1; 
				opB_wr     = 1;
			end
			c3_mv: begin // [Rx] ← [Ry]
				nextstate = c0;
				// Datapath Signal
				reg_in     = 2; // Select opB to store into [Rx] 
				reg_w_sel  = 0; // Select [Rx] to write into
				RF_wr      = 1;
			end
			c3_asc: begin // Do operation, update flag, and store output to ALU_OUT
				if(instr == 5'b00001) begin // add
					nextstate = c4_as;
					ALU_op    = 0; // Select add
				end
				else if(instr == 5'b00010) begin //sub
					nextstate = c4_as;
					ALU_op    = 1; // Select sub
				end
				else begin // cmp
					nextstate = c0;
					ALU_op    = 1; // Select sub
				end
				// Datapath Signal
				alu_1      = 1; // Select opA
				alu_2      = 1; // Select opB
				alu_out_wr = 1; // Write to alu_out register
				flag_wr    = 1; // Update flag
			end
			c4_as: begin
				nextstate = c0;
				// Datapath Signal
				reg_in     = 0; // Select ALU_out register
				reg_w_sel  = 0; // Select [Rx] to store value
				RF_wr      = 1;
			end
			c3_st: begin // mem[[Ry]] ← [Rx] 
				if(mem_wait == 1) nextstate = c3_st; // If wait is high, repeat request
				else nextstate = c0;
				// Datapath Signal
				addr_sel   = 1; // Select [Ry] for memory address
				mem_wr     = 1; // Select memory write
			end
			c3_ld: begin // MDR ← mem[[Ry]]  
				if(mem_wait == 1) nextstate = c3_ld; // If wait is high, repeat request
				else nextstate = c4_ld;
				// Datapath Signal
				addr_sel   = 1; // Select [Ry] for memory address 
				mem_read   = 1;
			end
			c4_ld: begin 
				if(mem_rddatavalid == 0) nextstate = c4_ld; // If valid is low, wait for high
				else begin
					nextstate = c5_ld;
					MDR_wr     = 1; // Store output of memory into MDR
				end
			end
			c5_ld: begin // [Rx] ← MDR
				nextstate = c0;
				// Datapath Signal
				reg_in     = 1; // Select MDR
				reg_w_sel  = 0; // Select [Rx] to store data
				RF_wr      = 1;
			end
			c3_mvi: begin // [Rx] ← s ext(imm8)
				nextstate = c0;
				// Datapath Signal
				reg_in     = 3; // Select s_ext(imm8) to store into [Rx] 
				reg_w_sel  = 0; // Select [Rx] to write into
				RF_wr      = 1; 
			end
			c3_asci: begin // [ALU_out] ← [opA] op s_ext(imm8) 
				if(instr == 5'b10001) begin // addi
					nextstate = c4_asi;
					ALU_op    = 0; // Select add
				end
				else if(instr == 5'b10010) begin //subi
					nextstate = c4_asi;
					ALU_op    = 1; // Select sub
				end
				else begin // cmp
					nextstate = c0;
					ALU_op    = 1; // Select sub
				end				
				// Datapath Signal
				alu_1      = 1; // Select opA
				alu_2      = 3; // Select s_ext(imm8) to operation
				alu_out_wr = 1; // Write to alu_out register
				flag_wr    = 1; // Update flag
			end
			c4_asi: begin // [Rx] ← [ALU_out] 
				nextstate = c0;
				// Datapath Signal
				reg_in     = 0; // Select ALU_out register
				reg_w_sel  = 0; // Select [Rx] to store value
				RF_wr      = 1;
			end
			c3_mvhi: begin // [Rx][15:8] ← imm8
				nextstate = c0;
				// Datapath Signal
				reg_in     = 4; // Select S_EXT IR[15:5] to store into [Rx] 
				reg_w_sel  = 0; // Select [Rx] to write into
				RF_wr      = 1; 
			end
			c3_jr: begin // PC ← [Rx] 
				nextstate = c0;
				// Datapath Signal
				pc_sel     = 1; // Select OpA value to store in PC
				PC_wr      = 1; 
			end
			c3_jznr: begin // PC ← [Rx] if flag is 1
				nextstate = c0;
				// Datapath Signal
				if(instr == 5'b01001 && flag_z == 1) begin // jzr
					pc_sel     = 1; // Select OpA value to store in PC
					PC_wr      = 1; 
				end
				else if(instr == 5'b01010 && flag_n == 1) begin // jnr
					pc_sel     = 1; // Select OpA value to store in PC
					PC_wr      = 1; 
				end
			end
			c3_callr: begin // R7 ← PC
				nextstate = c4_callr;
				// Datapath Signal
				reg_in     = 5; // Select PC to store into R7
				reg_w_sel  = 1; // Select R7
				RF_wr      = 1;
			end
			c4_callr: begin // PC ← opA
				nextstate = c0;
				// Datapath Signal
				pc_sel     = 1; // Select opA to store in PC
				PC_wr      = 1; 
			end
			c3_j: begin // PC ← PC + 2*s_ext(imm11) 
				nextstate = c0;
				// Datapath Signal
				alu_1      = 0; // Select PC
				ALU_op     = 0; // Select add
				addr_sel   = 0; // Select PC
				alu_2      = 2; // Select imm11
				pc_sel     = 0; // Select alu_out_wire
				PC_wr      = 1; 
			end
			c3_jzn: begin // PC ← PC + 2*s_ext(imm11) if flag is 1
				nextstate = c0;
				// Datapath Signal
				if(instr == 5'b11001 && flag_z == 1) begin // jz
					alu_1      = 0; // Select PC
					ALU_op     = 0; // Select add
					addr_sel   = 0; // Select PC
					alu_2      = 2; // Select imm11
					pc_sel     = 0; // Select alu_out_wire
					PC_wr      = 1; 
				end
				else if(instr == 5'b11010 && flag_n == 1) begin // jn
					alu_1      = 0; // Select PC
					ALU_op     = 0; // Select add
					addr_sel   = 0; // Select PC
					alu_2      = 2; // Select imm11
					pc_sel     = 0; // Select alu_out_wire
					PC_wr      = 1; 
				end			
			end
			c3_call: begin // R7 ← PC 
				nextstate = c4_call;
				// Datapath Signal
				reg_in     = 5; // Select PC to store into R7
				reg_w_sel  = 1; // Select R7
				RF_wr      = 1;
			end 
			c4_call: begin // PC ← PC + 2*s_ext(imm11)
				nextstate = c0;
				// Datapath Signal
				alu_1      = 0; // Select PC
				ALU_op     = 0; // Select add
				addr_sel   = 0; // Select PC
				alu_2      = 2; // Select imm11
				pc_sel     = 0; // Select alu_out_wire
				PC_wr      = 1; 
			end
		endcase // state
	end

endmodule // control