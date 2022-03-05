// Data Memory: uses single address pointer for both read and write
module DataMem #(parameter W=8, A=8)  (
  input                 Clk,
                        Reset,
                        WriteEn,
  input       [A-1:0]   DataAddress,  // A-bit-wide pointer to 256-deep memory
  input       [W-1:0]   DataIn,		    // W-bit-wide data path, also
  output logic[W-1:0]   DataOut);

  logic [W-1:0] Core[2**A];			      // 8x256 two-dimensional array -- the memory itself
                   
  Load the initial contents of memory
  initial begin
    $readmemh("C:/Users/18587/Desktop/UCSD/Classes/CSE 141L/CSE141L/program_impls/data_mem/data_mem_00-initial.hex", Core);
  end
  
  assign DataOut = Core[DataAddress]; // reads are combinational

  always_ff @ (posedge Clk) begin		 // writes are sequential
    if (WriteEn)
      Core[DataAddress] <= DataIn;
  end  

endmodule
