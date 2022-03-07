// Data Memory: uses single address pointer for both read and write
module DataMem #(parameter W=8, A=8)  (
  input                 Clk,
                        Reset,
                        WriteEn,
  input        [A-1:0]   DataA, // $t in MEM[$t] = $s
  input        [W-1:0]   DataB, // $s in both $t = MEM[$s] and MEM[$t] = $s
  output logic [W-1:0]   DataOut
  );

  logic [W-1:0] Core[2**A];			      // 8x256 two-dimensional array -- the memory itself
                   
  // Load the initial contents of memory
  initial begin
    $readmemh("C:/Users/18587/Desktop/UCSD/Classes/CSE 141L/CSE141L/program_impls/data_mem/data_mem_04-initial.hex", Core);
  end
  
  assign DataOut = Core[DataB]; // reads are combinational

  always_ff @ (posedge Clk) begin		 // writes are sequential
    if (WriteEn)
      Core[DataA] <= DataB;
  end  

endmodule
