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
//-- Filename: BMD_64_RX_ENGINE.v
//--
//-- Description: 64 bit Local-Link Receive Unit.
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

`define BMD_64_RX_RST            8'b00000001
`define BMD_64_RX_MEM_RD32_QW1   8'b00000010
`define BMD_64_RX_MEM_RD32_WT    8'b00000100
`define BMD_64_RX_MEM_WR32_QW1   8'b00001000
`define BMD_64_RX_MEM_WR32_WT    8'b00010000
`define BMD_64_RX_CPL_QW1        8'b00100000
`define BMD_64_RX_CPLD_QW1       8'b01000000
`define BMD_64_RX_CPLD_QWN       8'b10000000

`define BMD_MEM_RD32_FMT_TYPE    7'b00_00000
`define BMD_MEM_WR32_FMT_TYPE    7'b10_00000
`define BMD_CPL_FMT_TYPE         7'b00_01010
`define BMD_CPLD_FMT_TYPE        7'b10_01010

module BMD_RX_ENGINE (

                        clk,
                        rst_n,

                        /*
                         * Initiator reset
                         */

                        init_rst_i,

                        /*
                         * Receive local link interface from PCIe core
                         */
                    
                        trn_rd,  
                        trn_rrem_n,
                        trn_rsof_n,
                        trn_reof_n,
                        trn_rsrc_rdy_n,
                        trn_rsrc_dsc_n,
                        trn_rdst_rdy_n,
                        trn_rbar_hit_n,

                        /*
                         * Memory Read data handshake with Completion 
                         * transmit unit. Transmit unit reponds to 
                         * req_compl assertion and responds with compl_done
                         * assertion when a Completion w/ data is transmitted. 
                         */

                        req_compl_o,
                        compl_done_i,

                        addr_o,                    // Memory Read Address

                        req_tc_o,                  // Memory Read TC
                        req_td_o,                  // Memory Read TD
                        req_ep_o,                  // Memory Read EP
                        req_attr_o,                // Memory Read Attribute
                        req_len_o,                 // Memory Read Length (1DW)
                        req_rid_o,                 // Memory Read Requestor ID
                        req_tag_o,                 // Memory Read Tag
                        req_be_o,                  // Memory Read Byte Enables

                        /* 
                         * Memory interface used to save 1 DW data received 
                         * on Memory Write 32 TLP. Data extracted from
                         * inbound TLP is presented to the Endpoint memory
                         * unit. Endpoint memory unit reacts to wr_en_o
                         * assertion and asserts wr_busy_i when it is 
                         * processing written information.
                         */

                        wr_be_o,                   // Memory Write Byte Enable
                        wr_data_o,                 // Memory Write Data
                        wr_en_o,                   // Memory Write Enable
                        wr_busy_i,                  // Memory Write Busy

                        /*
                         * Completion no Data
                         */

                        cpl_ur_found_o,
                        cpl_ur_tag_o,

                        /*
                         * Completion with Data
                         */
                        
                        cpld_data_i,
                        cpld_found_o,
                        cpld_data_size_o,
                        cpld_malformed_o,
                        cpld_data_err_o
                         

                       );

    input              clk;
    input              rst_n;

    input              init_rst_i;

    input [63:0]       trn_rd;
    input [7:0]        trn_rrem_n;
    input              trn_rsof_n;
    input              trn_reof_n;
    input              trn_rsrc_rdy_n;
    input              trn_rsrc_dsc_n;
    output             trn_rdst_rdy_n;
    input [6:0]        trn_rbar_hit_n;
 
    output             req_compl_o;
    input              compl_done_i;

    output [10:0]      addr_o;

    output [2:0]       req_tc_o;
    output             req_td_o;
    output             req_ep_o;
    output [1:0]       req_attr_o;
    output [9:0]       req_len_o;
    output [15:0]      req_rid_o;
    output [7:0]       req_tag_o;
    output [7:0]       req_be_o;

    output [7:0]       wr_be_o;
    output [31:0]      wr_data_o;
    output             wr_en_o;
    input              wr_busy_i;

    output [7:0]       cpl_ur_found_o;
    output [7:0]       cpl_ur_tag_o;

    input  [31:0]      cpld_data_i;
    output [31:0]      cpld_found_o;
    output [31:0]      cpld_data_size_o;
    output             cpld_malformed_o;
    output             cpld_data_err_o;

    // Local wire

    wire   [31:0]      cpld_data_i_sw = {cpld_data_i[07:00],
                                         cpld_data_i[15:08],
                                         cpld_data_i[23:16],
                                         cpld_data_i[31:24]};

    // Local Registers

    reg [7:0]          bmd_64_rx_state;

    reg                trn_rdst_rdy_n;

    reg                req_compl_o;

    reg [2:0]          req_tc_o;
    reg                req_td_o;
    reg                req_ep_o;
    reg [1:0]          req_attr_o;
    reg [9:0]          req_len_o;
    reg [15:0]         req_rid_o;
    reg [7:0]          req_tag_o;
    reg [7:0]          req_be_o;

    reg [10:0]         addr_o;
    reg [7:0]          wr_be_o;
    reg [31:0]         wr_data_o;
    reg                wr_en_o;

    reg [7:0]          cpl_ur_found_o;
    reg [7:0]          cpl_ur_tag_o;

    reg [31:0]         cpld_found_o;
    reg [31:0]         cpld_data_size_o;
    reg                cpld_malformed_o;
    reg                cpld_data_err_o;

    //reg [9:0]          cpld_real_size;
    //reg [9:0]          cpld_tlp_size;
    reg [6:0]          cpld_real_size;
    reg [6:0]          cpld_tlp_size;

    reg [7:0]          bmd_64_rx_state_q;
    reg [63:0]         trn_rd_q;
    reg [7:0]          trn_rrem_n_q;
    reg                trn_reof_n_q;
    reg                trn_rsrc_rdy_n_q;

    always @ ( posedge clk ) begin
              
        if (!rst_n ) begin

          bmd_64_rx_state   <= `BMD_64_RX_RST;

          trn_rdst_rdy_n <= 1'b0;

          req_compl_o    <= 1'b0;

          req_tc_o       <= 2'b0;
          req_td_o       <= 1'b0;
          req_ep_o       <= 1'b0;
          req_attr_o     <= 2'b0;
          req_len_o      <= 10'b0;
          req_rid_o      <= 16'b0;
          req_tag_o      <= 8'b0;
          req_be_o       <= 8'b0;
          addr_o         <= 31'b0;

          wr_be_o        <= 8'b0;
          wr_data_o      <= 31'b0;
          wr_en_o        <= 1'b0;
          
          cpl_ur_found_o   <= 8'b0;
          cpl_ur_tag_o     <= 8'b0;

          cpld_found_o     <= 32'b0;
          cpld_data_size_o <= 32'b0;
          cpld_malformed_o <= 1'b0;

          cpld_real_size   <= 7'b0;
          cpld_tlp_size    <= 7'b0;

          bmd_64_rx_state_q <= `BMD_64_RX_RST;
          trn_rd_q          <= 64'b0;
          trn_rrem_n_q      <= 8'b0;
          trn_reof_n_q      <= 1'b1;
          trn_rsrc_rdy_n_q  <= 1'b1;

        end else begin

          wr_en_o        <= 1'b0;
          req_compl_o    <= 1'b0;
          trn_rdst_rdy_n <= 1'b0;
 
          if (init_rst_i) begin

            bmd_64_rx_state  <= `BMD_64_RX_RST;

            cpl_ur_found_o   <= 8'b0;
            cpl_ur_tag_o     <= 8'b0;
   
            cpld_found_o     <= 32'b0;
            cpld_data_size_o <= 32'b0;
            cpld_malformed_o <= 1'b0;

            cpld_real_size   <= 7'b0;
            cpld_tlp_size    <= 7'b0;

            bmd_64_rx_state_q <= `BMD_64_RX_RST;
            trn_rd_q          <= 64'b0;
            trn_rrem_n_q      <= 8'b0;
            trn_reof_n_q      <= 1'b1;
            trn_rsrc_rdy_n_q  <= 1'b1;

         end

         bmd_64_rx_state_q <= `BMD_64_RX_RST;
         trn_rd_q          <= 64'b0;
         trn_rrem_n_q      <= 8'b0;
         trn_reof_n_q      <= 1'b1;
         trn_rsrc_rdy_n_q  <= 1'b1;

         case (bmd_64_rx_state)

           `BMD_64_RX_RST : begin

             if ((!trn_rsof_n) && 
                 (!trn_rsrc_rdy_n) && 
                 (!trn_rdst_rdy_n)) begin
            
               case (trn_rd[62:56]) 

                 `BMD_MEM_RD32_FMT_TYPE : begin

                   if (trn_rd[41:32] == 10'b1) begin
    
                     req_tc_o     <= trn_rd[54:52];  
                     req_td_o     <= trn_rd[47];
                     req_ep_o     <= trn_rd[46]; 
                     req_attr_o   <= trn_rd[45:44]; 
                     req_len_o    <= trn_rd[41:32]; 
                     req_rid_o    <= trn_rd[31:16]; 
                     req_tag_o    <= trn_rd[15:08]; 
                     req_be_o     <= trn_rd[07:00];

                     bmd_64_rx_state <= `BMD_64_RX_MEM_RD32_QW1;
    
                   end else
                     bmd_64_rx_state <= `BMD_64_RX_RST;

                 end
             
                 `BMD_MEM_WR32_FMT_TYPE : begin
    
                   if (trn_rd[41:32] == 10'b1) begin
    
                     wr_be_o      <= trn_rd[07:00];
                     bmd_64_rx_state <= `BMD_64_RX_MEM_WR32_QW1;
                    
                   end else
                     bmd_64_rx_state <= `BMD_64_RX_RST;

    
                 end
    
                 `BMD_CPL_FMT_TYPE : begin
    
                   if (trn_rd[15:12] != 3'b000) begin
    
                     cpl_ur_found_o <= cpl_ur_found_o + 1'b1;
                     bmd_64_rx_state   <= `BMD_64_RX_CPL_QW1;
    
                   end else
                     bmd_64_rx_state   <= `BMD_64_RX_RST;
    
                 end
    
                 `BMD_CPLD_FMT_TYPE : begin
                   
                   cpld_data_size_o <= cpld_data_size_o + trn_rd[41:32];
                   cpld_tlp_size    <= trn_rd[38:32];
                   cpld_found_o     <= cpld_found_o  + 1'b1;
                   cpld_real_size   <= 7'b0;
                   bmd_64_rx_state  <= `BMD_64_RX_CPLD_QW1;
                   
                 end
                 
                 default : begin
    
                   bmd_64_rx_state   <= `BMD_64_RX_RST;
    
                 end
              
               endcase

             end else
               bmd_64_rx_state   <= `BMD_64_RX_RST;

           end

           `BMD_64_RX_MEM_RD32_QW1 : begin

             if ((!trn_reof_n) && 
                 (!trn_rsrc_rdy_n) && 
                 (!trn_rdst_rdy_n)) begin

               addr_o            <= trn_rd[63:34];
               req_compl_o       <= 1'b1;
               trn_rdst_rdy_n    <= 1'b1;
               bmd_64_rx_state   <= `BMD_64_RX_MEM_RD32_WT;

             end else
               bmd_64_rx_state   <= `BMD_64_RX_MEM_RD32_QW1;

           end

           `BMD_64_RX_MEM_RD32_WT: begin

             trn_rdst_rdy_n <= 1'b1;
             if (compl_done_i)
               bmd_64_rx_state   <= `BMD_64_RX_RST;
             else begin

               req_compl_o       <= 1'b1;
               trn_rdst_rdy_n    <= 1'b1;
               bmd_64_rx_state   <= `BMD_64_RX_MEM_RD32_WT;

             end

           end

           `BMD_64_RX_MEM_WR32_QW1 : begin

             if ((!trn_reof_n) && 
                 (!trn_rsrc_rdy_n) && 
                 (!trn_rdst_rdy_n)) begin

               addr_o           <= trn_rd[44:34];
               wr_data_o        <= trn_rd[31:00];
               wr_en_o          <= 1'b1;
               trn_rdst_rdy_n   <= 1'b1;
               bmd_64_rx_state  <= `BMD_64_RX_MEM_WR32_WT;

             end else
               bmd_64_rx_state  <= `BMD_64_RX_MEM_WR32_QW1;

           end

           `BMD_64_RX_MEM_WR32_WT: begin

             trn_rdst_rdy_n <= 1'b1;
             if (!wr_busy_i)
               bmd_64_rx_state  <= `BMD_64_RX_RST;
             else
               bmd_64_rx_state  <= `BMD_64_RX_MEM_WR32_WT;

           end

           `BMD_64_RX_CPL_QW1 : begin

             if ((!trn_reof_n) && 
                 (!trn_rsrc_rdy_n) && 
                 (!trn_rdst_rdy_n)) begin

               cpl_ur_tag_o     <= trn_rd[47:40];
               bmd_64_rx_state  <= `BMD_64_RX_RST;

             end else
               bmd_64_rx_state  <= `BMD_64_RX_CPL_QW1;

           end

           `BMD_64_RX_CPLD_QW1 : begin

             bmd_64_rx_state_q <= bmd_64_rx_state;
             trn_rd_q          <= trn_rd;
             trn_rrem_n_q      <= trn_rrem_n;
             trn_reof_n_q      <= trn_reof_n;
             trn_rsrc_rdy_n_q  <= trn_rsrc_rdy_n;

             if ((!trn_reof_n) && 
                 (!trn_rsrc_rdy_n) && 
                 (!trn_rdst_rdy_n)) begin

               cpld_real_size  <= cpld_real_size  + 1'b1;

               if (cpld_tlp_size != 1'b1)
                 cpld_malformed_o <= 1'b1;
               if (trn_rrem_n != 8'h00)
                 cpld_malformed_o <= 1'b1;

               bmd_64_rx_state  <= `BMD_64_RX_RST;

             end else if ((!trn_rsrc_rdy_n) && 
                          (!trn_rdst_rdy_n)) begin

               cpld_real_size   <= cpld_real_size  + 1'b1;
               bmd_64_rx_state  <= `BMD_64_RX_CPLD_QWN;

             end else
               bmd_64_rx_state   <= `BMD_64_RX_CPLD_QW1;

           end

           `BMD_64_RX_CPLD_QWN : begin

             bmd_64_rx_state_q <= bmd_64_rx_state;
             trn_rd_q          <= trn_rd;
             trn_rrem_n_q      <= trn_rrem_n;
             trn_reof_n_q      <= trn_reof_n;
             trn_rsrc_rdy_n_q  <= trn_rsrc_rdy_n;

             if ((!trn_reof_n) && 
                 (!trn_rsrc_rdy_n) && 
                 (!trn_rdst_rdy_n)) begin

               if (trn_rrem_n == 8'h0F) begin

                 cpld_real_size   <= cpld_real_size  + 1'h1;
                 if (cpld_tlp_size  != cpld_real_size  + 1'h1)
                   cpld_malformed_o <= 1'b1;

               end else begin

                 cpld_real_size   <= cpld_real_size  + 2'h2;
                 if (cpld_tlp_size  != cpld_real_size  + 2'h2)
                   cpld_malformed_o <= 1'b1;

               end 
               bmd_64_rx_state  <= `BMD_64_RX_RST;

             end else if ((!trn_rsrc_rdy_n) && 
                          (!trn_rdst_rdy_n)) begin

               cpld_real_size   <= cpld_real_size  + 2'h2;
               bmd_64_rx_state  <= `BMD_64_RX_CPLD_QWN;

             end else
               bmd_64_rx_state   <= `BMD_64_RX_CPLD_QWN;

           end

         endcase

      end   

    end       

    always @ ( posedge clk ) begin
              
      if (!rst_n ) begin

        cpld_data_err_o <= 1'b0;

      end else begin

        if (init_rst_i)
          cpld_data_err_o <= 1'b0;
        else begin

          case (bmd_64_rx_state_q)

            `BMD_64_RX_CPLD_QW1 : begin

              if (cpld_data_err_o == 1'b0)
                if (trn_rd_q[31:00] != cpld_data_i_sw)
                  cpld_data_err_o <= 1'b1;

            end

            `BMD_64_RX_CPLD_QWN : begin

              if (!trn_reof_n_q) begin
  
                if (trn_rrem_n_q == 8'h0F) begin
  
                  if (cpld_data_err_o == 1'b0)
                    if (trn_rd_q[63:32] != cpld_data_i_sw)
                      cpld_data_err_o <= 1'b1;
                 
                end else if (trn_rrem_n_q == 8'h00) begin
  
                   if (cpld_data_err_o == 1'b0)
                     if (trn_rd_q != {cpld_data_i_sw, cpld_data_i_sw})
                       cpld_data_err_o <= 1'b1;
  
                end else  // Invalid remainder
                   cpld_data_err_o <= 1'b1;
  
              end else begin
  
                if (cpld_data_err_o == 1'b0)
                  if (trn_rd_q != {cpld_data_i_sw, cpld_data_i_sw})
                    cpld_data_err_o <= 1'b1;
  
              end

            end

          endcase

        end

      end

    end


endmodule // BMD_64_RX_ENGINE
