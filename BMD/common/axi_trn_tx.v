//-----------------------------------------------------------------------------
//
// (c) Copyright 2009-2011 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : Series-7 Integrated Block for PCI Express
// File       : axi_trn_tx.v
// Version    : 1.1
//----------------------------------------------------------------------------//
//  File: axi_trn_tx.v                                                        //
//                                                                            //
//  Description:                                                              //
//  TRN to AXI TX module.                                                     //
//                                                                            //
//  Notes:                                                                    //
//  Optional notes section.                                                   //
//                                                                            //
//  Hierarchical:                                                             //
//    axi_trn_top                                                             //
//      axi_trn_tx                                                            //
//                                                                            //
//----------------------------------------------------------------------------//

`timescale 1ps/1ps

module axi_trn_tx #(
  parameter C_DATA_WIDTH = 64,            // RX/TX interface data width
  parameter C_FAMILY = "X7",              // Targeted FPGA family
  parameter C_ROOT_PORT = "FALSE",        // PCIe block is in root port mode
  parameter C_PM_PRIORITY = "FALSE",      // Disable TX packet boundary thrtl
  parameter TCQ = 1,                      // Clock to Q time

  // Do not override parameters below this line
  parameter REM_WIDTH  = (C_DATA_WIDTH == 128) ? 2 : 1, // trem/rrem width
  parameter KEEP_WIDTH = C_DATA_WIDTH / 8               // TKEEP width
  ) (
  //---------------------------------------------//
  // User Design I/O                             //
  //---------------------------------------------//

  // AXI TX
  //-----------
  output   [C_DATA_WIDTH-1:0] s_axis_tx_tdata,        // TX data from user
  output                      s_axis_tx_tvalid,       // TX data is valid
  input                       s_axis_tx_tready,       // TX ready for data
  output     [KEEP_WIDTH-1:0] s_axis_tx_tkeep,        // TX strobe byte enables
  output                      s_axis_tx_tlast,        // TX data is last
  output                [3:0] s_axis_tx_tuser,        // TX user signals


  //---------------------------------------------//
  // PCIe Block I/O                              //
  //---------------------------------------------//

  // TRN TX
  //-----------
  input [C_DATA_WIDTH-1:0] trn_td,                  // TX data from block
  input                    trn_tsof,                // TX start of packet
  input                    trn_teof,                // TX end of packet
  input                    trn_tsrc_rdy,            // TX source ready
  output                   trn_tdst_rdy,            // TX destination ready
  input                    trn_tsrc_dsc,            // TX source discontinue
  input    [REM_WIDTH-1:0] trn_trem,                // TX remainder
  input                    trn_terrfwd,             // TX error forward
  input                    trn_tstr,                // TX streaming enable
  input                     trn_lnk_up,             // PCIe link up


  // System
  //-----------
  input                     user_clk,                // user clock from block
  input                     user_rst                 // user reset from block
  );



// Wires and regs for creating AXI signals


wire   [KEEP_WIDTH-1:0] tkeep;
reg                     trn_in_packet;



//----------------------------------------------------------------------------//
// Create TDATA                                                               //
//----------------------------------------------------------------------------//

// Convert TRN data format to AXI data format. AXI is DWORD swapped from TRN
// 128-bit:                 64-bit:                  32-bit:
// TRN DW0 maps to AXI DW3  TRN DW0 maps to AXI DW1  TNR DW0 maps to AXI DW0
// TRN DW1 maps to AXI DW2  TRN DW1 maps to AXI DW0
// TRN DW2 maps to AXI DW1
// TRN DW3 maps to AXI DW0
generate begin : s_axis_tdata
  if(C_DATA_WIDTH == 128) begin : td_DW_swap_128
    assign s_axis_tx_tdata    = {trn_td[31:0],
                                trn_td[63:32],
                                trn_td[95:64],
                                trn_td[127:96]};
  end
  else if(C_DATA_WIDTH == 64) begin : td_DW_swap_64
    assign s_axis_tx_tdata    = {trn_td[31:0], trn_td[63:32]};
  end
  else if(C_DATA_WIDTH == 32) begin : td_DW_swap_32
    assign s_axis_tx_tdata = trn_td;
  end
end  
endgenerate




//----------------------------------------------------------------------------//
// Create TVALID, TLAST, TKEEP, TUSER                                         //
//----------------------------------------------------------------------------//
    assign s_axis_tx_tvalid = trn_tsrc_rdy ||
                             (trn_tsrc_dsc && trn_in_packet);
    assign s_axis_tx_tlast  = trn_teof;
    assign s_axis_tx_tkeep  = tkeep;
    assign s_axis_tx_tuser  = {trn_tsrc_dsc,
                              1'b0, //trn_tstr, 
                              trn_terrfwd,
                              1'b0};       



//----------------------------------------------------------------------------//
// Create TKEEP                                                               //
// ------------                                                               //
// Convert RREM to KEEP. Here, we are converting the encoding method for the  //
// location of the EOF from TRN flavor (rrem) to AXI (TKEEP).                 //
//                                                                            //
// NOTE: for each configuration, we need two values of TKEEP, the current and //
//       previous values. The need for these two values is described below.   //
//----------------------------------------------------------------------------//
generate begin : s_axis_tkeep
  if(C_DATA_WIDTH == 128) begin : trem_to_tkeep_128
    assign tkeep      = (trn_trem[1:0] == 2'b11) ? 16'hFFFF : 
                        (trn_trem[1:0] == 2'b10) ? 16'h0FFF :
                        (trn_trem[1:0] == 2'b01) ? 16'h00FF :
                        (trn_trem[1:0] == 2'b00) ? 16'h000F : 0 ;
                        
  end
  else if(C_DATA_WIDTH == 64) begin : trem_to_tkeep_64
    // 64-bit interface: contains 2 DWORDs per cycle, for a total of 8 bytes
    //  - TKEEP has only two possible values here, 0xFF or 0x0F
    assign tkeep      = trn_trem      ? 8'hFF : 8'h0F;
  end
  else begin : trem_to_tkeep_32
    // 32-bit interface: contains 1 DWORD per cycle, for a total of 4 bytes
    //  - TKEEP is always 0xF in this case, due to the nature of the PCIe block
    assign tkeep      = 4'hF;
  end
 end  
endgenerate



//----------------------------------------------------------------------------//
// Create trn_tdst_rdy                                                        //
//----------------------------------------------------------------------------//
    assign trn_tdst_rdy = s_axis_tx_tready;


// Create signal trn_in_packet, which is needed to validate trn_tsrc_dsc. We
// should ignore trn_tsrc_dsc when it's asserted out-of-packet.
always @(posedge user_clk) begin
  if(user_rst) begin
    trn_in_packet <= #TCQ 1'b0;
  end
  else begin
    if(!trn_in_packet && trn_tsof && !trn_teof && trn_tsrc_rdy && trn_tdst_rdy)
    begin
      trn_in_packet <= 1'b1;
    end
    else if(trn_in_packet && trn_teof && !trn_tsof && trn_tsrc_rdy &&
                                                             trn_tdst_rdy) begin
      trn_in_packet <= 1'b0;
    end
  end
end




endmodule











