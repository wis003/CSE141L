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
  
  logic [1:0] StartCount;
  logic start_r;

  // program counter can clear to 0, increment, or jump
  always_ff @(posedge Clk) begin
	if (BranchUp)	               	   	// relative jump up
	  ProgCtr <= ProgCtr - PCTarget;
	else if (BranchDown)   			   	// relative jump down
	  ProgCtr <= ProgCtr + PCTarget;
	else
	  ProgCtr <= ProgCtr + 1; 	       	// default increment (no need for ARM/MIPS +4, only 1 byte increments)

	// Handle the Start signal by overriding normal behavior
	if (Reset) begin
		StartCount <= '0;
		start_r <= '0;
	end 
	else begin
		start_r <= Start;
		// Detect rising edge of Start
		if ((start_r == '0) && (Start == '1)) begin
			StartCount <= StartCount + 1'b1;
		end
		// Detect falling edge of Start
		if ((start_r == '1) && (Start == '0)) begin
			case (StartCount)
				1: ProgCtr <= 'd000;
				2: ProgCtr <= 'd190;
				// 3: ProgCtr <= 'd200;
				default: ProgCtr <= ProgCtr;
			endcase
		end
		// And generally, don't let things go anywhere until first Start
		if (StartCount == '0)
		ProgCtr <= ProgCtr;
	end
  end
endmodule

