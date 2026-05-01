//Module & version: fifo_syn_pointer, v1
//Fifo with pointer.
//This pointer is 'no slot wasted' pointer i.e N+1 pointer. So in our design the parameter is 16 for depth, it is a power of 2 number, so we can use 5 bits and "x XXXX" bits i.e 4 bits for index and 1 bit for rounds/laps, for depth 16, we get 2 laps. If depth is not a power of 2, this method will not work.

module fifo_syn_pointer #(parameter DATA_WIDTH =32, DEPTH = 16)
(
  output logic [DATA_WIDTH-1:0] dout,
  output logic full,
  output logic empty,
  input logic clk,
  input logic rst,
  input logic wr_en,
  input logic rd_en,
  input logic [DATA_WIDTH-1:0] din );

logic [$clog2(DEPTH):0] wr_ptr, rd_ptr;

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

logic push, pop;

assign push = wr_en && !full;
assign pop = rd_en && !empty;

always_ff @(posedge clk or negedge rst)
  begin
    if(!rst) begin
      wr_ptr <=1'b0;
      rd_ptr <=1'b0;
      dout <=1'b0; 
    end
    
    else begin

    if(push) begin
      mem[wr_ptr[$clog2(DEPTH)-1:0]] <= din;
	wr_ptr <= wr_ptr +1;
    end
    
    if (pop) begin
      dout <= mem[rd_ptr[$clog2(DEPTH)-1:0]];
    rd_ptr <= rd_ptr +1;
    end
    

  end
  end
  
  assign full = (wr_ptr[$clog2(DEPTH)] != rd_ptr[$clog2(DEPTH)]) && (wr_ptr[$clog2(DEPTH)-1:0] == rd_ptr[$clog2(DEPTH)-1:0]);
  //full = (wr_ptr[4] != rd_ptr[4]) && (wr_ptr[3:0] == rd_ptr[3:0]);
  assign empty = (wr_ptr == rd_ptr);


endmodule
