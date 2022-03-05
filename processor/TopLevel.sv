// Top Level: CSE 141L Processor
module TopLevel(		   // you will have the same 3 ports
    input     	 Reset,	   // init/reset, active high
			     Start,    // start next program
	             Clk,	   // clock -- posedge used inside design
    output logic Ack	   // done flag from DUT
    );

	wire [9:0] 	ProgCtr;       // program counter
	wire [7:0]	PCTarget;
	wire [8:0] 	Instruction;   // our 9-bit opcode
	wire [7:0] 	DataOutA, DataOutB;
	wire [7:0] 	ALU_Out;       // ALU result
	wire [7:0] 	MemReadValue;  // data out from data_memory
	wire [3:0]	ALUInst;
	wire       	MemWrite,	   	// data_memory write enable
			   	BranchUp,	   	// program counter branch up 
			 	BranchDown;	// program counter branch down
	// logic [15:0] CycleCt;	   	// standalone; NOT PC!

	// Fetch stage = Program Counter + Instruction ROM
	// program counter
	ProgCtr PC1 (
		.Reset,  		// pins using shorthand (e.g. .grape(grape) is just .grape)
		.Start, 
		.Clk,
		.BranchUp,  	// branch up enable
		.BranchDown,  	// branch down enable
		.PCTarget,  	// branch distance
		.ProgCtr	   	// program count --> index to instruction memory
	);

	// instruction ROM -- holds the machine code pointed to by program counter
	InstROM #(.W(9)) IR1(
		.InstAddress (ProgCtr    ), 
		.InstOut     (Instruction)
	);

	// Decode stage = Control Decoder + Reg_file
	CtrlReg CtrlReg1 (
		.Clk,
		.Reset,
		.Instruction,
		.ALUData (ALU_Out),
		.MemData (MemReadValue),
		.BranchUp,
		.BranchDown,
		.MemWrite,
		.Ack,
		.DataOutA,
		.DataOutB,
		.PCTarget,
		.ALUInst
	);

	ALU ALU1 (
		.InputA  (DataOutA),
		.InputB  (DataOutB),
		.OP      (ALUInst),
		.Out     (ALU_Out)
	);

	DataMem DM1 (
		.Clk,
		.Reset,
		.WriteEn      (MemWrite),
		.DataAddress  (DataOutB), 
		.DataIn       (DataOutB), 
		.DataOut      (MemReadValue)
	);
		
	/* count number of instructions executed
		not part of main design, potentially useful
		This one halts when Ack is high  
	*/
	// always_ff @(posedge Clk)
	// if (Reset)	   // if(start)
	// 	CycleCt <= 0;
	// else if(Ack == 0)   // if(!halt)
	// 	CycleCt <= CycleCt+16'b1;

endmodule