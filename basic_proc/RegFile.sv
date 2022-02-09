// RegFile

/* parameters are compile time directives 
       this can be an any-width, any-depth reg_file: just override the params!
*/
module RegFile #(parameter W=8, A=4)(		 // W = data path width (leave at 8); A = address pointer width
  input                Clk,
                       Reset,
                       WriteEn,
  input        [A-1:0] RaddrA,				 // address pointers
                       RaddrB,
                       Waddr,
  input        [W-1:0] DataIn,
  output       [W-1:0] DataOutA,			 // showing two different ways to handle DataOutX, for
  output logic [W-1:0] DataOutB				 //   pedagogic reasons only
    );

// W bits wide [W-1:0] and 2**4 registers deep 	 
logic [W-1:0] Registers[2**A];	             // or just registers[16] if we know A=4 always

// combinational reads 
/* can write always_comb in place of assign
    difference: assign is limited to one line of code, so
	always_comb is much more versatile     
*/
assign      DataOutA = Registers[RaddrA];	 // 
always_comb DataOutB = Registers[RaddrB];    // can read from addr 0, just like ARM

// sequential (clocked) writes 
always_ff @ (posedge Clk) begin
  if (Reset) begin
    Registers[0] <= '0;
    Registers[1] <= '0;
    Registers[2] <= '0;
    Registers[3] <= '0;
    Registers[4] <= '0;
    Registers[5] <= '0;
    Registers[6] <= '0;
    Registers[7] <= '0;
    Registers[8] <= '0;
    Registers[9] <= '0;
    Registers[10] <= '0;
    Registers[11] <= '0;
    Registers[12] <= '0;
    Registers[13] <= '0;
    Registers[14] <= '0;
    Registers[15] <= '0;
  end else if (WriteEn) begin	                             // works just like data_memory writes
    Registers[Waddr] <= DataIn;
  end
end

endmodule
