// W is data path width (8 bits)
// byte count = number of "words" (bytes) in reg_file
//   or data_memory
module top_level #(parameter W=8,
                   byte_count = 256)(
  input        clk, 
               init,	           // req. from test bench
  output logic done);	           // ack. to test bench

// memory interface = 
//   write_en, raddr, waddr, data_in, data_out: 
  logic write_en;                  // store enable for dat_mem

// address pointers for reg_file/data_mem
  logic[$clog2(byte_count)-1:0] raddr, waddr;

// data path connections into/out of reg file/data mem
  logic[W-1:0] data_in;
  wire [W-1:0] data_out; 

/* instantiate data memory (reg file)
   Here we can override the two parameters, if we 
     so desire (leaving them as defaults here) */
  dat_mem #(.W(W),.byte_count(byte_count)) 
    dm1(.*);		               // reg_file or data memory


// program counter: bits[6:3] count passes through for loop/subroutine
// bits[2:0] count clock cycles within subroutine (I use 5 out of 8 possible, pad w/ 3 no ops)
  logic[ 6:0] count;
  logic[ 8:0] parity;
  logic[15:0] temp1, temp2, temp_working;
  logic       temp1_enh, temp1_enl, temp2_en, temp3_en;
  logic       p8, p4, p2, p1, p0;
  logic[ 3:0] casenum;

  always_comb begin

    // hamming code
    parity[8] = ^temp1[15:9];
    parity[4] = (^temp1[15:12])^(^temp1[7:5]); 
    parity[2] = temp1[15]^temp1[14]^temp1[11]^temp1[10]^temp1[7]^temp1[6]^temp1[3];
    parity[1] = temp1[15]^temp1[13]^temp1[11]^temp1[9]^temp1[7]^temp1[5]^temp1[3];
    parity[0] = ^temp1[15:1];

    // check for equality
    p8 = (parity[8] == temp1[8]);
    p4 = (parity[4] == temp1[4]);
    p2 = (parity[2] == temp1[2]);
    p1 = (parity[1] == temp1[1]);
    p0 = (parity[0] == temp1[0]);
    casenum = {p8, p4, p2, p1};

    // error detection
    if(p0 && casenum < 15) temp_working = 'b1000_0000_0000_0000; // two errors
    else if(!p0 && casenum == 15) temp_working = {5'b01000, temp1[15:9], temp1[7:5], temp1[3]}; // p0
    else begin
      case(casenum)
        0:  temp_working = {5'b01000, !temp1[15], temp1[14:9], temp1[7:5], temp1[3]}; // b11
        1:  temp_working = {5'b01000, temp1[15], !temp1[14], temp1[13:9], temp1[7:5], temp1[3]}; // b10
        2:  temp_working = {5'b01000, temp1[15:14], !temp1[13], temp1[12:9], temp1[7:5], temp1[3]}; // b9
        3:  temp_working = {5'b01000, temp1[15:13], !temp1[12], temp1[11:9], temp1[7:5], temp1[3]}; // b8
        4:  temp_working = {5'b01000, temp1[15:12], !temp1[11], temp1[10:9], temp1[7:5], temp1[3]}; // b7
        5:  temp_working = {5'b01000, temp1[15:11], !temp1[10], temp1[9], temp1[7:5], temp1[3]}; // b6
        6:  temp_working = {5'b01000, temp1[15:10], !temp1[9], temp1[7:5], temp1[3]}; // b5

        7:  temp_working = {5'b01000, temp1[15:9], temp1[7:5], temp1[3]}; // p8

        8:  temp_working = {5'b01000, temp1[15:9], !temp1[7], temp1[6:5], temp1[3]}; // b4
        9:  temp_working = {5'b01000, temp1[15:9], temp1[7], !temp1[6], temp1[5], temp1[3]}; // b3
        10: temp_working = {5'b01000, temp1[15:9], temp1[7:6], !temp1[5], temp1[3]}; // b2

        11: temp_working = {5'b01000, temp1[15:9], temp1[7:5], temp1[3]}; // p4

        12: temp_working = {5'b01000, temp1[15:9], temp1[7:5], !temp1[3]}; // b1

        13: temp_working = {5'b01000, temp1[15:9], temp1[7:5], temp1[3]}; // p2
        14: temp_working = {5'b01000, temp1[15:9], temp1[7:5], temp1[3]}; // p1

        default: temp_working = {5'b00000, temp1[15:9], temp1[7:5], temp1[3]}; // no errors
      endcase
    end

  end
  

  always @(posedge clk)
    if(init) begin
      count <= 0;
      temp1 <= 'b0;
      temp2 <= 'b0;
    end
    else begin
      count                     <= count + 1;
      if(temp1_enh) temp1[15:8] <= data_out;
      if(temp1_enl) temp1[ 7:0] <= data_out;
      if(temp2_en)  temp2       <= temp_working;
    end  

  always_comb begin
// defaults  
    temp1_enl        = 'b0;
    temp1_enh        = 'b0;
    temp2_en         = 'b0;
    raddr            = 'b0;
    waddr            = 'b0;
    write_en         = 'b0;
    data_in          = temp2[7:0];   
    case(count[2:0])
      1: begin                  // step 1: load from data_mem into lower byte of temp1
          raddr = 2*count[6:3] + 64;
          temp1_enl = 'b1;
      end  
      2: begin                  // step 2: load from data_mem into upper byte of temp1
          raddr = 2*count[6:3] + 65;
          temp1_enh = 'b1;
      end
      3: temp2_en    = 'b1;     // step 3: copy in output
      4: begin                  // step 4: store from one byte of temp3 into data_mem 
          write_en = 'b1;
          waddr = 2*count[6:3] + 94;
          data_in = temp2[7:0];
      end
      5: begin
          write_en = 'b1;      // step 5: store from other byte of temp3 into data_mem
          waddr = 2*count[6:3] + 95;
          data_in = temp2[15:8];
      end
    endcase
  end

// automatically stop at count 127; 120 might be even better (why?)
  assign done = &count;

endmodule