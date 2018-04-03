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
// File       : axi_trn_top.v
// Version    : 1.1
//----------------------------------------------------------------------------//
//  File: axi_trn_top.v                                                       //
//                                                                            //
//  Description:                                                              //
//  TRN/AXI4-S Bridge top level module. Instantiates RX and TX modules.       //
//                                                                            //
//  Notes:                                                                    //
//  Optional notes section.                                                   //
//                                                                            //
//  Hierarchical:                                                             //
//    axi_trn_top                                                             //
//                                                                            //
//----------------------------------------------------------------------------//

`timescale 1ps/1ps

module axi_trn_top #(
  parameter C_DATA_WIDTH = 64,            // RX/TX interface data width
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

  // AXI TX
  //-----------
  input                       s_axis_tx_tready,       // TX ready for data
  output   [C_DATA_WIDTH-1:0] s_axis_tx_tdata,        // TX data from user
  output                      s_axis_tx_tvalid,       // TX data is valid
  output     [KEEP_WIDTH-1:0] s_axis_tx_tkeep,        // TX strobe byte enables
  output                      s_axis_tx_tlast,        // TX data is last
  output                [3:0] s_axis_tx_tuser,        // TX user signals

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

  // TRN RX
  //-----------
  output  [C_DATA_WIDTH-1:0] trn_rd,                  // RX data from block
  output                     trn_rsof,                // RX start of packet
  output                     trn_reof,                // RX end of packet
  output                     trn_rsrc_rdy,            // RX source ready
  input                      trn_rdst_rdy,            // RX destination ready
  output                     trn_rsrc_dsc,            // RX source discontinue
  output     [REM_WIDTH-1:0] trn_rrem,                // RX remainder
  output    [RBAR_WIDTH-1:0] trn_rbar_hit,            // RX BAR hit
  input                       trn_lnk_up,             // PCIe link up

  // System
  //-----------
  input                      user_clk,                // user clock from block
  input                      user_rst                 // user reset from block
  );





  //---------------------------------------------//
  // RX Data Pipeline                            //
  //---------------------------------------------//

  axi_trn_rx #(
    .C_DATA_WIDTH( C_DATA_WIDTH ),
    .C_FAMILY( C_FAMILY ),

    .REM_WIDTH( REM_WIDTH ),
    .RBAR_WIDTH( RBAR_WIDTH ),
    .KEEP_WIDTH( KEEP_WIDTH )
  ) rx_inst (

    // Incoming AXI RX
    //-----------
    .m_axis_rx_tdata( m_axis_rx_tdata ),
    .m_axis_rx_tvalid( m_axis_rx_tvalid ),
    .m_axis_rx_tready( m_axis_rx_tready ),
    .m_axis_rx_tkeep( m_axis_rx_tkeep ),
    .m_axis_rx_tlast( m_axis_rx_tlast ),
    .m_axis_rx_tuser( m_axis_rx_tuser ),

    // Outgoing TRN RX
    //-----------
    .trn_rd( trn_rd ),
    .trn_rsof( trn_rsof ),
    .trn_reof( trn_reof ),
    .trn_rsrc_rdy( trn_rsrc_rdy ),
    .trn_rdst_rdy( trn_rdst_rdy ),
    .trn_rsrc_dsc( trn_rsrc_dsc ),
    .trn_rrem( trn_rrem ),
    .trn_rbar_hit( trn_rbar_hit ),
    .trn_rerrfwd(),
    .trn_lnk_up(trn_lnk_up),
    
    // System
    //-----------
    .user_clk( user_clk ),
    .user_rst( user_rst )
  );



  //---------------------------------------------//
  // TX Data Pipeline                            //
  //---------------------------------------------//

  axi_trn_tx #(
    .C_DATA_WIDTH( C_DATA_WIDTH ),
    .C_FAMILY( C_FAMILY ),
    .C_ROOT_PORT( C_ROOT_PORT ),
    .C_PM_PRIORITY( C_PM_PRIORITY ),

    .REM_WIDTH( REM_WIDTH ),
    .KEEP_WIDTH( KEEP_WIDTH )
  ) tx_inst (

    // Outgoing AXI TX
    //-----------
    .s_axis_tx_tdata( s_axis_tx_tdata ),
    .s_axis_tx_tvalid( s_axis_tx_tvalid ),
    .s_axis_tx_tready( s_axis_tx_tready ),
    .s_axis_tx_tkeep( s_axis_tx_tkeep ),
    .s_axis_tx_tlast( s_axis_tx_tlast ),
    .s_axis_tx_tuser( s_axis_tx_tuser ),


    // Incoming TRN TX
    //-----------
    .trn_td( trn_td ),
    .trn_tsof( trn_tsof ),
    .trn_teof( trn_teof ),
    .trn_tsrc_rdy( trn_tsrc_rdy ),
    .trn_tdst_rdy( trn_tdst_rdy ),
    .trn_tsrc_dsc( trn_tsrc_dsc ),
    .trn_trem( trn_trem ),
    .trn_terrfwd( trn_terrfwd ),
    .trn_tstr( trn_tstr ),
    .trn_lnk_up( trn_lnk_up ),


    // System
    //-----------
    .user_clk( user_clk ),
    .user_rst( user_rst )
  );

endmodule
