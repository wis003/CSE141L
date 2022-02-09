// InstROM
// read machine code into memory, access instruction via InstAddress, instruction is output
module InstROM #(parameter A=10, W=9) (
  input       [A-1:0] InstAddress,
  output logic[W-1:0] InstOut);

  // declare 2-dimensional array, W bits wide, 2**A words deep
  logic[W-1:0] inst_rom[2**A];
  always_comb InstOut = inst_rom[InstAddress];

  // Load instruction memory from external file
  initial begin
      $readmemb("C:/Users/18587/Desktop/UCSD/Classes/CSE 141L/CSE141L/program_impls/machine_code.txt", inst_rom);
  end 
  
endmodule