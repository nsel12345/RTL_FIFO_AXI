//FWFT= first word fall through
//Axi

`include "fifo_syn_pointer.sv"

module fifo_syn_pntr_axi_fwft #(parameter DATA_WIDTH = 32, DEPTH = 16)
  (
  output logic [DATA_WIDTH-1:0] m_tdata,
  output logic s_tready,
  output logic m_tvalid,
  input logic clk,
  input logic rst,
  input logic s_tvalid,
  input logic m_tready,
    input logic [DATA_WIDTH-1:0] s_tdata );
  
  logic native_full, native_empty;
  logic native_wr_en, native_rd_en;
  
  logic [DATA_WIDTH-1:0] native_dout;
  
  //instantiate native fifo (fifo_syn_pointer)
  // clock, reset, din=s_data connected directly
  // wire changes are for control pins, dout to internal wires
   
  fifo_syn_pointer #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) dut ( .dout(native_dout), .full(native_full), .empty(native_empty), .clk(clk), .rst(rst), .wr_en(native_wr_en), .rd_en(native_rd_en), .din(s_tdata));
  
  //In axi stream FIFO, subordinate is ready as long as the internal FIFO  isn't full
  assign s_tready = !native_full;
  
  //In axi wr_en = 1 if s_valid = 1 and s_ready = 1
  assign native_wr_en = s_tvalid && s_tready;
  assign native_rd_en = !native_empty && (!fwft_valid || m_tready);
  
  logic fwft_valid;
  
  // read logic, main part:
  assign m_tvalid = fwft_valid;
  assign m_tdata = native_dout;
  
  always_ff @(posedge clk or negedge rst)
    begin
      if(!rst) begin
        fwft_valid <= 1'b0;
      end
      else begin
        if (native_rd_en) begin
          fwft_valid <= 1'b1;
        end
        else if (m_tready) begin
          fwft_valid <= 1'b0;
        end
      end
    end
  
endmodule 
  
  
  