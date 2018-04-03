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
//--            ** Copyright (C) 2008, Xilinx, Inc. **
//--            ** All Rights Reserved.             **
//--            **************************************
//--
//--------------------------------------------------------------------------------
//-- Filename: BMD_GEN2.v
//--
//-- Description: Bus Master Device (BMD) Module for Gen2 Directed Link Change
//--
//--          The module designed to operate with 64 bit interfaces.
//--
//--------------------------------------------------------------------------------

//`define ADD_CHIPSCOPE_GEN2

`timescale 1ns/1ns


`define BMD_GEN2_IDLE        3'b001
`define BMD_GEN2_SC          3'b010
`define BMD_GEN2_WC          3'b100



module BMD_GEN2 (
                      pl_directed_link_change,
                      pl_directed_link_width,
                      pl_directed_link_speed,
                      pl_directed_link_auton,
                      pl_sel_link_width,
                      pl_sel_link_rate,
                      pl_ltssm_state,
                      clk,
                      rst_n,

                      pl_speed_change_err,
                      pl_width_change_err,
                      clr_pl_width_change_err,
                      clr_pl_speed_change_err,
                      clear_directed_speed_change
);


input  [1:0]          pl_directed_link_change;
input  [1:0]          pl_directed_link_width;
input                 pl_directed_link_speed;
input                 pl_directed_link_auton;
input  [1:0]          pl_sel_link_width;
input                 pl_sel_link_rate;
input  [5:0]          pl_ltssm_state;
input                 clk;
input                 rst_n;

output                pl_speed_change_err;
output                pl_width_change_err;
input                 clr_pl_width_change_err;
input                 clr_pl_speed_change_err;
output                clear_directed_speed_change;

reg [2:0]             bmd_gen2_fsm;
reg                   pl_speed_change_err;
reg                   pl_width_change_err;
reg [1:0]             pl_sel_link_width_save;
reg                   pl_sel_link_rate_save;
reg                   polling_start;
reg                   clear_directed_WSC;
wire                  polling_exp;
wire                  clear_directed_speed_change;

reg [7:0]             poll_cntr_7_0;
reg [7:0]             poll_cntr_15_8;
reg [3:0]             poll_cntr_20_16;

assign polling_exp = poll_cntr_20_16[3] ? 1 : 0;
assign clear_directed_speed_change = polling_exp | clear_directed_WSC;

always @(posedge clk) begin

  if (!rst_n) begin

    pl_sel_link_width_save      <= 2'b0;
    pl_sel_link_rate_save       <= 1'b0;
    pl_speed_change_err         <= 1'b0;
    pl_width_change_err         <= 1'b0;
    polling_start               <= 1'b0;
    bmd_gen2_fsm                <= `BMD_GEN2_IDLE;
    poll_cntr_7_0               <= 8'h0;
    poll_cntr_15_8              <= 8'h0;
    poll_cntr_20_16             <= 4'h0;
    clear_directed_WSC          <= 1'b0;

  end else begin

    if (polling_start == 1) begin

      poll_cntr_7_0    <=  poll_cntr_7_0 + 1'b1;
      poll_cntr_15_8   <=  (poll_cntr_7_0 == 8'hff) ?  (poll_cntr_15_8 + 1'b1) : poll_cntr_15_8;
      poll_cntr_20_16  <=  ((poll_cntr_15_8 == 8'hff) & (poll_cntr_7_0 == 8'hff)) ?  (poll_cntr_20_16 + 1'b1) : poll_cntr_20_16;

    end else begin

      poll_cntr_7_0         <= 8'h0;
      poll_cntr_15_8        <= 8'h0;
      poll_cntr_20_16       <= 4'h0;

    end

    case (bmd_gen2_fsm)

      `BMD_GEN2_IDLE: begin

        pl_sel_link_rate_save    <= pl_sel_link_rate;
        pl_sel_link_width_save   <= pl_sel_link_width;
        clear_directed_WSC       <= 0;

        if (!clear_directed_WSC) begin

          if (pl_directed_link_change == 2'h01) begin  // Width change only

            polling_start         <= 1;
            bmd_gen2_fsm          <= `BMD_GEN2_WC;

          end else if (pl_directed_link_change != 2'h00) begin  // Either a Speed change or Width+Speed change

            polling_start         <= 1;
            bmd_gen2_fsm          <= `BMD_GEN2_SC;

          end else begin

            // Clear Previous Errors

            if (clr_pl_width_change_err)
              pl_width_change_err <= 0;
            if (clr_pl_speed_change_err)
              pl_speed_change_err <= 0;

            polling_start         <= 0;

          end

        end

      end

      `BMD_GEN2_SC: begin

        if (polling_exp == 0) begin

          // Check if link speed has changed and the LTSSM state is Recovery.Idle (speed change is complete)

          if ((pl_sel_link_rate != pl_sel_link_rate_save) && 
              (pl_ltssm_state == 6'h20)) begin

            if (pl_directed_link_change == 2'b10)  begin // speed chg only

              pl_speed_change_err          <= 1'b0;
              pl_width_change_err          <= 1'b0;
              clear_directed_WSC           <= 1;
              bmd_gen2_fsm                 <= `BMD_GEN2_IDLE;

            end else if (pl_directed_link_change == 2'b11) begin // speed && width chg

              pl_speed_change_err          <= 1'b0;
              pl_width_change_err          <= 1'b0;
              clear_directed_WSC           <= 0;
              bmd_gen2_fsm                 <= `BMD_GEN2_WC;

            end

          end

        end else begin // polling_exp == 1

          if (pl_directed_link_change == 2'b10)  begin // speed chg timeout

            pl_speed_change_err    <= 1'b1;
            pl_width_change_err    <= 1'b0;

          end else if (pl_directed_link_change == 2'b11) begin // speed && width chg timeout

            pl_speed_change_err    <= 1'b1;
            pl_width_change_err    <= 1'b1;

          end

          polling_start             <= 0;
          clear_directed_WSC        <= 1;
          bmd_gen2_fsm              <= `BMD_GEN2_IDLE;

        end

      end

      `BMD_GEN2_WC: begin

        if (polling_exp == 0) begin

          // Check if link width has changed and the LTSSM state is Cfg.Idle (width change is complete)

          if ((pl_sel_link_width != pl_sel_link_width_save) &&
              (pl_ltssm_state == 6'h15)) begin

            pl_speed_change_err           <= 1'b0;
            pl_width_change_err           <= 1'b0;
            clear_directed_WSC            <= 1;
            bmd_gen2_fsm                  <= `BMD_GEN2_IDLE;

          end  

        end else begin // timeout

          pl_speed_change_err           <= 1'b0;
          pl_width_change_err           <= 1'b1;
          polling_start                 <= 0;
          clear_directed_WSC            <= 0;
          bmd_gen2_fsm                  <= `BMD_GEN2_WC;

        end

      end

    endcase

  end

end

`ifdef ADD_CHIPSCOPE_GEN2
wire [35 : 0] CONTROL0;

chipscope_icon_v1_03_a icon (.CONTROL0(CONTROL0)) /* synthesis syn_noprune=1 */;

chipscope_ila_v1_02_a ila (.CLK(clk),
                           .CONTROL(CONTROL0),
                           .DATA ({      // 160
        pl_directed_link_change,	// 44:43
        pl_directed_link_width,		// 42:41
        pl_directed_link_speed,		// 40
        pl_directed_link_auton,		// 39
        pl_sel_link_width,		// 38:37
        pl_sel_link_rate,		// 36
        pl_speed_change_err,		// 35
        pl_width_change_err,		// 34
        clr_pl_width_change_err,	// 33
        clr_pl_speed_change_err,	// 32
        clear_directed_speed_change,	// 31
        bmd_gen2_fsm,			// 30:28
        pl_sel_link_width_save,		// 27:26
        pl_sel_link_rate_save,		// 25
        clr_pl_width_change_err,	// 24
        clr_pl_speed_change_err,	// 23
        clear_directed_WSC,  		// 22
        polling_exp,   		 	// 21
        poll_cntr_20_16,                // 20:16
        poll_cntr_15_8,                 // 15:8
        poll_cntr_7_0,                  // 7:0
                                 }),

                           .TRIG0 ({     // 16
                                pl_directed_link_change,
                                pl_sel_link_width,
                                pl_sel_link_rate

                                  })
                          ) /* synthesis syn_noprune=1 */;


endmodule

module chipscope_ila_v1_02_a (
  CLK, CONTROL, DATA, TRIG0
) /* synthesis syn_black_box */;
  input CLK;
  inout [35 : 0] CONTROL;
  input [159 : 0] DATA;
  input [15 : 0] TRIG0;

endmodule

module chipscope_icon_v1_03_a (
CONTROL0
) /* synthesis syn_black_box */;
  inout [35 : 0] CONTROL0;
`endif






endmodule




