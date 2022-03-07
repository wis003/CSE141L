import definitions::*;

// control decoder + register
// module talks between instROM, ALU, DataMem, and ProgCtr
module CtrlReg #(parameter W=8, A=4)(
  input                Clk,
                     Reset,
  input [W:0]   Instruction,      // machine code
  input [W-1:0] ALUData,          // data to store from ALU
  input [W-1:0] MemData,          // data to store from mem
  output logic BranchUp,  	      // branch up enable
		           BranchDown,  	    // branch down enable
               MemWrite,	        // write to mem
	             Ack,               // done logic
  output logic [W-1:0] DataOutA,
                       DataOutB,
                       PCTarget,
  output logic [A-1:0] ALUInst
  );
 	 
  logic [W-1:0] Registers[2**A]; // W bits wide [W-1:0] and 2**4 registers deep
  logic [W-1:0] DataIn;
  logic [A-1:0] Waddr; // register to write to
  logic WriteEn;

  always_comb begin

    // defaults
    BranchUp = 0;
    BranchDown = 0;
    MemWrite = 0;
    WriteEn = 0;
    DataIn = ALUData;
    Ack = &Instruction; // reserve instruction = 9'b111111111 for Ack

    DataOutA = 0;
    DataOutB = 0;
    PCTarget = 0;
    ALUInst = 0;
    Waddr = 0;
    
    case (Instruction[8:7])							  
      2'b00 : begin // Memory and Comparison

        DataOutA = Registers[Instruction[3:2]];
        DataOutB = Registers[Instruction[1:0]];
        WriteEn = 1;
        Waddr = Instruction[3:2];

        case (Instruction[6:4])
          3'b000 : begin // get
            DataIn = Registers[Registers[Instruction[1:0]]]; // DataIn here is essentially pointer to pointer
            Waddr = Instruction[3:2];
          end
          3'b001 : begin // put
            DataIn = Registers[Instruction[1:0]];
            Waddr = Registers[Instruction[3:2]]; // Waddr here is essentially pointer to pointer
          end
          3'b010 : begin // lw
            DataIn = MemData;
          end
          3'b011 : begin // sw
            MemWrite = 1;
            WriteEn = 0;
          end
          3'b100 : begin // seq
            ALUInst = SEQ;
          end
          3'b101 : begin // sne
            ALUInst = SNE;
          end
          3'b110 : begin // slt
            ALUInst = SLT;
          end
        endcase
      end

      2'b01 : begin // 1 Variable
        if (Instruction[6]) begin // not
          DataIn = ~Registers[Instruction[5:4]];
          WriteEn = 1;
          Waddr = Instruction[5:4];
        end
        else begin // set
          DataIn = Instruction[5:0];
          WriteEn = 1;
          Waddr = 3;
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
        if (Instruction[6]) begin // b_down
          if (Registers[Instruction[5:4]] == Registers[Instruction[3:2]]) begin
            PCTarget = Registers[Instruction[1:0]];
            BranchDown = 1;
          end
        end
        else begin // b_up
          if (Registers[Instruction[5:4]] == Registers[Instruction[3:2]]) begin
            PCTarget = Registers[Instruction[1:0]];
            BranchUp = 1;
          end
        end
      end
    endcase
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