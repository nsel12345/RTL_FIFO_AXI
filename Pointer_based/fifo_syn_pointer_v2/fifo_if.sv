interface fifo_if #(parameter DATA_WIDTH = 32) (
  				  input logic clk,
                  input logic rst);
  // connects tectbench to DUT
  logic [DATA_WIDTH-1:0] dout;
  logic full;
  logic empty;
  logic wr_en;
  logic rd_en;
  logic [DATA_WIDTH-1:0] din;
  
  //Defining clocking bloack for the testbench
  
  clocking cb @(posedge clk);
    default input #1step output #1ns; // Sample just befor edge,         drive just after
    
    //testbecnh drives these to the design
    output wr_en;
  	output rd_en;
  	output din;
    
    // testbench samples these from the design
    input dout;
    input full;
    input empty;
  endclocking
  
endinterface

