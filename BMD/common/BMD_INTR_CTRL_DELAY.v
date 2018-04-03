//--------------------------------------------------------------------------------
//--
//-- This file is owned and controlled by Xilinx and must be used solely
//-- for design, simulation, implementation and creation of design files
//-- limited to Xilinx devices or technologies. Use with non-Xilinx
//-- devices or technologies is expressly prohibited and immediately
//-- terminates your license.
//--
//-- Xilinx products are not intended for use in life support
//-- appliances, devices, or systems. Use in such applications is
//-- expressly prohibited.
//--
//--            **************************************
//--            ** Copyright (C) 2005, Xilinx, Inc. **
//--            ** All Rights Reserved.             **
//--            **************************************
//--
//--------------------------------------------------------------------------------
//-- Filename: BMD_INTR_CTRL_DELAY.v
//--
//-- Description: Endpoint Intrrupt Delay
//--
//--------------------------------------------------------------------------------

module BMD_INTR_CTRL_DELAY (
                expired,
                enable,
                simulation,
                rst,
                clk
                );

  output        expired;
  input         enable;
  input         simulation;
  input         rst;
  input         clk;


  //******************************************************************//
  // Reality check.                                                   //
  //******************************************************************//


  parameter Tc2o = 1;


  //******************************************************************//
  // Construct the counter.  One milisecond is 0x1E848 clock cycles   //
  // at 125 MHz.  Rounding this up to 0x1FFFF makes life easier and   //
  // is only 4.5% longer than an exact count.  The spec says timeout  //
  // values are minus 0% to plus 50%.  So, counting to a maximum of   //
  // "64 ms" will require a 23-bit counter.                           // 
  //******************************************************************//
 
 
  reg    [22:0] reg_count;
  wire   [22:0] ns_count;   // non-scaled count
  wire   [22:0] count;      // scaled for simulation
 
  always @ (posedge clk )
  begin : up_counter
    if (rst) reg_count <= 0;
    else if (!enable) reg_count <= 0;
    else reg_count <= ns_count + 1;
  end
 
  assign #Tc2o ns_count = reg_count;
  assign #Tc2o count = simulation ? (reg_count << 8) : reg_count;
 
 
  //******************************************************************//
  // Generate the timeout flags.  These are gated with the state      // 
  // change flag so that no timer expirations from the previous state //
  // can accidentally be seen as a timeout in the next state.         // 
  //******************************************************************//
 
 
  assign #Tc2o expired_2ms  = enable & ((|count[22:18]));
  assign #Tc2o expired_12ms = enable & ((|count[22:21]) | (&count[20:19]));
  assign #Tc2o expired_24ms = enable & ((count[22]) | (&count[21:20]));
  assign #Tc2o expired_48ms = enable & ((&count[22:21]));

  assign #Tc2o expired = expired_2ms;


  //******************************************************************//
  //                                                                  //
  //******************************************************************//


endmodule
