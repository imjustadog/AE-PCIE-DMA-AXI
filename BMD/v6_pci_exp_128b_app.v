//-----------------------------------------------------------------------------
//
// (c) Copyright 2009 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information of Xilinx, Inc.
// and is protected under U.S. and international copyright and other
// intellectual property laws.
//
// DISCLAIMER
//
// This disclaimer is not a license and does not grant any rights to the
// materials distributed herewith. Except as otherwise provided in a valid
// license issued to you by Xilinx, and to the maximum extent permitted by
// applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL
// FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS,
// IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
// MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE;
// and (2) Xilinx shall not be liable (whether in contract or tort, including
// negligence, or under any other theory of liability) for any loss or damage
// of any kind or nature related to, arising under or in connection with these
// materials, including for any direct, or any indirect, special, incidental,
// or consequential loss or damage (including loss of data, profits, goodwill,
// or any type of loss or damage suffered as a result of any action brought by
// a third party) even if such damage or loss was reasonably foreseeable or
// Xilinx had been advised of the possibility of the same.
//
// CRITICAL APPLICATIONS
//
// Xilinx products are not designed or intended to be fail-safe, or for use in
// any application requiring fail-safe performance, such as life-support or
// safety devices or systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any other
// applications that could lead to death, personal injury, or severe property
// or environmental damage (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and liability of any use of
// Xilinx products in Critical Applications, subject only to applicable laws
// and regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE
// AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : Virtex-6 Integrated Block for PCI Express
// File       : pcie_app_v6.v
//--
//-- Description:  PCI Express Endpoint sample application
//--               design. 
//--
//------------------------------------------------------------------------------

`timescale 1ns / 1ps

`define PCI_EXP_EP_OUI                           24'h000A35
`define PCI_EXP_EP_DSN_1                         {{8'h1},`PCI_EXP_EP_OUI}
`define PCI_EXP_EP_DSN_2                         32'h00000001

module  pcie_app_v6
(

  input                                          trn_clk,
  input                                          trn_reset_n,
  input                                          trn_lnk_up_n, 

  // Tx
  input  [5:0]                                   trn_tbuf_av,
  input                                          trn_tcfg_req_n,
  input                                          trn_terr_drop_n,
  input                                          trn_tdst_rdy_n,
  output [127:0]                                 trn_td,
  output [1:0]                                   trn_trem_n,
  output                                         trn_tsof_n,
  output                                         trn_teof_n,
  output                                         trn_tsrc_rdy_n,
  output                                         trn_tsrc_dsc_n,
  output                                         trn_terrfwd_n,
  output                                         trn_tcfg_gnt_n,
  output                                         trn_tstr_n,

  // Rx
  input [127:0]                                 trn_rd,
  input [1:0]                                   trn_rrem_n,
  input                                          trn_rsof_n,
  input                                          trn_reof_n,
  input                                          trn_rsrc_rdy_n,
  input                                          trn_rsrc_dsc_n,
  input                                          trn_rerrfwd_n,
  input  [6:0]                                   trn_rbar_hit_n,
  output                                         trn_rdst_rdy_n,
  output                                         trn_rnp_ok_n, 

  // Flow Control
  input  [11:0]                                  trn_fc_cpld,
  input  [7:0]                                   trn_fc_cplh,
  input  [11:0]                                  trn_fc_npd,
  input  [7:0]                                   trn_fc_nph,
  input  [11:0]                                  trn_fc_pd,
  input  [7:0]                                   trn_fc_ph,
  output [2:0]                                   trn_fc_sel,


  input  [31:0]                                  cfg_do,
  input                                          cfg_rd_wr_done_n,
  output [31:0]                                  cfg_di,
  output [3:0]                                   cfg_byte_en_n,
  output [9:0]                                   cfg_dwaddr,
  output                                         cfg_wr_en_n,
  output                                         cfg_rd_en_n,


  output                                         cfg_err_cor_n,
  output                                         cfg_err_ur_n,
  output                                         cfg_err_ecrc_n,
  output                                         cfg_err_cpl_timeout_n,
  output                                         cfg_err_cpl_abort_n,
  output                                         cfg_err_cpl_unexpect_n,
  output                                         cfg_err_posted_n,
  output                                         cfg_err_locked_n,
  output [47:0]                                  cfg_err_tlp_cpl_header,
  input                                          cfg_err_cpl_rdy_n,
  output                                         cfg_interrupt_n,
  input                                          cfg_interrupt_rdy_n,
  output                                         cfg_interrupt_assert_n,
  output [7:0]                                   cfg_interrupt_di,
  input  [7:0]                                   cfg_interrupt_do,
  input  [2:0]                                   cfg_interrupt_mmenable,
  input                                          cfg_interrupt_msienable,
  input                                          cfg_interrupt_msixenable,
  input                                          cfg_interrupt_msixfm,
  output                                         cfg_turnoff_ok_n,
  input                                          cfg_to_turnoff_n,
  output                                         cfg_trn_pending_n,
  output                                         cfg_pm_wake_n,
  input   [7:0]                                  cfg_bus_number,
  input   [4:0]                                  cfg_device_number,
  input   [2:0]                                  cfg_function_number,
  input  [15:0]                                  cfg_status,
  input  [15:0]                                  cfg_command,
  input  [15:0]                                  cfg_dstatus,
  input  [15:0]                                  cfg_dcommand,
  input  [15:0]                                  cfg_lstatus,
  input  [15:0]                                  cfg_lcommand,
  input  [15:0]                                  cfg_dcommand2,
  input   [2:0]                                  cfg_pcie_link_state_n,

  output [1:0]                                   pl_directed_link_change,
  input  [5:0]                                   pl_ltssm_state, 
  output [1:0]                                   pl_directed_link_width,
  output                                         pl_directed_link_speed,
  output                                         pl_directed_link_auton,
  output                                         pl_upstream_prefer_deemph,
  input  [1:0]                                   pl_sel_link_width,
  input                                          pl_sel_link_rate,
  input                                          pl_link_gen2_capable,
  input                                          pl_link_partner_gen2_supported,
  input  [2:0]                                   pl_initial_link_width,
  input                                          pl_link_upcfg_capable,
  input  [1:0]                                   pl_lane_reversal_mode,
  input                                          pl_received_hot_rst,

  output [63:0]                                  cfg_dsn


);

  wire   [1:0]                                   trn_trem;
  wire   [1:0]                                   trn_rrem;

//
// Core input tie-offs
//
assign trn_fc_sel = 3'b0; 

assign trn_rnp_ok_n = 1'b0;
assign trn_terrfwd_n = 1'b1;

assign trn_tcfg_gnt_n = 1'b0;
assign trn_tecrc_gen_n = 1'b1;

assign cfg_err_cor_n = 1'b1;
assign cfg_err_ur_n = 1'b1;
assign cfg_err_ecrc_n = 1'b1;
assign cfg_err_cpl_timeout_n = 1'b1;
assign cfg_err_cpl_abort_n = 1'b1;
assign cfg_err_cpl_unexpect_n = 1'b1;
assign cfg_err_posted_n = 1'b0;
assign cfg_err_locked_n = 1'b1;
assign cfg_pm_wake_n = 1'b1;
assign cfg_trn_pending_n = 1'b1;
assign trn_tstr_n = 1'b0;
assign cfg_err_tlp_cpl_header = 47'h0;
assign cfg_di = 0;
assign cfg_byte_en_n = 4'hf;
assign cfg_wr_en_n = 1;
assign cfg_dsn = {`PCI_EXP_EP_DSN_2, `PCI_EXP_EP_DSN_1};



//
//BMD
//
wire        cfg_ext_tag_en           = cfg_dcommand[8];
wire  [5:0] cfg_neg_max_lnk_width    = cfg_lstatus[9:4];
wire  [2:0] cfg_prg_max_payload_size = cfg_dcommand[7:5];
wire  [2:0] cfg_max_rd_req_size      = cfg_dcommand[14:12];
wire        cfg_rd_comp_bound        = cfg_lcommand[3];
wire [15:0] cfg_completer_id = { cfg_bus_number, cfg_device_number, cfg_function_number };
wire        cfg_bus_mstr_enable      = cfg_command[2]; 

wire trn_tdst_dsc_n = 1'b1;

 parameter INTERFACE_WIDTH = 128;
 parameter INTERFACE_TYPE = 4'b0011;
 parameter FPGA_FAMILY = 8'h14; 


       BMD#
       (
        .INTERFACE_WIDTH(INTERFACE_WIDTH),
        .INTERFACE_TYPE(INTERFACE_TYPE),
        .FPGA_FAMILY(FPGA_FAMILY)
        )
        BMD (
        .trn_clk ( trn_clk ),                       // I
        .trn_reset_n ( trn_reset_n ),               // I
        .trn_lnk_up_n ( trn_lnk_up_n ),             // I

        .trn_td ( trn_td ),                         // O [63:0]
        .trn_trem_n ( trn_trem_n ),                 // O [7:0]
        .trn_tsof_n ( trn_tsof_n ),                 // O
        .trn_teof_n ( trn_teof_n ),                 // O
        .trn_tsrc_rdy_n ( trn_tsrc_rdy_n ),         // O
        .trn_tsrc_dsc_n ( trn_tsrc_dsc_n ),         // O
        .trn_tdst_rdy_n ( trn_tdst_rdy_n ),         // I
        .trn_tdst_dsc_n ( trn_tdst_dsc_n ),         // I  

        .trn_tbuf_av ( trn_tbuf_av ),               // I [5:0]
        .trn_rd ( trn_rd ),                         // I [63:0]
        .trn_rrem_n ( trn_rrem_n ),                 // I [7:0]
        .trn_rsof_n ( trn_rsof_n ),                 // I
        .trn_reof_n ( trn_reof_n ),                 // I
        .trn_rsrc_rdy_n ( trn_rsrc_rdy_n ),         // I
        .trn_rsrc_dsc_n ( trn_rsrc_dsc_n ),         // I
        .trn_rbar_hit_n ( trn_rbar_hit_n ),         // I [6:0]
        .trn_rdst_rdy_n ( trn_rdst_rdy_n ),         // O

        .cfg_to_turnoff_n ( cfg_to_turnoff_n ),     // I
        .cfg_turnoff_ok_n ( cfg_turnoff_ok_n ),     // O
        .cfg_do(cfg_do),                                // I [31:0]
        .cfg_dwaddr(cfg_dwaddr),                        // O [11:0]
        .cfg_rd_en_n(cfg_rd_en_n),                      // O
        .cfg_interrupt_n(cfg_interrupt_n),              // O
        .cfg_interrupt_rdy_n(cfg_interrupt_rdy_n),      // I

        .cfg_interrupt_assert_n(cfg_interrupt_assert_n),   // O
        .cfg_interrupt_di(cfg_interrupt_di),               // O
        .cfg_interrupt_do(cfg_interrupt_do),               // I
        .cfg_interrupt_mmenable(cfg_interrupt_mmenable),   // I
        .cfg_interrupt_msienable(cfg_interrupt_msienable), // I

        .cfg_ext_tag_en( cfg_ext_tag_en ),                // I  
        .cfg_max_rd_req_size(cfg_max_rd_req_size),           // I [2:0]  

        .cfg_prg_max_payload_size(cfg_prg_max_payload_size), // I [5:0] 
        .cfg_neg_max_lnk_width(cfg_neg_max_lnk_width),       // I [5:0]
        .cfg_rd_comp_bound(cfg_rd_comp_bound),          // I 
        .cfg_rd_wr_done_n(cfg_rd_wr_done_n),            // I

`ifdef PCIE2_0
        .pl_directed_link_change( pl_directed_link_change ),
        .pl_ltssm_state( pl_ltssm_state ),
        .pl_directed_link_width( pl_directed_link_width ),
        .pl_directed_link_speed( pl_directed_link_speed ),
        .pl_directed_link_auton( pl_directed_link_auton ),
        .pl_sel_link_width( pl_sel_link_width ),
        .pl_sel_link_rate( pl_sel_link_rate ),
        .pl_link_gen2_capable( pl_link_gen2_capable ),
        .pl_link_partner_gen2_supported( pl_link_partner_gen2_supported ),
        .pl_initial_link_width( pl_initial_link_width ),
        .pl_link_upcfg_capable( pl_link_upcfg_capable ),
        .pl_lane_reversal_mode( pl_lane_reversal_mode ),
	     .pl_upstream_preemph_src( pl_upstream_prefer_deemph ),
`endif
        .cfg_completer_id ( cfg_completer_id ),         // I [15:0]
        .cfg_bus_mstr_enable (cfg_bus_mstr_enable )     // I

        ); 

endmodule // pcie_app
