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
//-- Filename: BMD_INTR_CTRL.v
//--
//-- Description: Endpoint Intrrupt Controller
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns


`define BMD_INTR_RST      3'b001
`define BMD_INTR_RD       3'b010
`define BMD_INTR_WR       3'b100

`define BMD_INTR_RD_RST   4'b0001
`define BMD_INTR_RD_ACT   4'b0010
`define BMD_INTR_RD_ACT2  4'b0100
`define BMD_INTR_RD_DUN   4'b1000

`define BMD_INTR_WR_RST   4'b0001
`define BMD_INTR_WR_ACT   4'b0010
`define BMD_INTR_WR_ACT2  4'b0100
`define BMD_INTR_WR_DUN   4'b1000

module BMD_INTR_CTRL (
                      clk,                   // I
                      rst_n,                 // I

                      init_rst_i,            // I

                      mrd_done_i,            // I
                      mwr_done_i,            // I

                      msi_on,                // I

                      cfg_interrupt_assert_n_o, // O
                      cfg_interrupt_rdy_n_i,    // I
                      cfg_interrupt_n_o,        // O
                      cfg_interrupt_legacyclr   // I
       
                      );

    input             clk;
    input             rst_n;

    input             init_rst_i;

    input             mrd_done_i;
    input             mwr_done_i;

    input             msi_on;

    output            cfg_interrupt_assert_n_o;
    input             cfg_interrupt_rdy_n_i;
    output            cfg_interrupt_n_o;
    input             cfg_interrupt_legacyclr;

    // Local Registers

    reg [2:0]         intr_state;
    reg [2:0]         next_intr_state;
    reg [3:0]         rd_intr_state;
    reg [3:0]         next_rd_intr_state;
    reg [3:0]         wr_intr_state;
    reg [3:0]         next_wr_intr_state;

    reg               rd_intr_n;
    reg               rd_intr_assert_n;
    reg               wr_intr_n;
    reg               wr_intr_assert_n;

    reg               mrd_done;
    reg               mwr_done;

    wire              mrd_exp;
    wire              mwr_exp;

    parameter         Tcq = 1;

    assign cfg_interrupt_n_o = rd_intr_n  & wr_intr_n;
    assign cfg_interrupt_assert_n_o = rd_intr_assert_n & wr_intr_assert_n;

    //
    // Resolve mrd_done_i and mwr_done_i
    //

    always @(mrd_done_i or mwr_done_i or rd_intr_state or intr_state or rd_intr_state or wr_intr_state) begin
    
      case (intr_state) /* synthesis full_case */ /* synthesis parallel_case */
      
        `BMD_INTR_RST : begin
        
          if (mrd_done_i)  begin

            mrd_done = 1'b1;
            mwr_done = 1'b0;
            next_intr_state = `BMD_INTR_RD;

          end else if (mwr_done_i) begin

            mrd_done = 1'b0;
            mwr_done = 1'b1;
            next_intr_state = `BMD_INTR_WR;

          end else begin

            mrd_done = 1'b0;
            mwr_done = 1'b0;
            next_intr_state = `BMD_INTR_RST;

          end

        end

        `BMD_INTR_RD : begin

          if (mwr_done_i && (rd_intr_state == `BMD_INTR_RD_DUN)) begin

            mwr_done = 1'b1;
            mrd_done = 1'b1;

          end else begin

            mwr_done = 1'b0;
            mrd_done = 1'b1;

          end

          next_intr_state = `BMD_INTR_RD;
        
        end

        `BMD_INTR_WR : begin

          if (mrd_done_i && (wr_intr_state == `BMD_INTR_WR_DUN)) begin

            mrd_done = 1'b1;
            mwr_done = 1'b1;

          end else begin

            mrd_done = 1'b0;
            mwr_done = 1'b1;

          end

          next_intr_state = `BMD_INTR_WR;

        end

      endcase

    end

    //
    // Read Interrupt Control
    // 

    always @(rd_intr_state or mrd_done or cfg_interrupt_rdy_n_i or mrd_exp or msi_on) begin

      case (rd_intr_state) /* synthesis full_case */ /* synthesis parallel_case */

        `BMD_INTR_RD_RST : begin

          if (mrd_done) begin
            rd_intr_n = 1'b0;
            rd_intr_assert_n = 1'b0;

            if (!cfg_interrupt_rdy_n_i)
               next_rd_intr_state = `BMD_INTR_RD_ACT;
            else
               next_rd_intr_state = `BMD_INTR_RD_RST;

          end else begin
            rd_intr_n = 1'b1;
            rd_intr_assert_n = 1'b1;
            next_rd_intr_state = `BMD_INTR_RD_RST;
          end
        

        end

        `BMD_INTR_RD_ACT : begin
     
          if (msi_on) begin

            rd_intr_n = 1'b1;
            rd_intr_assert_n = 1'b1;
            next_rd_intr_state = `BMD_INTR_RD_DUN;

          end else begin

            rd_intr_n = 1'b1;
            rd_intr_assert_n = 1'b1;
            next_rd_intr_state = `BMD_INTR_RD_ACT2;

          end

        end


        `BMD_INTR_RD_ACT2 : begin
          if (cfg_interrupt_legacyclr) begin
            rd_intr_n = 1'b0;
            rd_intr_assert_n = 1'b1;

            if (!cfg_interrupt_rdy_n_i)
               next_rd_intr_state = `BMD_INTR_RD_DUN;
            else
               next_rd_intr_state = `BMD_INTR_RD_ACT2;

          end else begin
            rd_intr_n = 1'b1;
            rd_intr_assert_n = 1'b1;
            next_rd_intr_state = `BMD_INTR_RD_ACT2;
          end
        end


        `BMD_INTR_RD_DUN : begin

          rd_intr_n = 1'b1;
          rd_intr_assert_n = 1'b1;
          next_rd_intr_state = `BMD_INTR_RD_DUN;

        end
        
      endcase

    end


    //
    // Write Interrupt Control
    // 
    always @(wr_intr_state or mwr_done or cfg_interrupt_rdy_n_i or cfg_interrupt_legacyclr or msi_on) begin

      case (wr_intr_state) /* synthesis full_case */ /* synthesis parallel_case */

        `BMD_INTR_WR_RST : begin


          if (mwr_done) begin
            wr_intr_n = 1'b0;
            wr_intr_assert_n = 1'b0;

            if (!cfg_interrupt_rdy_n_i)
               next_wr_intr_state = `BMD_INTR_WR_ACT;
            else
               next_wr_intr_state = `BMD_INTR_WR_RST;

          end else begin
            wr_intr_n = 1'b1;
            wr_intr_assert_n = 1'b1;
            next_wr_intr_state = `BMD_INTR_WR_RST;
          end

        end

        `BMD_INTR_WR_ACT : begin

          if (msi_on) begin

            wr_intr_n = 1'b1;
            wr_intr_assert_n = 1'b0;
            next_wr_intr_state = `BMD_INTR_WR_DUN;

          end else begin

            wr_intr_n = 1'b1;
            wr_intr_assert_n = 1'b0;
            next_wr_intr_state = `BMD_INTR_WR_ACT2;

          end

        end

        `BMD_INTR_WR_ACT2 : begin
          if (cfg_interrupt_legacyclr) begin
            wr_intr_n = 1'b0;
            wr_intr_assert_n = 1'b1;

            if (!cfg_interrupt_rdy_n_i)
               next_wr_intr_state = `BMD_INTR_WR_DUN;
            else
               next_wr_intr_state = `BMD_INTR_WR_ACT2;

          end else begin
            wr_intr_n = 1'b1;
            wr_intr_assert_n = 1'b0;
            next_wr_intr_state = `BMD_INTR_WR_ACT2;
          end
        end


        `BMD_INTR_WR_DUN : begin

          wr_intr_n = 1'b1;
          wr_intr_assert_n = 1'b1;
          next_wr_intr_state = `BMD_INTR_WR_DUN;

        end
        
      endcase

    end



    always @(posedge clk ) begin
    
        if ( !rst_n ) begin

          rd_intr_state <= #(Tcq) `BMD_INTR_RD_RST;
          wr_intr_state <= #(Tcq) `BMD_INTR_WR_RST;
          intr_state    <= #(Tcq) `BMD_INTR_RST;

        end else begin

          if (init_rst_i) begin

            rd_intr_state <= #(Tcq) `BMD_INTR_RD_RST;
            wr_intr_state <= #(Tcq) `BMD_INTR_WR_RST;
            intr_state    <= #(Tcq) `BMD_INTR_RST;

          end else begin

            rd_intr_state <= #(Tcq) next_rd_intr_state;
            wr_intr_state <= #(Tcq) next_wr_intr_state;
            intr_state <= #(Tcq) next_intr_state;

          end

        end

    end

endmodule

