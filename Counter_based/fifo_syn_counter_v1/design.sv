//Module & version: fifo_syn_counter, v1 
//Counter based Synchoronous FIFO(First In First Out), V1
//Description: This method tracks exact fill of the fifo buffer with a 'count' register.
//Latency: 1 clock cycle

module fifo_syn_counter #(parameter DATA_WIDTH =32, DEPTH = 16)
(
  output logic [DATA_WIDTH-1:0] dout,
  output logic full,
  output logic empty,
  input logic clk,
  input logic rst,
  input logic wr_en,
  input logic rd_en,
  input logic [DATA_WIDTH-1:0] din );

logic [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;
logic [$clog2(DEPTH+1)-1:0] count;

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

int push_cnt, pop_cnt;

logic push, pop;

assign push = wr_en && !full;
assign pop = rd_en && !empty;

always_ff @(posedge clk or negedge rst)
  begin
    if(!rst) begin
      wr_ptr <=1'b0;
      rd_ptr <=1'b0;
      dout <=1'b0; 
      count <= 5'b0;
      push_cnt <= 1'b0;
      pop_cnt <= 1'b0;
    end
    
    else begin

    if(push) begin
    mem[wr_ptr] <= din;
	wr_ptr <= wr_ptr +1;
    push_cnt <=push_cnt +1;
    end
    
    if (pop) begin
    dout <= mem[rd_ptr];
    rd_ptr <= rd_ptr +1;
    pop_cnt <= pop_cnt +1;
    end
    
    if (push && !pop)
      count <= count + 1;
    else if (pop && !push) 
      count <= count - 1;
    else
          count <= count;

  end
  end
  
  assign full = (count == DEPTH);
  assign empty = (count == 0);


endmodule
