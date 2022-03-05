// CSE141L
import definitions::*;
// control decoder and register (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
module Ctrl #(parameter W=8, A=4)(
  input                Clk,
                     Reset,
  input[W:0]   Instruction,	 // machine code
  input[W-1:0] DataStore  ,
  output logic BranchUp   ,  	// branch up enable
		           BranchDown ,  	// branch down enable
              //  RegWrEn    ,	   // write to reg_file (common)
              //  MemWrEn    ,	   // write to mem (store only)
              //  LoadInst	  ,	   // mem or ALU to reg_file ?
      	      //  StoreInst  ,          // mem write enable
	             Ack        ,		   // "done w/ program"
  output  [W-1:0] DataOutA,
                  DataOutB,
                  PCTarget,
  output  [A-1:0] ALUInst
  );
 	 
  logic [W-1:0] Registers[2**A]; // W bits wide [W-1:0] and 2**4 registers deep
  logic [W-1:0] DataIn;
  logic [A-1:0] Waddr; // register to write to
  logic WriteEn;

  always_comb begin

    DataIn = DataStore;
    WriteEn = 0;

    case (Instruction[8:7])							  
      2'b00 : begin // Memory and Comparison
        case (Instruction[6:4])
          3'b000 : begin // get
          
          end
          3'b001 : begin // put
          
          end
          3'b010 : begin // lw
          
          end
          3'b011 : begin // sw
          
          end
          3'b100 : begin // seq
            DataOutA = Registers[Instruction[3:2]];
            DataOutB = Registers[Instruction[1:0]];
            ALUInst = SEQ;
            WriteEn = 1;
            Waddr = Instruction[3:2];
          end
          3'b101 : begin // sne
            DataOutA = Registers[Instruction[3:2]];
            DataOutB = Registers[Instruction[1:0]];
            ALUInst = SNE;
            WriteEn = 1;
            Waddr = Instruction[3:2];
          end
          3'b110 : begin // slt
            DataOutA = Registers[Instruction[3:2]];
            DataOutB = Registers[Instruction[1:0]];
            ALUInst = SLT;
            WriteEn = 1;
            Waddr = Instruction[3:2];
          end
        endcase
      end

      2'b01 : begin // 1 Variable
        if (Instruction[6]) begin
          DataIn = Instruction[5:0];
          WriteEn = 1;
          Waddr = 3;
        end
        else begin
          DataIn = ~Registers[Instruction[5:4]];
          WriteEn = 1;
          Waddr = Instruction[5:4];
        end
      end

      2'b10 : begin // 2 Variable
        DataOutA = Registers[Instruction[3:2]];
        DataOutB = Registers[Instruction[1:0]];
        ALUInst = {1'b0, Instruction[6:4]};
        WriteEn = 1;
        Waddr = Instruction[3:2];
      end

      2'b11 : begin // Branch
        if (Instruction[6]) begin
          if (Registers[Instruction[5:4]] == Registers[Instruction[3:2]]) begin
            PCTarget = Registers[Instruction[1:0]];
            BranchUp = 0;
            BranchDown = 1;
          end
        end
        else begin
          if (Registers[Instruction[5:4]] == Registers[Instruction[3:2]) begin
            PCTarget = Registers[Instruction[1:0]];
            BranchUp = 1;
            BranchDown = 0;
          end
        end
      end
    endcase

    // reserve instruction = 9'b111111111; for Ack
    Ack = &Instruction;

  end

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