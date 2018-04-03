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
// File       : pci_exp_usrapp_rx.v
//-----------------------------------------------------------------------------

`timescale 1ns / 1ps

`define EXPECT_FINISH_CHECK board.RP.com_tests.expect_finish_check

module pci_exp_usrapp_rx #(
  parameter    TCQ            = 1,
  parameter    RX_LOG         = 0,
  parameter    TRN_RX_TIMEOUT = 5000
)
(
  output reg                                 trn_rdst_rdy_n,
  output reg                                 trn_rnp_ok_n,

  input       [(64 - 1):0]                   trn_rd,
  input       [(8 - 1):0]                    trn_rrem_n,
  input                                      trn_rsof_n,
  input                                      trn_reof_n,
  input                                      trn_rsrc_rdy_n,
  input                                      trn_rsrc_dsc_n,
  input                                      trn_rerrfwd_n,
  input       [(7 - 1):0]                    trn_rbar_hit_n,

  input                                      trn_clk,
  input                                      trn_reset_n,
  input                                      trn_lnk_up_n
);

/* Local variables */

reg               next_trn_rdst_rdy_n;
reg               next_trn_rnp_ok_n;

reg     [4:0]     trn_rx_state, next_trn_rx_state;
reg               trn_rx_in_frame, next_trn_rx_in_frame;
reg               trn_rx_in_channel, next_trn_rx_in_channel;

reg     [31:0]    next_trn_rx_timeout;

/* State variables */

localparam        TRN_RX_RESET    = 5'b00001;
localparam        TRN_RX_DOWN     = 5'b00010;
localparam        TRN_RX_IDLE     = 5'b00100;
localparam        TRN_RX_ACTIVE   = 5'b01000;
localparam        TRN_RX_SRC_DSC  = 5'b10000;


/* Transaction Receive User Interface State Machine */


always @(posedge trn_clk or negedge trn_reset_n) begin

  if (trn_reset_n == 1'b0) begin

    trn_rx_state     <= #(TCQ)  TRN_RX_RESET;

  end else begin

  case (trn_rx_state)

    TRN_RX_RESET :  begin

      if (trn_reset_n == 1'b0)

        trn_rx_state <= #(TCQ) TRN_RX_RESET;

      else

        trn_rx_state <= #(TCQ) TRN_RX_DOWN;
    end

    TRN_RX_DOWN : begin

      if (trn_lnk_up_n == 1'b1)

        trn_rx_state <= #(TCQ) TRN_RX_DOWN;

      else begin

        trn_rx_state <= #(TCQ) TRN_RX_IDLE;
      end

    end

    TRN_RX_IDLE : begin

      if (trn_reset_n == 1'b0)

        trn_rx_state <= #(TCQ) TRN_RX_RESET;

      else if (trn_lnk_up_n == 1'b1)

        trn_rx_state <= #(TCQ) TRN_RX_DOWN;

      else begin

        if (  (trn_rsof_n == 1'b0) &&
              (trn_rsrc_rdy_n == 1'b0) &&
               (trn_rdst_rdy_n == 1'b0)  ) begin

          board.RP.com_usrapp.TSK_READ_DATA(0, RX_LOG, trn_rd, trn_rrem_n);

          trn_rx_state <= #(TCQ) TRN_RX_ACTIVE;

        end else begin

          trn_rx_state <= #(TCQ) TRN_RX_IDLE;

        end
      end

    end

    TRN_RX_ACTIVE : begin

      if (trn_reset_n == 1'b0)

        trn_rx_state <= #(TCQ) TRN_RX_RESET;

      else if (trn_lnk_up_n == 1'b1)

        trn_rx_state <= #(TCQ) TRN_RX_DOWN;

      else if (  (trn_rsrc_rdy_n == 1'b0) &&
                (trn_reof_n == 1'b0) &&
                 (trn_rdst_rdy_n == 1'b0)  ) begin

        board.RP.com_usrapp.TSK_READ_DATA(1, RX_LOG, trn_rd, trn_rrem_n);
        board.RP.com_usrapp.TSK_PARSE_FRAME(RX_LOG);

        trn_rx_state <= #(TCQ) TRN_RX_IDLE;

      end else if (  (trn_rsrc_rdy_n == 1'b0) &&
                     (trn_rdst_rdy_n == 1'b0)  ) begin

        board.RP.com_usrapp.TSK_READ_DATA(0, RX_LOG, trn_rd, trn_rrem_n);

        trn_rx_state <= #(TCQ) TRN_RX_ACTIVE;

      end else if (  (trn_rsrc_rdy_n == 1'b0) &&
          (trn_reof_n == 1'b0) &&
          (trn_rsrc_dsc_n == 1'b0)  ) begin

        board.RP.com_usrapp.TSK_READ_DATA(1, RX_LOG, trn_rd, trn_rrem_n);
        board.RP.com_usrapp.TSK_PARSE_FRAME(RX_LOG);

        trn_rx_state <= #(TCQ) TRN_RX_SRC_DSC;

      end else begin

        trn_rx_state <= #(TCQ) TRN_RX_ACTIVE;
      end

    end

    TRN_RX_SRC_DSC : begin

      if (trn_reset_n == 1'b0)

        trn_rx_state <= #(TCQ) TRN_RX_RESET;

      else if (trn_lnk_up_n == 1'b1)

        trn_rx_state <= #(TCQ) TRN_RX_DOWN;

      else begin

        trn_rx_state <= #(TCQ) TRN_RX_IDLE;

      end
    end

  endcase

   end

end

reg [1:0]   trn_rdst_rdy_toggle_count;
reg [8:0]   trn_rnp_ok_toggle_count;

always @(posedge trn_clk or negedge trn_reset_n) begin

   if (trn_reset_n == 1'b0) begin

    trn_rnp_ok_n        <= #(TCQ)   1'b0;
    trn_rdst_rdy_n      <= #(TCQ)       1'b0;
    trn_rdst_rdy_toggle_count <= #(TCQ) $random;
    trn_rnp_ok_toggle_count <=  #(TCQ)     $random;

   end else begin

    if (trn_rnp_ok_toggle_count == 0) begin

        trn_rnp_ok_n        <= #(TCQ)   !trn_rnp_ok_n;
        trn_rnp_ok_toggle_count <=  #(TCQ)     $random;

    end else begin

        //trn_rnp_ok_toggle_count   <=  #(TCQ)     trn_rnp_ok_toggle_count - 1;

    end

    if (trn_rdst_rdy_toggle_count == 0) begin

        //trn_rdst_rdy_n      <= #(TCQ)       !trn_rdst_rdy_n;
        trn_rdst_rdy_toggle_count <= #(TCQ) $random;

    end else begin

        //trn_rdst_rdy_toggle_count <= trn_rdst_rdy_toggle_count - 1;
    end

   end

end

/* Transaction Receive Timeout */
reg [31:0] sim_timeout;
initial
begin
  sim_timeout = TRN_RX_TIMEOUT;
end

always @(trn_clk or trn_rsof_n or trn_rsrc_rdy_n) begin

    if (next_trn_rx_timeout == 0) begin
        if(!`EXPECT_FINISH_CHECK)
          $display("[%t] : TEST FAILED --- Haven't Received All Expected TLPs", $realtime);

        $finish(2);
    end

    if ((trn_rsof_n == 1'b0) && (trn_rsrc_rdy_n == 1'b0)) begin

        next_trn_rx_timeout = sim_timeout;

    end else begin

        if (trn_lnk_up_n == 1'b0)

            next_trn_rx_timeout = next_trn_rx_timeout - 1'b1;

    end

end

`undef EXPECT_FINISH_CHECK

endmodule // pci_exp_usrapp_rx

