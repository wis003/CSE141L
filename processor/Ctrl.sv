// CSE141L
import definitions::*;
// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
module Ctrl (
  input[ 8:0]  Instruction,	   // machine code
  output logic Jump     ,
               BranchEn ,
               RegWrEn  ,	   // write to reg_file (common)
               MemWrEn  ,	   // write to mem (store only)
               LoadInst	,	   // mem or ALU to reg_file ?
      	       StoreInst,          // mem write enable
	             Ack      ,		   // "done w/ program"
  );

assign MemWrEn = Instruction[8:6]==3'b110;	 //111  110
assign StoreInst = Instruction[8:6]==3'b110;  // calls out store specially

assign RegWrEn = Instruction[8:7]!=2'b11;  // !111  !110 
assign LoadInst = Instruction[8:6] == 3'b011;
// reserve instruction = 9'b111111111; for Ack

// jump on right shift that generates a zero
// equiv to simply: assign Jump = Instrucxtion[2:0] == kRSH;
always_comb
  if(Instruction[2:0] ==  kRSH)
    Jump = 1;
  else
    Jump = 0;

// branch every time instruction = 9'b?????1111;
assign BranchEn = &Instruction[3:0];

assign Ack = &Instruction;

endmodule

