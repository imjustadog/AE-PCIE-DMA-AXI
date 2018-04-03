//-----------------------------------------------------------------------------
//
// (c) Copyright 2008, 2009 Xilinx, Inc. All rights reserved.
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
// Project    : Spartan-6 Integrated Block for PCI Express
// File       : xilinx_pcie_2_0_rport_v6.v
//-----------------------------------------------------------------------------

`timescale 1ns / 1ps

module xilinx_pcie_2_0_rport_v6 # (


  parameter                       REF_CLK_FREQ = 0,          // 0 - 100 MHz, 1 - 125 MHz,  2 - 250 MHz
  parameter                       ALLOW_X8_GEN2 = "FALSE",
  parameter                       PL_FAST_TRAIN = "FALSE",
  parameter                       LINK_CAP_MAX_LINK_WIDTH = 6'h01,
  parameter                       DEVICE_ID = 16'h506F,
  parameter                       LINK_CAP_MAX_LINK_SPEED = 4'h1,
  parameter                       LINK_CTRL2_TARGET_LINK_SPEED = 4'h1,
  parameter                       DEV_CAP_MAX_PAYLOAD_SUPPORTED = 2,
  parameter                       USER_CLK_FREQ = 3,
  parameter                       VC0_TX_LASTPACKET = 14,
  parameter                       VC0_RX_RAM_LIMIT = 13'h03ff,
  parameter                       VC0_CPL_INFINITE = "TRUE",
  parameter                       VC0_TOTAL_CREDITS_PD = 154,
  parameter                       VC0_TOTAL_CREDITS_CD = 154,

  // Simulation parameters
  parameter                       TX_LOG = 0,
  parameter                       RX_LOG = 0,
  parameter                       TRN_RX_TIMEOUT = 5000

)
(

  input                           sys_clk,
  input                           sys_reset_n,

  input  [(LINK_CAP_MAX_LINK_WIDTH - 1):0]              pci_exp_rxn, pci_exp_rxp,
  output [(LINK_CAP_MAX_LINK_WIDTH - 1):0]              pci_exp_txn, pci_exp_txp

);

// Local Wires
// Common
wire                            trn_clk;
wire                            trn_reset_n;
wire                            trn_lnk_up_n;

// Tx
wire  [63:0]                    trn_td;
wire                            trn_trem_n;
wire                            trn_tsof_n;
wire                            trn_teof_n;
wire                            trn_tsrc_rdy_n;
wire                            trn_tdst_rdy_n;
wire                            trn_tsrc_dsc_n;
wire                            trn_terrfwd_n;
wire                            trn_tdst_dsc_n;
wire  [5:0]                     trn_tbuf_av;

// Rx
wire  [63:0]                    trn_rd;
wire                            trn_rrem_n;
wire                            trn_rsof_n;
wire                            trn_reof_n;
wire                            trn_rsrc_rdy_n;
wire                            trn_rsrc_dsc_n;
wire                            trn_rdst_rdy_n;
wire                            trn_rerrfwd_n;
wire                            trn_rnp_ok_n;
wire [6:0]                      trn_rbar_hit_n;
wire [7:0]                      trn_rfc_nph_av;
wire [11:0]                     trn_rfc_npd_av;
wire [7:0]                      trn_rfc_ph_av;
wire [11:0]                     trn_rfc_pd_av;
wire [7:0]                      trn_rfc_cplh_av;
wire [11:0]                     trn_rfc_cpld_av;

wire [31:0]                     cfg_do;
wire [31:0]                     cfg_di;
wire [3:0]                      cfg_byte_en_n;
wire [9:0]                      cfg_dwaddr;
wire [47:0]                     cfg_err_tlp_cpl_header;
wire                            cfg_wr_en_n;
wire                            cfg_rd_wr_done_n;
wire                            cfg_rd_en_n;
wire                            cfg_err_cor_n;
wire                            cfg_err_ur_n;
wire                            cfg_err_ecrc_n;
wire                            cfg_err_cpl_timeout_n;
wire                            cfg_err_cpl_abort_n;
wire                            cfg_err_cpl_unexpect_n;
wire                            cfg_err_posted_n;
wire                            cfg_interrupt_n;
wire                            cfg_interrupt_rdy_n;
wire                            cfg_pm_send_pme_to_n;
wire [15:0]                     cfg_status;
wire [15:0]                     cfg_command;
wire [15:0]                     cfg_dstatus;
wire [15:0]                     cfg_dcommand;
wire [15:0]                     cfg_lstatus;
wire [15:0]                     cfg_lcommand;
wire                            cfg_rdy_n;
wire [2:0]                      cfg_pcie_link_state_n;
wire                            cfg_trn_pending_n;

wire                            cfg_msg_received;
wire [15:0]                     cfg_msg_data;
wire                            cfg_msg_received_err_cor;
wire                            cfg_msg_received_err_non_fatal;
wire                            cfg_msg_received_err_fatal;
wire                            cfg_msg_received_pme_to_ack;
wire                            cfg_msg_received_assert_inta;
wire                            cfg_msg_received_assert_intb;
wire                            cfg_msg_received_assert_intc;
wire                            cfg_msg_received_assert_intd;
wire                            cfg_msg_received_deassert_inta;
wire                            cfg_msg_received_deassert_intb;
wire                            cfg_msg_received_deassert_intc;
wire                            cfg_msg_received_deassert_intd;

wire [2:0]                      pl_initial_link_width;
wire [1:0]                      pl_lane_reversal_mode;
wire                            pl_link_gen2_capable;
wire                            pl_link_partner_gen2_supported;
wire                            pl_link_upcfg_capable;
wire [5:0]                      pl_ltssm_state;
wire                            pl_sel_link_rate;
wire [1:0]                      pl_sel_link_width;
wire                            pl_directed_link_auton;
wire [1:0]                      pl_directed_link_change;
wire                            pl_directed_link_speed;
wire [1:0]                      pl_directed_link_width;
wire                            pl_upstream_prefer_deemph;

wire                            speed_change_done_n;


// PCI-Express FPGA Endpoint Instance

pcie_2_0_rport_v6 # (

        .ALLOW_X8_GEN2(ALLOW_X8_GEN2),
        .REF_CLK_FREQ(REF_CLK_FREQ),
        .PL_FAST_TRAIN(PL_FAST_TRAIN),

        .LINK_CAP_MAX_LINK_WIDTH(LINK_CAP_MAX_LINK_WIDTH),
        .DEVICE_ID(DEVICE_ID),

        .LINK_CAP_MAX_LINK_SPEED(LINK_CAP_MAX_LINK_SPEED),
        .LINK_CTRL2_TARGET_LINK_SPEED(LINK_CTRL2_TARGET_LINK_SPEED),

        .DEV_CAP_MAX_PAYLOAD_SUPPORTED(DEV_CAP_MAX_PAYLOAD_SUPPORTED),
        .USER_CLK_FREQ(USER_CLK_FREQ),
        .VC0_TX_LASTPACKET(VC0_TX_LASTPACKET),
        .VC0_RX_RAM_LIMIT(VC0_RX_RAM_LIMIT),
        .VC0_CPL_INFINITE(VC0_CPL_INFINITE),
        .VC0_TOTAL_CREDITS_PD(VC0_TOTAL_CREDITS_PD),
        .VC0_TOTAL_CREDITS_CD(VC0_TOTAL_CREDITS_CD)

)
rport  (

        //
        // PCI Express (PCI_EXP) Interface
        //

        .pci_exp_txp(pci_exp_txp),
        .pci_exp_txn(pci_exp_txn),
        .pci_exp_rxp(pci_exp_rxp),
        .pci_exp_rxn(pci_exp_rxn),

        //
        // Transaction (TRN) Interface
        //

        .trn_clk(trn_clk),
        .trn_reset_n(trn_reset_n),
        .trn_lnk_up_n(trn_lnk_up_n),

        // Tx
        .trn_td(trn_td),
        .trn_trem_n(trn_trem_n),
        .trn_tsof_n(trn_tsof_n),
        .trn_teof_n(trn_teof_n),
        .trn_tsrc_rdy_n(trn_tsrc_rdy_n),
        .trn_tdst_rdy_n(trn_tdst_rdy_n),
        .trn_tsrc_dsc_n(trn_tsrc_dsc_n),
        .trn_terrfwd_n(trn_terrfwd_n),
        .trn_terr_drop_n(trn_tdst_dsc_n),
        .trn_tbuf_av(trn_tbuf_av),
        .trn_tcfg_gnt_n(1'b0),
        .trn_tstr_n(1'b1),
        .trn_tcfg_req_n(),

        // Rx
        .trn_rd(trn_rd),
        .trn_rrem_n(trn_rrem_n),
        .trn_rsof_n(trn_rsof_n),
        .trn_reof_n(trn_reof_n),
        .trn_rsrc_rdy_n(trn_rsrc_rdy_n),
        .trn_rsrc_dsc_n(trn_rsrc_dsc_n),
        .trn_rdst_rdy_n(trn_rdst_rdy_n),
        .trn_rerrfwd_n(trn_rerrfwd_n),
        .trn_rnp_ok_n(trn_rnp_ok_n),
        .trn_rbar_hit_n(trn_rbar_hit_n),
        .trn_recrc_err_n(),

        .trn_fc_cpld(),
        .trn_fc_cplh(),
        .trn_fc_npd(),
        .trn_fc_nph(),
        .trn_fc_pd(),
        .trn_fc_ph(),
        .trn_fc_sel(3'b0),


        //
        // Host (CFG) Interface
        //

        .cfg_do(cfg_do),
        .cfg_rd_wr_done_n(cfg_rd_wr_done_n),
        .cfg_di(cfg_di),
        .cfg_byte_en_n(cfg_byte_en_n),
        .cfg_dwaddr(cfg_dwaddr),
        .cfg_wr_en_n(cfg_wr_en_n),
        .cfg_wr_rw1c_as_rw_n(1'b1),
        .cfg_rd_en_n(cfg_rd_en_n),

        .cfg_err_cor_n(cfg_err_cor_n),
        .cfg_err_ur_n(cfg_err_ur_n),
        .cfg_err_ecrc_n(cfg_err_ecrc_n),
        .cfg_err_cpl_timeout_n(cfg_err_cpl_timeout_n),
        .cfg_err_cpl_abort_n(cfg_err_cpl_abort_n),
        .cfg_err_cpl_unexpect_n(cfg_err_cpl_unexpect_n),
        .cfg_err_posted_n(cfg_err_posted_n),
        .cfg_err_tlp_cpl_header(cfg_err_tlp_cpl_header),

        .cfg_interrupt_n(cfg_interrupt_n),
        .cfg_interrupt_rdy_n(cfg_interrupt_rdy_n),

        .cfg_pm_send_pme_to_n( cfg_pm_send_pme_to_n ),

        .cfg_status(cfg_status),
        .cfg_command(cfg_command),
        .cfg_dstatus(cfg_dstatus),
        .cfg_dcommand(cfg_dcommand),
        .cfg_lstatus(cfg_lstatus),
        .cfg_lcommand(cfg_lcommand),

        .cfg_pcie_link_state_n(cfg_pcie_link_state_n),
        .cfg_trn_pending_n(cfg_trn_pending_n),

        .cfg_dsn(64'h0),
        .cfg_err_locked_n(1'b1),
        .cfg_interrupt_assert_n(1'b1),
        .cfg_interrupt_di(8'h0),

        .cfg_err_cpl_rdy_n(),
        .cfg_interrupt_do(),
        .cfg_interrupt_mmenable(),
        .cfg_interrupt_msienable(),
        .cfg_interrupt_msixenable(),
        .cfg_interrupt_msixfm(),
        .cfg_dcommand2(),

        .cfg_msg_received(cfg_msg_received),
        .cfg_msg_data(cfg_msg_data),
        .cfg_msg_received_err_cor(cfg_msg_received_err_cor),
        .cfg_msg_received_err_non_fatal(cfg_msg_received_err_non_fatal),
        .cfg_msg_received_err_fatal(cfg_msg_received_err_fatal),
        .cfg_msg_received_pme_to_ack(cfg_msg_received_pme_to_ack),

        .cfg_ds_bus_number(8'h0),
        .cfg_ds_device_number(5'h0),

        // PL Control and Status

        .pl_initial_link_width( pl_initial_link_width ),
        .pl_lane_reversal_mode( pl_lane_reversal_mode ),
        .pl_link_gen2_capable( pl_link_gen2_capable ),
        .pl_link_partner_gen2_supported( pl_link_partner_gen2_supported ),
        .pl_link_upcfg_capable( pl_link_upcfg_capable ),
        .pl_ltssm_state( pl_ltssm_state ),
        .pl_sel_link_rate( pl_sel_link_rate ),
        .pl_sel_link_width( pl_sel_link_width ),
        .pl_directed_link_auton( pl_directed_link_auton ),
        .pl_directed_link_change( pl_directed_link_change ),
        .pl_directed_link_speed( pl_directed_link_speed ),
        .pl_directed_link_width( pl_directed_link_width ),
        .pl_upstream_prefer_deemph( pl_upstream_prefer_deemph ),

        .pl_transmit_hot_rst(1'b0),

        // Unused status outputs
        .cfg_pmcsr_pme_en(),
        .cfg_pmcsr_pme_status(),
        .cfg_pmcsr_powerstate(),
        .cfg_msg_received_assert_inta(cfg_msg_received_assert_inta),
        .cfg_msg_received_assert_intb(cfg_msg_received_assert_intb),
        .cfg_msg_received_assert_intc(cfg_msg_received_assert_intc),
        .cfg_msg_received_assert_intd(cfg_msg_received_assert_intd),
        .cfg_msg_received_deassert_inta(cfg_msg_received_deassert_inta),
        .cfg_msg_received_deassert_intb(cfg_msg_received_deassert_intb),
        .cfg_msg_received_deassert_intc(cfg_msg_received_deassert_intc),
        .cfg_msg_received_deassert_intd(cfg_msg_received_deassert_intd),

         // PCIe DRP
        .pcie_drp_do(),
        .pcie_drp_drdy(),
        .pcie_drp_clk(1'b0),
        .pcie_drp_den(1'b0),
        .pcie_drp_dwe(1'b0),
        .pcie_drp_daddr(9'd0),
        .pcie_drp_di(16'h0),

        // System (SYS) Interface

        .sys_clk(sys_clk),
        .sys_reset_n(sys_reset_n)

        );

// User Application Instances

// Rx User Application Interface

pci_exp_usrapp_rx #(
        .RX_LOG (RX_LOG),
        .TRN_RX_TIMEOUT (TRN_RX_TIMEOUT)
)
rx_usrapp (
        .trn_clk(trn_clk),
        .trn_reset_n(trn_reset_n),
        .trn_lnk_up_n(trn_lnk_up_n),

        .trn_rd(trn_rd),
        .trn_rrem_n({4'b0, {4{trn_rrem_n}}}),
        .trn_rsof_n(trn_rsof_n),
        .trn_reof_n(trn_reof_n),
        .trn_rsrc_rdy_n(trn_rsrc_rdy_n),
        .trn_rsrc_dsc_n(trn_rsrc_dsc_n),
        .trn_rdst_rdy_n(trn_rdst_rdy_n),
        .trn_rerrfwd_n(trn_rerrfwd_n),
        .trn_rnp_ok_n(trn_rnp_ok_n),
        .trn_rbar_hit_n(trn_rbar_hit_n)

        );

// Tx User Application Interface

wire [6:0] trn_trem_n_unused;
pci_exp_usrapp_tx # (

        .TX_LOG (TX_LOG),
        .LINK_CAP_MAX_LINK_SPEED(LINK_CAP_MAX_LINK_SPEED)

)
tx_usrapp (

        .trn_clk(trn_clk),
        .trn_reset_n(trn_reset_n),
        .trn_lnk_up_n(trn_lnk_up_n),

        .trn_td(trn_td),
        .trn_trem_n({trn_trem_n_unused, trn_trem_n}),
        .trn_tsof_n(trn_tsof_n),
        .trn_teof_n(trn_teof_n),
        .trn_terrfwd_n(trn_terrfwd_n),
        .trn_tsrc_rdy_n(trn_tsrc_rdy_n),
        .trn_tdst_rdy_n(trn_tdst_rdy_n),
        .trn_tsrc_dsc_n(trn_tsrc_dsc_n),
        .trn_tdst_dsc_n(trn_tdst_dsc_n),
        .trn_tbuf_av(trn_tbuf_av),
        .speed_change_done_n(speed_change_done_n)

        );

// Cfg UsrApp

pci_exp_usrapp_cfg cfg_usrapp (


        .trn_clk(trn_clk),
        .trn_reset_n(trn_reset_n),

        .cfg_do(cfg_do),
        .cfg_di(cfg_di),
        .cfg_byte_en_n(cfg_byte_en_n),
        .cfg_dwaddr(cfg_dwaddr),
        .cfg_wr_en_n(cfg_wr_en_n),
        .cfg_rd_en_n(cfg_rd_en_n),
        .cfg_rd_wr_done_n(cfg_rd_wr_done_n),

        .cfg_err_cor_n(cfg_err_cor_n),
        .cfg_err_ur_n(cfg_err_ur_n),
        .cfg_err_ecrc_n(cfg_err_ecrc_n),
        .cfg_err_cpl_timeout_n(cfg_err_cpl_timeout_n),
        .cfg_err_cpl_abort_n(cfg_err_cpl_abort_n),
        .cfg_err_cpl_unexpect_n(cfg_err_cpl_unexpect_n),
        .cfg_err_posted_n(cfg_err_posted_n),
        .cfg_err_tlp_cpl_header(cfg_err_tlp_cpl_header),
        .cfg_interrupt_n(cfg_interrupt_n),
        .cfg_interrupt_rdy_n(cfg_interrupt_rdy_n),
        .cfg_turnoff_ok_n(),
        .cfg_pm_wake_n(),
        .cfg_to_turnoff_n(1'b1),
        .cfg_bus_number(8'h0),
        .cfg_device_number(5'h0),
        .cfg_function_number(3'h0),
        .cfg_status(cfg_status),
        .cfg_command(cfg_command),
        .cfg_dstatus(cfg_dstatus),
        .cfg_dcommand(cfg_dcommand),
        .cfg_lstatus(cfg_lstatus),
        .cfg_lcommand(cfg_lcommand),
        .cfg_pcie_link_state_n(cfg_pcie_link_state_n),
        .cfg_trn_pending_n(cfg_trn_pending_n)

        );

// Common UsrApp

pci_exp_usrapp_com #(
          .RX_LOG(RX_LOG)
) com_usrapp ();

// PL UsrApp

pci_exp_usrapp_pl # (
         .LINK_CAP_MAX_LINK_SPEED(LINK_CAP_MAX_LINK_SPEED)
)
pl_usrapp (

         .pl_initial_link_width( pl_initial_link_width ),
         .pl_lane_reversal_mode( pl_lane_reversal_mode ),
         .pl_link_gen2_capable( pl_link_gen2_capable ),
         .pl_link_partner_gen2_supported( pl_link_partner_gen2_supported ),
         .pl_link_upcfg_capable( pl_link_upcfg_capable ),
         .pl_ltssm_state( pl_ltssm_state ),
         .pl_received_hot_rst( 1'b0 ),
         .pl_sel_link_rate( pl_sel_link_rate ),
         .pl_sel_link_width( pl_sel_link_width ),
         .pl_directed_link_auton( pl_directed_link_auton ),
         .pl_directed_link_change( pl_directed_link_change ),
         .pl_directed_link_speed( pl_directed_link_speed ),
         .pl_directed_link_width( pl_directed_link_width ),
         .pl_upstream_prefer_deemph( pl_upstream_prefer_deemph ),
         .speed_change_done_n(speed_change_done_n),

         .trn_lnk_up_n( trn_lnk_up_n ),
         .trn_clk( trn_clk ),
         .trn_reset_n( trn_reset_n )

         );

// Instantate tests module
tests com_tests ();

endmodule

