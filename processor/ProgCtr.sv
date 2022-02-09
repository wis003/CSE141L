// Program Counter
module ProgCtr #(parameter L=10) (
  input                Reset,      // reset, init, etc. -- force PC to 0
                       Start,      // Signal to jump to next program 
                       Clk,        // PC can change on pos. edges only
                       BranchRel,  // jump to Target + PC
					   BranchAbs,  // jump to Target
					   ALU_flag,   // Sometimes you may require signals from other modules, can pass around flags if needed
  input        [L-1:0] Target,     // jump ... "how high?" (100 shooters - future)
  output logic [L-1:0] ProgCtr     // the program counter register itself
  );
  
  logic [1:0] startCount;

  // program counter can clear to 0, increment, or jump
  always_ff @(posedge Clk) begin	           // or just always; always_ff is a linting construct
	if (BranchAbs)	               // unconditional absolute jump
	  ProgCtr <= Target;			   //   how would you make it conditional and/or relative?
	else if (BranchRel)   			   // conditional relative jump
	  ProgCtr <= Target + ProgCtr;	   //   how would you make it unconditional and/or absolute
	else
	  ProgCtr <= ProgCtr + 1; 	       // default increment (no need for ARM/MIPS +4 -- why?)

	// override default behavior
	if (Reset) begin
		ProgCtr <= 'd0;
		startCount <= '0;
	end else if (Start)	begin				   // hold while start asserted; commence when released
	  	if (startCount == 0)
		  ProgCtr <= 'd1; // first program starts at 1
		else if (startCount == 1)
		  ProgCtr <= 'd2; // second program starts at 2
		else if (startCount == 2)
		  ProgCtr <= 'd4; // third program starts at 4
		else
		  ProgCtr <= 'd0;
		startCount <= startCount + 1;
	end
	if (ProgCtr == 0 && Start == 0)
		ProgCtr <= ProgCtr; // stall
  end
endmodule

