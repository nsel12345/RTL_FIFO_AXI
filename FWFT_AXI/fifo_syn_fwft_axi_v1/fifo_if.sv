interface fifo_if #(parameter DATA_WIDTH = 32) (
  				  input logic clk,
                  input logic rst);
  // connects tectbench to DUT
  logic [DATA_WIDTH-1:0] m_tdata;
  logic s_tready;
  logic m_tvalid;
  logic s_tvalid;
  logic m_tready;
  logic [DATA_WIDTH-1:0] s_tdata;
  
  //Defining clocking bloack for the testbench
  
  clocking cb @(posedge clk);
    default input #1step output #1ns; // Sample just befor edge,         drive just after
    
    //testbecnh drives these to the design
    output s_tvalid;
  	output m_tready;
  	output s_tdata;
    
    // testbench samples these from the design
    input m_tdata;
    input s_tready;
    input m_tvalid;
  endclocking
  
endinterface

