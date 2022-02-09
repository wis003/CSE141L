import definitions::*;			              // includes package "definitions"

// ALU module
module ALU #(parameter W=8, Ops=4) (
  input        [W-1:0]   InputA,          // data inputs
                         InputB,
  input        [Ops-1:0] OP,		          // ALU opcode, part of microcode
  input                  SC_in,           // shift or carry in
  output logic [W-1:0]   Out,		          // data output 
  output logic           Zero,            // output = zero flag	 !(Out)
                         Parity,          // outparity flag  ^(Out)
                         Odd			        // output odd flag (Out[0])
  );								    
	 
  op_mne op_mnemonic;			                // type enum: used for convenient waveform viewing
	
  always_comb begin
    Out = 0;                              // No Op = default
    case(OP)							  
      ADD : Out = InputA + InputB;        // add
      SUB : Out = InputA + (~InputB) + 1; // sub
      AND : Out = InputA & InputB;        // bitwise AND
      NOR : Out = ~(InputA | InputB);       // bitwise NOR
      XOR : Out = InputA ^ InputB;        // bitwise XOR
      LSH : Out = InputA >> InputB;       // shift left
      RSH : Out = InputA << InputB;       // shift right
      SEQ : Out = InputA == InputB;       // equals
      SNE : Out = InputA != InputB;       // not equals
      SGT : Out = InputA > InputB;        // greater than
      SLT : Out = InputA < InputB;        // less than
    endcase
  end

  assign Zero   = !Out;                   // reduction NOR
  assign Parity = ^Out;                   // reduction XOR
  assign Odd    = Out[0];				          // odd/even -- just the value of the LSB

  always_comb
    op_mnemonic = op_mne'(OP);			      // displays operation name in waveform viewer

endmodule