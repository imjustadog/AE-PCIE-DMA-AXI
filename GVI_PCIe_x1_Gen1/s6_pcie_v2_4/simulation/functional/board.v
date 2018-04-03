//-----------------------------------------------------------------------------
//
// (c) Copyright 2001, 2002, 2003, 2004, 2005, 2007, 2008, 2009 Xilinx, Inc. All rights reserved.
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
// File       : board.v
// Description: Top level testbench
//
//-----------------------------------------------------------------------------

`timescale 1ns/1ns

`define RX_LOG                       0
`define TX_LOG                       1
`define TRN_RX_TIMEOUT               5000

module board;

  parameter          REF_CLK_FREQ       = 0;  // 0 - 100 MHz, 1 - 125 MHz

  localparam         REF_CLK_HALF_CYCLE = (REF_CLK_FREQ == 0) ? 5000 :
                                          (REF_CLK_FREQ == 1) ? 4000 : 0;

  //
  // System reset
  //
  reg                sys_reset_n;

  //
  // System clocks
  //
  wire               rp_sys_clk;
  wire               ep_sys_clk_p;
  wire               ep_sys_clk_n;

  //
  // PCI-Express Serial Interconnect
  //
  wire               ep_pci_exp_txn;
  wire               ep_pci_exp_txp;
  wire               rp_pci_exp_txn;
  wire               rp_pci_exp_txp;

  //
  // PCI-Express Endpoint Instance
  //

  xilinx_pcie_1_1_ep_s6 #(
    .FAST_TRAIN("TRUE")
  )
  EP (
    // SYS Inteface
    .sys_clk_p(ep_sys_clk_p),
    .sys_clk_n(ep_sys_clk_n),
    .sys_reset_n(sys_reset_n),

    // PCI-Express Interface
    .pci_exp_txn(ep_pci_exp_txn),
    .pci_exp_txp(ep_pci_exp_txp),
    .pci_exp_rxn(rp_pci_exp_txn),
    .pci_exp_rxp(rp_pci_exp_txp),

    // Misc signals
    .led_0(led_0),
    .led_1(led_1),
    .led_2(led_2)
  );

  //
  // PCI-Express Model Root Port Instance
  //
  xilinx_pcie_2_0_rport_v6 #(
    .REF_CLK_FREQ(REF_CLK_FREQ),
    .PL_FAST_TRAIN("TRUE"),
    .RX_LOG(`RX_LOG),
    .TX_LOG(`TX_LOG),
    .TRN_RX_TIMEOUT(`TRN_RX_TIMEOUT)
  )
  RP (
    // SYS Inteface
    .sys_clk(rp_sys_clk),
    .sys_reset_n(sys_reset_n),

    // PCI-Express Interface
    .pci_exp_txn(rp_pci_exp_txn),
    .pci_exp_txp(rp_pci_exp_txp),
    .pci_exp_rxn(ep_pci_exp_txn),
    .pci_exp_rxp(ep_pci_exp_txp)
  );

  sys_clk_gen  # (
    .halfcycle(REF_CLK_HALF_CYCLE),
    .offset(0)
  )
  CLK_GEN_RP (
    .sys_clk(rp_sys_clk)
  );

  sys_clk_gen_ds #(
    .halfcycle(REF_CLK_HALF_CYCLE),
    .offset(0)
  )
  CLK_GEN_EP (
    .sys_clk_p(ep_sys_clk_p),
    .sys_clk_n(ep_sys_clk_n)
  );


  initial begin
    $display("[%t] : System Reset Asserted...", $realtime);
    sys_reset_n = 1'b0;

    repeat (500)
      @(posedge ep_sys_clk_p);

    $display("[%t] : System Reset De-asserted...", $realtime);
    sys_reset_n = 1'b1;
  end

  initial begin

    if ($test$plusargs ("dump_all")) begin

      `ifdef NCV // Cadence TRN dump

        $recordsetup("design=board",
                     "compress",
                     "wrapsize=100M",
                     "version=1",
                     "run=1");
        $recordvars();

      `elsif VCS //Synopsys VPD dump

        $vcdplusfile("board.vpd");
        $vcdpluson;
        $vcdplusglitchon;
        $vcdplusflush;

      `else

        // Verilog VC dump
        $dumpfile("board.vcd");
        $dumpvars(0, board);

      `endif // ModelSim dump is handled through simulate_mti.do script
    end
  end

`undef RX_LOG
`undef TX_LOG
`undef TRN_RX_TIMEOUT

endmodule // board
