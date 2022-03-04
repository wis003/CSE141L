// RegFile

// any-depth `reg_file`: just override the params!
//   W = data path width          <-- [WI22 Requirement: max(W) = 8]
//   A = address pointer width    <-- [WI22 Requirement: max(A) = 4]
module RegFile #(parameter W=8, A=4)(		 // W = data path width (leave at 8); A = address pointer width
  input                Clk,
                       Reset,
                       WriteEn,
  input        [A-1:0] RaddrA,				 // address pointers
                       RaddrB,
                       Waddr,
  input        [W-1:0] DataIn,
  output       [W-1:0] DataOutA,			 // showing two different ways to handle DataOutX, for
  output logic [W-1:0] DataOutB				 // pedagogic reasons only
    );

// W bits wide [W-1:0] and 2**4 registers deep 	 
logic [W-1:0] Registers[2**A];	             // or just registers[16] if we know A=4 always

// combinational reads 
assign DataOutA = Registers[RaddrA];
assign DataOutB = Registers[RaddrB];

// sequential (clocked) writes 
always_ff @ (posedge Clk) begin
  integer i;
  if (Reset) begin
    for (i = 0; i < 2**A; i = i + 1) begin
      Registers[i] <= '0;
    end
  end else if (WriteEn) begin
    Registers[Waddr] <= DataIn;
  end
end

endmodule
