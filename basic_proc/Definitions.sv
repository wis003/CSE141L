// this file defines the parameters used in the ALU
// import package into each module that needs it
// packages very useful for declaring global variables
package definitions;
    
    // Instruction map
    const logic [3:0]kADD  = 4'b0000;
    const logic [3:0]kSUB  = 4'b0001;
    const logic [3:0]kAND  = 4'b0010;
    const logic [3:0]kNOR  = 4'b0011;
    const logic [3:0]kXOR  = 4'b0100;
	const logic [3:0]kLSH  = 4'b0101;
	const logic [3:0]kRSH  = 4'b0110;
    const logic [3:0]kSEQ  = 4'b0111;
    const logic [3:0]kSNE  = 4'b1000;
	const logic [3:0]kSGT  = 4'b1001;
	const logic [3:0]kSLT  = 4'b1010;

    // enum names will appear in timing diagram
    typedef enum logic[3:0] {
        ADD, SUB, AND, NOR, XOR, LSH,
        RSH, SEQ, SNE, SGT, SLT } op_mne;

// ADD is of type enum -- equiv., but watch casting
// see ALU.sv for how to handle this   
endpackage // definitions
