// TEST BENCH
// Instruction Fetch, including ProgCtr and InstROM

`timescale 1ns/ 1ps

module InstructionFetch_tb;

bit Reset;
bit Start;
bit Clk;
bit BranchRel;
bit BranchAbs;
bit ALU_flag;
bit [9:0] Target;
logic [9:0] ProgCtr;

ProgCtr uut1 (
    .Reset,
    .Start,
    .Clk,
    .BranchRel,
    .BranchAbs,
    .ALU_flag,
    .Target,
    .ProgCtr
);

logic [8:0] InstOut;

InstROM uut2 (
    .InstAddress (ProgCtr),
    .InstOut
);

initial begin
    // time 0 values
    Reset = 1'b1;
    Start = '0;
    Clk = '0;
    BranchRel = '0;
    BranchAbs = '0;
    ALU_flag = '0;
    Target = '0; // 32-bit wide "0"

    // advance 1
    #1 Clk = '1;
    #1 Clk = '0;

    $display("Check Reset");
    assert (ProgCtr == 'd0);
    Reset = 1'b0;

    // advance 1
    #1 Clk = '1;
    #1 Clk = '0;

    $display("Check nothing happens before Start");
    assert (ProgCtr == 'd0);
    Start = '1;

    // advance 1
    #1 Clk = '1;
    #1 Clk = '0;

    $display("Check first program was loaded");
    assert (InstOut == 9'b011011100);
    Start = '0;

    // advance 1
    #1 Clk = '1;
    #1 Clk = '0;

    Start = '1;

    // advance 1
    #1 Clk = '1;
    #1 Clk = '0;

    $display("Check second program was loaded");
    assert (InstOut == 9'b000001011);
    Start = '0;

    // advance 1
    #1 Clk = '1;
    #1 Clk = '0;

    Start = '1;

    // advance 1
    #1 Clk = '1;
    #1 Clk = '0;

    $display("Check third program was loaded");
    assert (InstOut == 9'b110001000);

end

endmodule