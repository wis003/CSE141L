import definitions::*;			              // includes package "definitions"

// ALU module
module ALU #(parameter W=8, Ops=4) (
  input        [W-1:0]   InputA,          // data inputs
                         InputB,
  input        [Ops-1:0] OP,		          // ALU opcode, part of microcode
  input                  SC_in,           // shift or carry in
  output logic [W-1:0]   Out		          // data output
  );								    
	 
  op_mne op_mnemonic;			                // type enum: used for convenient waveform viewing
	
  always_comb begin
    Out = 0;                              // No Op = default
    case(OP)							  
      ADD : Out = InputA + InputB;        // add
      SUB : Out = InputA + (~InputB) + 1; // sub
      AND : Out = InputA & InputB;        // bitwise AND
      OR  : Out = InputA | InputB;        // bitwise OR
      XOR : Out = ^(InputB);              // reduction XOR (8 bit output)
      LSH : Out = InputA << InputB;       // shift left
      RSH : Out = InputA >> InputB;       // shift right
      SEQ : Out = InputA == InputB;       // equals (8 bit output)
      SNE : Out = InputA != InputB;
      SLT : Out = InputA < InputB;        // less than (8 bit output)
    endcase
  end

  always_comb
    op_mnemonic = op_mne'(OP);			      // displays operation name in waveform viewer

endmodule