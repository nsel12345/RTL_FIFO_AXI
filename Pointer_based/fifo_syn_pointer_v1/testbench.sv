//The testbench is same as fifo_syn_counter_v3, but i changed some naming to match pointer design.

//One thing that was noticed after running this is that 'full' is not tested, all through the waveform full is never high. So will create fifo_syn_pointer_v2, in which i will add 'random constraints in generator, to check this feature.

`include "fifo_if.sv"

//Transaction class
class transaction #(parameter DATA_WIDTH = 32);
  rand bit [DATA_WIDTH-1:0] din;
  rand bit wr_en;
  rand bit rd_en;
  
  // using bit instead of logic gives only two states 0 and 1, but i used logic here, can fix later if needed, logic has 4 states.
  logic [DATA_WIDTH-1:0] dout; 
  logic full;
  logic empty;
  
  function void display(string name);
    $display("[%s] inputs: wr_en= %0d, rd_en= %0d, din= %0d | outputs: dout= %0d, full= %0d, empty= %0d", name, wr_en, rd_en, din, dout, full, empty );
    
  endfunction
  
endclass

//Generator class: creates transcations, randomize them & put them in a mailbox for the Driver.

class generator;
  transaction tr;
  mailbox mb;
  
  // creating constructor:
  function new(mailbox mb);
    this.mb = mb;
  endfunction
  
  task run();
    
    bit [31:0] prev_din;
    
    for (int i=0; i<61; i++) begin
      tr = new(); //construct 
    tr.randomize(); // randomize
      
      if(tr.wr_en == 0) begin
        tr.din = prev_din; //overwritten random garbage with previous din, this helps din keep only required data and no random data is produced.
      end else begin
        prev_din = tr.din; 
      end
      
    tr.display("Genrator"); //print
    mb.put(tr); // send it
    end
  endtask
endclass

//Driver class

class driver;
  transaction tr;
  mailbox mb;
  virtual fifo_if vif; //virtual interface
  
  //constructor to connect mailbox and interface
  function new(mailbox mb, virtual fifo_if vif);
    this.mb = mb;
    this.vif = vif;
  endfunction
  
  task run();  // driver runs continuously so we put a forever begin loop inside this.
    
    forever begin
      @(vif.cb); // wait for the clock edge using the clock block
     
      if (mb.try_get(tr)) begin // grab next transaction
        vif.cb.wr_en <= tr.wr_en; //pins from transactions are driven using non-blocking statement to sync them to work at clock edges
      vif.cb.rd_en <= tr.rd_en;
      vif.cb.din <= tr.din;
      tr.display("Driver"); //printing the data at driver
      end
      else begin
        vif.cb.wr_en <= 0;
        vif.cb.rd_en <= 0;
      end
      
    end
  endtask
endclass

//Monitor class

class monitor;
  transaction tr;
  mailbox mb; // this will be monitor -to scoreboard mailbox
  virtual fifo_if vif;
  
  //constructor to connect mailbox and interface
  
  function new(mailbox mb, virtual fifo_if vif);
    this.mb = mb;
    this.vif = vif;
  endfunction
  
  task run();
    forever begin
      @(vif.cb); //wait for clock edge
      tr = new(); //construct new transaction to hold sampled data
      //sample all the signals drove & outputs
      // we use = because we only read and don't need to remember the state
      
      tr.wr_en = vif.wr_en;
      tr.rd_en = vif.rd_en;
      tr.din = vif.din;
      tr.dout = vif.cb.dout;
      tr.full = vif.cb.full;
      tr.empty = vif.cb.empty;
      
      tr.display("Monitor"); //print monitor values
      
      mb.put(tr); // we put it mailbox that runs from monitor to scoreboard
    end
  endtask
  
endclass
      
//Scoreboard class

class scoreboard;
  mailbox mb; // to receive transactions from monitor
  transaction tr;
  bit [31:0] expected_fifo [$];
  bit [31:0] expected_data;
  
  bit read_pending;
  
  //creating constructor
  function new(mailbox mb);
     this.mb = mb;
   endfunction
               
     task run();
       forever begin
         mb.get(tr); //get transaction from monitor
         
         //compare
         if(read_pending) begin
           if (expected_data == tr.dout) begin
             $display("Scoreboard Pass! Expected= %0d, Received= %0d", expected_data, tr.dout);
           end
            else begin
              $display("Scoreboard Error! Expected= %0d, Received= %0d", expected_data, tr.dout);
            end
           read_pending = 0; // clear
         end
         
         //write
         if (tr.wr_en && !tr.full) begin
          expected_fifo.push_back(tr.din);
           $display("Scoreboard Pushed %0d into reference queue", tr.din);
         end
                   
         //read
         if (tr.rd_en && !tr.empty) begin
           expected_data = expected_fifo.pop_front();
           read_pending = 1;
         end
         
       end
       
     endtask
  
endclass
                                
//Environment class

class environment;
  
  //four classes and their declaration
  generator gen;
  driver drv;
  monitor mon;
  scoreboard scb;
  
  //Declaring two mailboxes that we need that work in different classes
  //1. mailbox from genrator to driver
  //2. mailbox from monitor to scoreboard
  
  mailbox gen_to_drv;
  mailbox mon_to_scb;
  
  //Declaring virtual interface for driver to connect to physical interface
  virtual fifo_if vif;
  
    //creating a constructor for virtual interface
  function new(virtual fifo_if vif);
    this.vif = vif; //saving this interface
    gen_to_drv = new(); //build the mailboxes
    mon_to_scb = new();
    
   //build the components that pass correct mailboxes and interfaces
    gen = new(gen_to_drv);
    drv = new(gen_to_drv, vif);
    mon = new(mon_to_scb, vif);
    scb = new(mon_to_scb);
  endfunction
  
  task run();
    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join_any
  endtask
endclass


//Top testbench module

module tb_fifo_syn_pointer;
  parameter DATA_WIDTH = 32;
  parameter DEPTH =16;

 logic clk;
 logic rst;
  
  always #5 clk = ~clk;
  
  //physical interface-pif; virtual interface-vif
  fifo_if pif(.clk(clk), .rst(rst)); // instansiate fifo_if interface module
  
  //DUT instatiation and we also plug pins from interface module to this DUT
   
  fifo_syn_pointer #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) dut ( .dout(pif.dout), .full(pif.full), .empty(pif.empty), .clk(clk), .rst(rst), .wr_en(pif.wr_en), .rd_en(pif.rd_en), .din(pif.din));
  
  //Environment instantiation
  environment env;
  
  //Testing block
  initial 
    begin
      
      $dumpfile("dump.vcd");
      $dumpvars(0, tb_fifo_syn_pointer);
  
  clk = 0;
  rst = 0;
  //builing env and passing this to physical interface(pif)
  env = new(pif); // initilizing this at time = 0, so we load everything before reset.
      
  #10 rst = 1;
  //run the test now
  env.run();
  
  #700; // an approx delay to allow driver to finish emptying the mailbox
  
  $finish;
  
    end
  
endmodule

