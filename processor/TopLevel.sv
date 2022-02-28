// Top Level: CSE 141L Processor
module TopLevel(		   // you will have the same 3 ports
    input     	 Reset,	   // init/reset, active high
			     Start,    // start next program
	             Clk,	   // clock -- posedge used inside design
    output logic Ack	   // done flag from DUT
    );

	wire [9:0] 	 ProgCtr,       // program counter
			   	 PCTarget;
	wire [8:0] 	 Instruction;   // our 9-bit opcode
	wire [7:0] 	 ReadA, ReadB;  // reg_file outputs
	wire [7:0] 	 InA, InB, 	   	// ALU operand inputs
			   	 ALU_Out;       // ALU result
	wire [7:0] 	 RegWriteValue, // data in to reg file
			   	 MemWriteValue, // data in to data_memory
			   	 MemReadValue;  // data out from data_memory
	wire       	 MemWrite,	   	// data_memory write enable
			   	 RegWrEn,	   	// reg_file write enable
			   	 Zero,          // ALU output = 0 flag
			   	 BranchUp,	   	// program counter branch up 
			   	 BranchDown;	// program counter branch down
	// logic [15:0] CycleCt;	   	// standalone; NOT PC!

	// Fetch stage = Program Counter + Instruction ROM
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
		.InstAddress  (ProgCtr     ) , 
		.InstOut      (Instruction)
	);

	// Decode stage = Control Decoder + Reg_file
	// Control decoder
	Ctrl Ctrl1 (
		.Instruction  (Instruction) ,  // from instr_ROM
		.Jump         (Jump       ) ,  // to PC to handle jump/branch instructions
		.BranchEn     (BranchEn   )	,  // to PC
		.RegWrEn      (RegWrEn    )	,  // register file write enable
		.MemWrEn      (MemWrite   ) ,  // data memory write enable
		.LoadInst     (LoadInst   ) ,  // selects memory vs ALU output as data input to reg_file
		.StoreInst    (StoreInst  ) ,
		.Ack          (Ack        )	   // "done" flag
	);

	// reg file
	RegFile #(.W(8),.A(3)) RF1 (			  // A(3) makes this 2**3=8 elements deep
		.Clk    				  ,
		.Reset     (Reset),
		.WriteEn   (RegWrEn)    , 
		.RaddrA    (Instruction[5:3]),        //concatenate with 0 to give us 4 bits
		.RaddrB    (Instruction[2:0]), 
		.Waddr     (Instruction[5:3]), 	      // mux above
		.DataIn    (RegWriteValue) , 
		.DataOutA  (ReadA        ) , 
		.DataOutB  (ReadB		 )
	);

	/* one pointer, two adjacent read accesses: 
	(sample optional approach)
		.raddrA ({Instruction[5:3],1'b0});
		.raddrB ({Instruction[5:3],1'b1});
	*/

	assign InA = ReadA;						  // connect RF out to ALU in
	assign InB = ReadB;	          			  // interject switch/mux if needed/desired
	// controlled by Ctrl1 -- must be high for load from data_mem; otherwise usually low
	assign RegWriteValue = LoadInst ? MemReadValue : ALU_Out;  // 2:1 switch into reg_file

	ALU ALU1 (
		.InputA  (InA),
		.InputB  (InB),
		.OP      (Instruction[8:6]), // TODO
		.Out     (ALU_Out)
	);

	DataMem DM1 (
		.Clk,
		.Reset,
		.WriteEn      (MemWrite),
		.DataAddress  (ReadB), 
		.DataIn       (ReadA), 
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