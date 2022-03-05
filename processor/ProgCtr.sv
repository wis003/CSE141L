// Program Counter
module ProgCtr #(parameter L=10) (
  input                Reset,      	// reset, init, etc. -- force PC to 0
                       Start,      	// Signal to jump to next program 
                       Clk,        	// PC can change on pos. edges only
                       BranchUp,  	// jump to PC - PCTarget
					   BranchDown, 	// jump to PC + PCTarget
  input        [7:0] PCTarget,    // jump ... "how high?" (100 shooters - future)
  output logic [L-1:0] ProgCtr     	// the program counter register itself
  );
  
  logic [1:0] startCount;

  // program counter can clear to 0, increment, or jump
  always_ff @(posedge Clk) begin
	if (BranchUp)	               	   	// relative jump up
	  ProgCtr <= ProgCtr - PCTarget;
	else if (BranchDown)   			   	// relative jump down
	  ProgCtr <= ProgCtr + PCTarget;
	else
	  ProgCtr <= ProgCtr + 1; 	       	// default increment (no need for ARM/MIPS +4, only 1 byte increments)

	// override default behavior
	if (Reset) begin
		ProgCtr <= 'd0;
		startCount <= '0;
	end else if (Start)	begin			// hold while start asserted; commence when released
	  	if (startCount == 0)
		  ProgCtr <= 'd1; 				// first program start hardcoded
		else if (startCount == 1)
		  ProgCtr <= 'd2; 				// second program start hardcoded
		else if (startCount == 2)
		  ProgCtr <= 'd4; 				// third program start hardcoded
		else
		  ProgCtr <= 'd0;
		startCount <= startCount + 1;
	end
	if (ProgCtr == 0 && Start == 0)
		ProgCtr <= ProgCtr; // stall
  end
endmodule

