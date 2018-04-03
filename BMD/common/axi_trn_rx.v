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
// File       : axi_trn_rx.v
// Version    : 1.1
//----------------------------------------------------------------------------//
//  File: axi_trn_rx.v                                                        //
//                                                                            //
//  Description:                                                              //
//  TRN to AXI RX module. Instantiates pipeline and null generator RX         //
//  submodules.                                                               //
//                                                                            //
//  Notes:                                                                    //
//  Optional notes section.                                                   //
//                                                                            //
//  Hierarchical:                                                             //
//    axi_trn_top                                                             //
//      axi_trn_rx                                                            //
//                                                                            //
//----------------------------------------------------------------------------//

`timescale 1ps/1ps

module axi_trn_rx #(
  parameter C_DATA_WIDTH = 128,           // RX/TX interface data width
  parameter C_FAMILY = "X7",              // Targeted FPGA family
  parameter C_ROOT_PORT = "FALSE",        // PCIe block is in root port mode
  parameter C_PM_PRIORITY = "FALSE",      // Disable TX packet boundary thrtl
  parameter TCQ = 1,                      // Clock to Q time

  // Do not override parameters below this line
  parameter REM_WIDTH  = (C_DATA_WIDTH == 128) ? 2 : 1, // trem/rrem width
  parameter RBAR_WIDTH = (C_FAMILY == "X7") ? 8 : 7,    // trn_rbar_hit width
  parameter KEEP_WIDTH = C_DATA_WIDTH / 8               // TKEEP width
  ) (
  //---------------------------------------------//
  // User Design I/O                             //
  //---------------------------------------------//

  // AXI RX
  //-----------
  input  [C_DATA_WIDTH-1:0] m_axis_rx_tdata,        // RX data to user
  input                     m_axis_rx_tvalid,       // RX data is valid
  output                    m_axis_rx_tready,       // RX ready for data
  input    [KEEP_WIDTH-1:0] m_axis_rx_tkeep,        // RX strobe byte enables
  input                     m_axis_rx_tlast,        // RX data is last
  input              [21:0] m_axis_rx_tuser,        // RX user signals

  //---------------------------------------------//
  // PCIe Block I/O                              //
  //---------------------------------------------//

  // TRN RX
  //-----------
  output  [C_DATA_WIDTH-1:0] trn_rd,                  // RX data from block
  output                     trn_rsof,                // RX start of packet
  output                     trn_reof,                // RX end of packet
  output                     trn_rsrc_rdy,            // RX source ready
  input                      trn_rdst_rdy,            // RX destination ready
  output reg                 trn_rsrc_dsc,            // RX source discontinue
  output     [REM_WIDTH-1:0] trn_rrem,                // RX remainder
  output                     trn_rerrfwd,             // RX error forward
  output    [RBAR_WIDTH-1:0] trn_rbar_hit,            // RX BAR hit


  // TRN Misc.
  //-----------
  input                     trn_lnk_up,              // PCIe link up


  // System
  //-----------
  input                     user_clk,                // user clock from block
  input                     user_rst                 // user reset from block
  );

reg                     trn_in_packet;

//----------------------------------------------------------------------------//
// Create constant-width rbar_hit wire regardless of target architecture
//----------------------------------------------------------------------------//
    assign trn_rbar_hit = m_axis_rx_tuser[9:2];

//----------------------------------------------------------------------------//
// Convert AXI data format to TRN data format. AXI is DWORD swapped from TRN. //
// 128-bit:                 64-bit:                  32-bit:                  //
// TRN DW0 maps to AXI DW3  TRN DW0 maps to AXI DW1  TNR DW0 maps to AXI DW0  //
// TRN DW1 maps to AXI DW2  TRN DW1 maps to AXI DW0                           //
// TRN DW2 maps to AXI DW1                                                    //
// TRN DW3 maps to AXI DW0                                                    //
//----------------------------------------------------------------------------//
generate begin : m_axis_trn_rd
  if(C_DATA_WIDTH == 128) begin : rd_DW_swap_128
    assign trn_rd[127:0] = {m_axis_rx_tdata[31:0],
                     m_axis_rx_tdata[63:32],
                     m_axis_rx_tdata[95:64],
                     m_axis_rx_tdata[127:96]};
  end
  else if(C_DATA_WIDTH == 64) begin : rd_DW_swap_64
    assign trn_rd = {m_axis_rx_tdata[31:0], 
                     m_axis_rx_tdata[63:32]};
  end
 end  
endgenerate

    
//----------------------------------------------------------------------------//
// Create trn_rsof. To do so, create signal trn_in_packet, which tracks if a  //
// packet is currently in progress on the TRN interface. If not, then the     //
// assertion of TVALID indicates SOF.                                         //
//----------------------------------------------------------------------------//
always @(posedge user_clk) begin
  if(user_rst) begin
    trn_in_packet <= #TCQ 1'b0;
  end
  else begin
    if(m_axis_rx_tvalid && trn_rdst_rdy) begin
      trn_in_packet <= #TCQ !m_axis_rx_tlast;
    end
  end
end

generate begin : m_axis_to_trn_rsof
  if(C_DATA_WIDTH == 128) begin : rx_tuser_to_rsof 
    assign trn_rsof = m_axis_rx_tuser[14]; 
  end
  else begin : m_axis_to_trn_rsof
    assign trn_rsof = m_axis_rx_tvalid && !trn_in_packet;
  end
end  
endgenerate 



//----------------------------------------------------------------------------//
// Convert KEEP to RREM. Here, we are converting the encoding method for the  //
// location of the EOF from AXI (RKEEP) to TRN flavor (rrem).                 //
//----------------------------------------------------------------------------//
generate begin : m_axis_trn_rrem
  if(C_DATA_WIDTH == 128) begin : rkeep_to_rrem_128
    //---------------------------------------//

    wire [4:0] is_sof  = m_axis_rx_tuser[14:10];
    wire [4:0] is_eof  = m_axis_rx_tuser[21:17];
        assign trn_rrem[1] = (is_eof[4] || is_sof[4] )  ?  ( (is_sof[4] && is_eof[4] && is_eof[3]) || 
                                                             (!is_sof[4] && is_eof[4] && is_eof[3]) || 
                                                             (is_sof[4] && !is_eof[4] && !is_sof[3]) )  
                                                        :   1'b1;

    
    
                                                      
    assign trn_rrem[0] = is_eof[2];
  end
  else if(C_DATA_WIDTH == 64) begin : rkeep_to_rrem_64
    assign trn_rrem    = (m_axis_rx_tkeep[7:4] == 4'hF) ? 1 : 0;
  end
end  
endgenerate

//----------------------------------------------------------------------------//
// Create remaining TRN signals                                               //
//----------------------------------------------------------------------------//
generate begin : m_axis_to_trn_reof
  if(C_DATA_WIDTH == 128) begin : rx_tuser_to_reof 
    assign trn_reof = m_axis_rx_tuser[21]; 
  end
  else begin : m_axis_to_trn_teof
    assign trn_reof         = m_axis_rx_tlast;
  end
end  
endgenerate 

//--------------------------------------------------------------------------------//
assign trn_recrc_gen    = m_axis_rx_tuser[0];
assign trn_rerrfwd      = m_axis_rx_tuser[1];
assign trn_rsrc_rdy     = m_axis_rx_tvalid;
assign m_axis_rx_tready = trn_rdst_rdy;

//----------------------------------------------------------------------------//
// Create trn_rsrc_dsc signal                                                 //
//----------------------------------------------------------------------------//
always @(posedge user_clk) begin
 if(user_rst) begin
  trn_rsrc_dsc     <= #TCQ 1'b0;
 end
 else begin 
   trn_rsrc_dsc     <= #TCQ trn_lnk_up;
   end
end


endmodule


