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
// File       : xilinx_pcie_1_1_ep_s6.v
// Description: PCI Express Endpoint example FPGA design
//
//-----------------------------------------------------------------------------

`timescale 1ns / 1ps

module xilinx_pcie_1_1_ep_s6 #(
  parameter FAST_TRAIN = "FALSE"
) (
  output    pci_exp_txp,
  output    pci_exp_txn,
  input     pci_exp_rxp,
  input     pci_exp_rxn,

  input     sys_clk_p,
  input     sys_clk_n,
  input     sys_reset_n,

  output    led_0,
  output    led_1,
  output    led_2

);

  // Common
  wire                                        user_clk;
  wire                                        user_reset;
  wire                                        user_lnk_up;

  // Tx
  wire [5:0]                                  tx_buf_av;
  wire                                        tx_cfg_req;
  wire                                        tx_err_drop;
  wire                                        tx_cfg_gnt;
  wire                                        s_axis_tx_tready;
  wire [3:0]                                  s_axis_tx_tuser;
  wire [31:0]                                 s_axis_tx_tdata;
  wire [3:0]                                  s_axis_tx_tkeep;
  wire                                        s_axis_tx_tlast;
  wire                                        s_axis_tx_tvalid;

  // Rx
  wire [31:0]                                 m_axis_rx_tdata;
  wire [3:0]                                  m_axis_rx_tkeep;
  wire                                        m_axis_rx_tlast;
  wire                                        m_axis_rx_tvalid;
  wire                                        m_axis_rx_tready;
  wire  [21:0]                                m_axis_rx_tuser;
  wire                                        rx_np_ok;

  // Flow Control
  wire [11:0]                                 fc_cpld;
  wire [7:0]                                  fc_cplh;
  wire [11:0]                                 fc_npd;
  wire [7:0]                                  fc_nph;
  wire [11:0]                                 fc_pd;
  wire [7:0]                                  fc_ph;
  wire [2:0]                                  fc_sel;

  // Config
  wire [63:0]                                 cfg_dsn;
  wire [31:0]                                 cfg_do;
  wire                                        cfg_rd_wr_done  ;
  wire [9:0]                                  cfg_dwaddr;
  wire                                        cfg_rd_en  ;

  // Error signaling
  wire                                        cfg_err_cor;
  wire                                        cfg_err_ur;
  wire                                        cfg_err_ecrc;
  wire                                        cfg_err_cpl_timeout;
  wire                                        cfg_err_cpl_abort;
  wire                                        cfg_err_posted;
  wire                                        cfg_err_locked  ;
  wire [47:0]                                 cfg_err_tlp_cpl_header;
  wire                                        cfg_err_cpl_rdy  ;

  // Interrupt signaling
  wire                                        cfg_interrupt  ;
  wire                                        cfg_interrupt_rdy  ;
  wire                                        cfg_interrupt_assert  ;
  wire [7:0]                                  cfg_interrupt_di;
  wire [7:0]                                  cfg_interrupt_do;
  wire [2:0]                                  cfg_interrupt_mmenable;
  wire                                        cfg_interrupt_msienable;

  // Power management signaling
  wire                                        cfg_turnoff_ok  ;
  wire                                        cfg_to_turnoff  ;
  wire                                        cfg_trn_pending  ;
  wire                                        cfg_pm_wake  ;

  // System configuration and status
  wire [7:0]                                  cfg_bus_number;
  wire [4:0]                                  cfg_device_number;
  wire [2:0]                                  cfg_function_number;
  wire [15:0]                                 cfg_status;
  wire [15:0]                                 cfg_command;
  wire [15:0]                                 cfg_dstatus;
  wire [15:0]                                 cfg_dcommand;
  wire [15:0]                                 cfg_lstatus;
  wire [15:0]                                 cfg_lcommand;
  wire [2:0]                                  cfg_pcie_link_state  ;

  // System (SYS) Interface
  wire                                        sys_clk_c;
  wire                                        sys_reset_n_c;

  //-------------------------------------------------------
  // Clock Input Buffer for differential system clock
  //-------------------------------------------------------
  IBUFDS refclk_ibuf (.O(sys_clk_c), .I(sys_clk_p), .IB(sys_clk_n));

  //-------------------------------------------------------
  // Input buffer for system reset signal
  //-------------------------------------------------------
  IBUF   sys_reset_n_ibuf (.O(sys_reset_n_c), .I(sys_reset_n));

  //-------------------------------------------------------
  // Output buffers for diagnostic LEDs
  //-------------------------------------------------------
  OBUF   led_0_obuf (.O(led_0), .I(sys_reset_n_c));
  OBUF   led_1_obuf (.O(led_1), .I(user_reset));
  OBUF   led_2_obuf (.O(led_2), .I(user_lnk_up));

  pcie_app_s6 app (
    // Transaction (TRN) Interface
    // Common lock & reset
    .user_clk( user_clk ),
    .user_reset( user_reset ),
    .user_lnk_up( user_lnk_up ),
    // Common flow control
    .fc_cpld( fc_cpld ),
    .fc_cplh( fc_cplh ),
    .fc_npd( fc_npd ),
    .fc_nph( fc_nph ),
    .fc_pd( fc_pd ),
    .fc_ph( fc_ph ),
    .fc_sel( fc_sel ),
    // Transaction Tx
    .tx_buf_av( tx_buf_av ),
    .tx_cfg_req( tx_cfg_req ),
    .tx_cfg_gnt( tx_cfg_gnt ),
    .tx_err_drop( tx_err_drop ),
    .s_axis_tx_tready( s_axis_tx_tready ),
    .s_axis_tx_tdata( s_axis_tx_tdata ),
    .s_axis_tx_tkeep( s_axis_tx_tkeep ),
    .s_axis_tx_tuser( s_axis_tx_tuser ),
    .s_axis_tx_tlast( s_axis_tx_tlast ),
    .s_axis_tx_tvalid( s_axis_tx_tvalid ),

    // Transaction Rx
    .m_axis_rx_tdata( m_axis_rx_tdata ),
    .m_axis_rx_tkeep( m_axis_rx_tkeep ),
    .m_axis_rx_tlast( m_axis_rx_tlast ),
    .m_axis_rx_tvalid( m_axis_rx_tvalid ),
    .m_axis_rx_tready( m_axis_rx_tready ),
    .m_axis_rx_tuser ( m_axis_rx_tuser ),
    .rx_np_ok( rx_np_ok ),

    // Configuration (CFG) Interface
    // Configuration space access
    .cfg_do( cfg_do ),
    .cfg_rd_wr_done  ( cfg_rd_wr_done  ),
    .cfg_dwaddr( cfg_dwaddr ),
    .cfg_rd_en  ( cfg_rd_en   ),
    // Error signaling
    .cfg_err_cor( cfg_err_cor ),
    .cfg_err_ur( cfg_err_ur ),
    .cfg_err_ecrc( cfg_err_ecrc ),
    .cfg_err_cpl_timeout( cfg_err_cpl_timeout ),
    .cfg_err_cpl_abort( cfg_err_cpl_abort ),
    .cfg_err_posted( cfg_err_posted ),
    .cfg_err_locked  ( cfg_err_locked   ),
    .cfg_err_tlp_cpl_header( cfg_err_tlp_cpl_header ),
    .cfg_err_cpl_rdy  ( cfg_err_cpl_rdy   ),
    // Interrupt generation
    .cfg_interrupt  ( cfg_interrupt   ),
    .cfg_interrupt_rdy  ( cfg_interrupt_rdy   ),
    .cfg_interrupt_assert  ( cfg_interrupt_assert   ),
    .cfg_interrupt_di( cfg_interrupt_di ),
    .cfg_interrupt_do( cfg_interrupt_do ),
    .cfg_interrupt_mmenable( cfg_interrupt_mmenable ),
    .cfg_interrupt_msienable( cfg_interrupt_msienable ),
    // Power managemnt signaling
    .cfg_turnoff_ok  ( cfg_turnoff_ok   ),
    .cfg_to_turnoff  ( cfg_to_turnoff   ),
    .cfg_trn_pending  ( cfg_trn_pending   ),
    .cfg_pm_wake  ( cfg_pm_wake   ),
    // System configuration and status
    .cfg_bus_number( cfg_bus_number ),
    .cfg_device_number( cfg_device_number ),
    .cfg_function_number( cfg_function_number ),
    .cfg_status( cfg_status ),
    .cfg_command( cfg_command ),
    .cfg_dstatus( cfg_dstatus ),
    .cfg_dcommand( cfg_dcommand ),
    .cfg_lstatus( cfg_lstatus ),
    .cfg_lcommand( cfg_lcommand ),
    .cfg_pcie_link_state  ( cfg_pcie_link_state   ),
    .cfg_dsn( cfg_dsn )
  );

  s6_pcie_v2_4 #(
    .FAST_TRAIN                        ( FAST_TRAIN                        )
  ) s6_pcie_v2_4_i (
    // PCI Express (PCI_EXP) Fabric Interface
    .pci_exp_txp                        ( pci_exp_txp                             ),
    .pci_exp_txn                        ( pci_exp_txn                             ),
    .pci_exp_rxp                        ( pci_exp_rxp                             ),
    .pci_exp_rxn                        ( pci_exp_rxn                             ),

    // Transaction (TRN) Interface
    // Common clock & reset
    .user_lnk_up                        ( user_lnk_up                             ),
    .user_clk_out                       ( user_clk                                ),
    .user_reset_out                     ( user_reset                              ),
    // Common flow control
    .fc_sel                             ( fc_sel                                  ),
    .fc_nph                             ( fc_nph                                  ),
    .fc_npd                             ( fc_npd                                  ),
    .fc_ph                              ( fc_ph                                   ),
    .fc_pd                              ( fc_pd                                   ),
    .fc_cplh                            ( fc_cplh                                 ),
    .fc_cpld                            ( fc_cpld                                 ),

    // Transaction Tx
    .s_axis_tx_tready                   ( s_axis_tx_tready                        ),
    .s_axis_tx_tdata                    ( s_axis_tx_tdata                         ),
    .s_axis_tx_tkeep                    ( s_axis_tx_tkeep                         ),
    .s_axis_tx_tuser                    ( s_axis_tx_tuser                         ),
    .s_axis_tx_tlast                    ( s_axis_tx_tlast                         ),
    .s_axis_tx_tvalid                   ( s_axis_tx_tvalid                        ),
    .tx_err_drop                        ( tx_err_drop                             ),
    .tx_buf_av                          ( tx_buf_av                               ),
    .tx_cfg_req                         ( tx_cfg_req                              ),
    .tx_cfg_gnt                         ( tx_cfg_gnt                              ),

    // Transaction Rx
    .m_axis_rx_tdata                    ( m_axis_rx_tdata                         ),
    .m_axis_rx_tkeep                    ( m_axis_rx_tkeep                         ),
    .m_axis_rx_tlast                    ( m_axis_rx_tlast                         ),
    .m_axis_rx_tvalid                   ( m_axis_rx_tvalid                        ),
    .m_axis_rx_tready                   ( m_axis_rx_tready                        ),
    .m_axis_rx_tuser                    ( m_axis_rx_tuser                         ),
    .rx_np_ok                           ( rx_np_ok                                ),


    // Configuration (CFG) Interface
    // Configuration space access
    .cfg_do                             ( cfg_do                                  ),
    .cfg_rd_wr_done                     ( cfg_rd_wr_done                          ),
    .cfg_dwaddr                         ( cfg_dwaddr                              ),
    .cfg_rd_en                          ( cfg_rd_en                               ),
    // Error reporting
    .cfg_err_ur                         ( cfg_err_ur                              ),
    .cfg_err_cor                        ( cfg_err_cor                             ),
    .cfg_err_ecrc                       ( cfg_err_ecrc                            ),
    .cfg_err_cpl_timeout                ( cfg_err_cpl_timeout                     ),
    .cfg_err_cpl_abort                  ( cfg_err_cpl_abort                       ),
    .cfg_err_posted                     ( cfg_err_posted                          ),
    .cfg_err_locked                     ( cfg_err_locked                          ),
    .cfg_err_tlp_cpl_header             ( cfg_err_tlp_cpl_header                  ),
    .cfg_err_cpl_rdy                    ( cfg_err_cpl_rdy                         ),
    // Interrupt generation
    .cfg_interrupt                      ( cfg_interrupt                           ),
    .cfg_interrupt_rdy                  ( cfg_interrupt_rdy                       ),
    .cfg_interrupt_assert               ( cfg_interrupt_assert                    ),
    .cfg_interrupt_do                   ( cfg_interrupt_do                        ),
    .cfg_interrupt_di                   ( cfg_interrupt_di                        ),
    .cfg_interrupt_mmenable             ( cfg_interrupt_mmenable                  ),
    .cfg_interrupt_msienable            ( cfg_interrupt_msienable                 ),
    // Power management signaling
    .cfg_turnoff_ok                     ( cfg_turnoff_ok                          ),
    .cfg_to_turnoff                     ( cfg_to_turnoff                          ),
    .cfg_pm_wake                        ( cfg_pm_wake                             ),
    .cfg_pcie_link_state                ( cfg_pcie_link_state                     ),
    .cfg_trn_pending                    ( cfg_trn_pending                         ),
    // System configuration and status
    .cfg_dsn                            ( cfg_dsn                                 ),
    .cfg_bus_number                     ( cfg_bus_number                          ),
    .cfg_device_number                  ( cfg_device_number                       ),
    .cfg_function_number                ( cfg_function_number                     ),
    .cfg_status                         ( cfg_status                              ),
    .cfg_command                        ( cfg_command                             ),
    .cfg_dstatus                        ( cfg_dstatus                             ),
    .cfg_dcommand                       ( cfg_dcommand                            ),
    .cfg_lstatus                        ( cfg_lstatus                             ),
    .cfg_lcommand                       ( cfg_lcommand                            ),

    // System (SYS) Interface
    .sys_clk                            ( sys_clk_c                               ),
    .sys_reset                          ( !sys_reset_n_c                          ),
    .received_hot_reset                 (                                         )
  );

endmodule
