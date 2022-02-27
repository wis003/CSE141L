// TEST BENCH
// ALU

`timescale 1ns/ 1ps

module ALU_tb;
  logic [7:0] InputA;        // data inputs
  logic [7:0] InputB;
  logic [3:0] OP;  // ALU opcode, part of microcode
  bit SC_in = 'b0;
  wire  [7:0] Out;
  wire Zero;
  wire Parity;
  wire Odd;
  logic [7:0] expected;

  // CONNECTION
  ALU uut(
    .InputA,
    .InputB,
    .SC_in,
    .OP,
    .Out,
    .Zero,
    .Parity,
    .Odd
      );

  initial begin

  InputA = 4;
  InputB = 1;

  OP= 'd0;
  test_alu_func;
  #5;

  OP= 'd1;
  test_alu_func;
  #5;

  OP= 'd2;
  test_alu_func;
  #5;

  OP= 'd3;
  test_alu_func;
  #5;

  OP= 'd4;
  test_alu_func;
  #5;

  OP= 'd5;
  test_alu_func;
  #5;

  OP= 'd6;
  test_alu_func;
  #5;

  OP= 'd7;
  test_alu_func;
  #5;

  OP= 'd8;
  test_alu_func;
  #5;

  end

  task test_alu_func;
    begin
      case (OP)
        0 : expected = InputA + InputB;        // add
        1 : expected = InputA - InputB;        // sub
        2 : expected = InputA & InputB;        // bitwise AND
        3 : expected = InputA | InputB;        // bitwise OR
        4 : expected = ^(InputB);              // reduction XOR
        5 : expected = InputA << InputB;       // shift left
        6 : expected = InputA >> InputB;       // shift right
        7 : expected = InputA == InputB;       // equals
        8 : expected = InputA < InputB;        // less than
      endcase

      #1; if (expected == Out)
            begin
              $display("%t YAY!! inputs = %h %h, OPcode = %b, Zero %b", $time, InputA, InputB, OP, Zero);
            end
          else begin $display("%t FAIL! inputs = %h %h, OPcode = %b, zero %b", $time, InputA, InputB, OP, Zero); end

    end
  endtask

endmodule