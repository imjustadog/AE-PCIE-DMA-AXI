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
//-- Filename: BMD_EP_MEM_ACCESS.v
//--
//-- Description: Endpoint Memory Access Unit. This module provides access functions
//--              to the Endpoint memory aperture.
//--
//--              Read Access: Module returns data for the specifed address and
//--              byte enables selected. 
//-- 
//--              Write Access: Module accepts data, byte enables and updates
//--              data when write enable is asserted. Modules signals write busy 
//--              when data write is in progress. 
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

`define BMD_MEM_ACCESS_WR_RST     3'b000
`define BMD_MEM_ACCESS_WR_WAIT    3'b001
`define BMD_MEM_ACCESS_WR_READ    3'b010
`define BMD_MEM_ACCESS_WR_WRITE   3'b100

module BMD_EP_MEM_ACCESS#
  (
   parameter INTERFACE_TYPE = 4'b0010,
   parameter FPGA_FAMILY = 8'h14

)
   (

                     clk,
                     rst_n,

                     // Misc. control ports

                     cfg_cap_max_lnk_width, // I [5:0]
                     cfg_neg_max_lnk_width, // I [5:0]

                     cfg_cap_max_payload_size,  // I [2:0]
                     cfg_prg_max_payload_size,  // I [2:0]
                     cfg_max_rd_req_size,       // I [2:0]

                     // Read Access

                     addr_i,        // I [6:0]     

                     rd_be_i,       // I [3:0] 
                     rd_data_o,     // O [31:0]

                     // Write Access

                     wr_be_i,       // I [7:0]
                     wr_data_i,     // I [31:0]
                     wr_en_i,       // I 
                     wr_busy_o,     // O 

                     init_rst_o,    // O

                     mrd_start_o,   // O
                     mrd_int_dis_o, // O
                     mrd_done_o,    // O
                     mrd_addr_o,    // O [31:0]
                     mrd_len_o,     // O [31:0]
                     mrd_count_o,   // O [31:0]
                     mrd_tlp_tc_o,  // O [2:0]
                     mrd_64b_en_o,  // O
                     mrd_phant_func_dis1_o, // O
                     mrd_up_addr_o, // O [7:0]
                     mrd_relaxed_order_o,   // O
                     mrd_nosnoop_o,         // O
                     mrd_wrr_cnt_o,         // O [7:0]


                     mwr_start_o,   // O
                     mwr_int_dis_o, // O
                     mwr_done_i,    // I
                     mwr_addr_o,    // O [31:0]
                     mwr_len_o,     // O [31:0]
                     mwr_count_o,   // O [31:0]
                     mwr_data_o,    // O [31:0]
                     mwr_tlp_tc_o,  // O [2:0]
                     mwr_64b_en_o,  // O
                     mwr_phant_func_dis1_o, // O
                     mwr_up_addr_o, // O [7:0]
                     mwr_relaxed_order_o,   // O
                     mwr_nosnoop_o,         // O
                     mwr_wrr_cnt_o,         // O [7:0]

`ifdef PCIE2_0
                     pl_directed_link_change,
                     pl_ltssm_state,
                     pl_directed_link_width,
                     pl_directed_link_speed,
                     pl_directed_link_auton,
                     pl_upstream_preemph_src,
                     pl_sel_link_width,
                     pl_sel_link_rate,
                     pl_link_gen2_capable,
                     pl_link_partner_gen2_supported,
                     pl_initial_link_width,
                     pl_link_upcfg_capable,
                     pl_lane_reversal_mode,

                     pl_width_change_err,
                     pl_speed_change_err,
                     clr_pl_width_change_err,
                     clr_pl_speed_change_err,
                     clear_directed_speed_change,
`endif

                     cpl_ur_found_i,     // I [7:0]
                     cpl_ur_tag_i,       // I [7:0]

                     cpld_data_o,        // O [31:0]
                     cpld_found_i,       // I [31:0]
                     cpld_data_size_i,   // I [31:0]
                     cpld_malformed_i,   // I
                     cpld_data_err_i,    // I

                     cpl_streaming_o,    // O
                     rd_metering_o,      // O
                     cfg_interrupt_di,   // O
                     cfg_interrupt_do,   // I
                     cfg_interrupt_mmenable,    // I
                     cfg_interrupt_msienable,   // I
                     cfg_interrupt_legacyclr,   // O

                     trn_rnp_ok_n_o,            // O
                     trn_tstr_n_o               // O

                     );

    input            clk;
    input            rst_n;

    /*
     * Misc. control ports
     */

    input [5:0]      cfg_cap_max_lnk_width;
    input [5:0]      cfg_neg_max_lnk_width;

    input [2:0]      cfg_cap_max_payload_size;
    input [2:0]      cfg_prg_max_payload_size;
    input [2:0]      cfg_max_rd_req_size;
 
    /*
     *  Read Port
     */
    
    input  [6:0]     addr_i;
    input  [3:0]     rd_be_i;
    output [31:0]    rd_data_o;

    /*
     *  Write Port
     */

    input  [7:0]     wr_be_i;
    input  [31:0]    wr_data_i;
    input            wr_en_i;
    output           wr_busy_o;

    output           init_rst_o;

    output           mrd_start_o;
    output           mrd_int_dis_o;
    output           mrd_done_o;
    output [31:0]    mrd_addr_o;
    output [31:0]    mrd_len_o;
    output [2:0]     mrd_tlp_tc_o;
    output           mrd_64b_en_o;
    output           mrd_phant_func_dis1_o;
    output [7:0]     mrd_up_addr_o;
    output [31:0]    mrd_count_o;
    output           mrd_relaxed_order_o;
    output           mrd_nosnoop_o;
    output [7:0]     mrd_wrr_cnt_o;

    output           mwr_start_o;
    output           mwr_int_dis_o;
    input            mwr_done_i;
    output [31:0]    mwr_addr_o;
    output [31:0]    mwr_len_o;
    output [31:0]    mwr_count_o;
    output [31:0]    mwr_data_o;
    output [2:0]     mwr_tlp_tc_o;
    output           mwr_64b_en_o;
    output           mwr_phant_func_dis1_o;
    output [7:0]     mwr_up_addr_o;
    output           mwr_relaxed_order_o;
    output           mwr_nosnoop_o;
    output [7:0]     mwr_wrr_cnt_o;

    input  [7:0]     cpl_ur_found_i;
    input  [7:0]     cpl_ur_tag_i;

    output [31:0]    cpld_data_o;
    input  [31:0]    cpld_found_i;
    input  [31:0]    cpld_data_size_i;
    input            cpld_malformed_i;
    input            cpld_data_err_i;
    output           cpl_streaming_o;
    output           rd_metering_o;
    output           trn_rnp_ok_n_o;
    output           trn_tstr_n_o;

    output [7:0]     cfg_interrupt_di;
    input  [7:0]     cfg_interrupt_do;
    input  [2:0]     cfg_interrupt_mmenable;
    input            cfg_interrupt_msienable;
    output           cfg_interrupt_legacyclr;

`ifdef PCIE2_0
    output [1:0]     pl_directed_link_change;
    input  [5:0]     pl_ltssm_state;
    output [1:0]     pl_directed_link_width;
    output           pl_directed_link_speed;
    output           pl_directed_link_auton;
    output           pl_upstream_preemph_src;
    input  [1:0]     pl_sel_link_width;
    input            pl_sel_link_rate;
    input            pl_link_gen2_capable;
    input            pl_link_partner_gen2_supported;
    input  [2:0]     pl_initial_link_width;
    input            pl_link_upcfg_capable;
    input  [1:0]     pl_lane_reversal_mode;

    input            pl_width_change_err;
    input            pl_speed_change_err;
    output           clr_pl_width_change_err;
    output           clr_pl_speed_change_err;
    input            clear_directed_speed_change;
`endif


    wire [31:0]      mem_rd_data;
    wire [31:0]      w_pre_wr_data;

    reg              mem_write_en;
    reg   [31:0]     pre_wr_data;
    reg   [31:0]     mem_wr_data;

    reg    [3:0]     wr_mem_state;  

    /*
     * Memory Write Controller 
     */

    wire [6:0]       mem_addr = addr_i; 

    /*
     *  Extract current data bytes. These need to be swizzled
     *  memory storage format : 
     *    data[31:0] = { byte[3], byte[2], byte[1], byte[0] (lowest addr) }  
     */

    wire  [7:0]      w_pre_wr_data_b3 = pre_wr_data[31:24];
    wire  [7:0]      w_pre_wr_data_b2 = pre_wr_data[23:16];
    wire  [7:0]      w_pre_wr_data_b1 = pre_wr_data[15:08];
    wire  [7:0]      w_pre_wr_data_b0 = pre_wr_data[07:00];

    /*
     *  Extract new data bytes from payload
     *  TLP Payload format : 
     *    data[31:0] = { byte[0] (lowest addr), byte[2], byte[1], byte[3] }  
     */

    wire  [7:0]      w_wr_data_b3 = wr_data_i[07:00];
    wire  [7:0]      w_wr_data_b2 = wr_data_i[15:08];
    wire  [7:0]      w_wr_data_b1 = wr_data_i[23:16];
    wire  [7:0]      w_wr_data_b0 = wr_data_i[31:24];

    always @(posedge clk ) begin

        if ( !rst_n ) begin

          pre_wr_data    <= 32'b0;
          mem_write_en   <= 1'b0;
          mem_wr_data    <= 32'b0;

          wr_mem_state <= `BMD_MEM_ACCESS_WR_RST;
        
        end else begin

          case ( wr_mem_state )

            `BMD_MEM_ACCESS_WR_RST : begin

              mem_write_en <= 1'b0;

              if (wr_en_i) begin // read state
           
                wr_mem_state <= `BMD_MEM_ACCESS_WR_READ ;
            
              end else begin

                wr_mem_state <= `BMD_MEM_ACCESS_WR_RST;

              end

            end

            `BMD_MEM_ACCESS_WR_READ : begin

              mem_write_en <= 1'b0;
              pre_wr_data  <= mem_rd_data; 

              wr_mem_state <= `BMD_MEM_ACCESS_WR_WRITE;

            end

            `BMD_MEM_ACCESS_WR_WRITE : begin

              /*
               * Merge new enabled data and write target location
               */

              mem_wr_data  <= {{wr_be_i[3] ? w_wr_data_b3 : w_pre_wr_data_b3},
                               {wr_be_i[2] ? w_wr_data_b2 : w_pre_wr_data_b2},
                               {wr_be_i[1] ? w_wr_data_b1 : w_pre_wr_data_b1},
                               {wr_be_i[0] ? w_wr_data_b0 : w_pre_wr_data_b0}};
              mem_write_en <= 1'b1;

              wr_mem_state <= `BMD_MEM_ACCESS_WR_RST;

            end

          endcase

        end

    end

    /* 
     * Write controller busy 
     */

    assign wr_busy_o = wr_en_i | (wr_mem_state != `BMD_MEM_ACCESS_WR_RST);

    /*
     *  Memory Read Controller
     */

    /* Handle Read byte enables */

    assign rd_data_o = {{rd_be_i[0] ? mem_rd_data[07:00] : 8'h0},
                        {rd_be_i[1] ? mem_rd_data[15:08] : 8'h0}, 
                        {rd_be_i[2] ? mem_rd_data[23:16] : 8'h0}, 
                        {rd_be_i[3] ? mem_rd_data[31:24] : 8'h0}};

    BMD_EP_MEM# (
        .INTERFACE_TYPE(INTERFACE_TYPE),
        .FPGA_FAMILY(FPGA_FAMILY)
    
    ) EP_MEM (

                      .clk(clk),
                      .rst_n(rst_n),

                      .cfg_cap_max_lnk_width(cfg_cap_max_lnk_width), // I [5:0]
                      .cfg_neg_max_lnk_width(cfg_neg_max_lnk_width), // I [5:0]

                      .cfg_cap_max_payload_size(cfg_cap_max_payload_size), // I [2:0]
                      .cfg_prg_max_payload_size(cfg_prg_max_payload_size), // I [2:0]
                      .cfg_max_rd_req_size(cfg_max_rd_req_size),           // I [2:0]

                      .a_i(mem_addr[6:0]),                  // I [6:0]
                      .wr_en_i(mem_write_en),               // I
                      .rd_d_o(mem_rd_data),                 // O [31:0]
                      .wr_d_i(mem_wr_data),                 // I [31:0]

                      .init_rst_o(init_rst_o),              // O

                      .mrd_start_o(mrd_start_o),            // O
                      .mrd_int_dis_o(mrd_int_dis_o),        // O
                      .mrd_done_o(mrd_done_o),              // O
                      .mrd_addr_o(mrd_addr_o),              // O [31:0]
                      .mrd_len_o(mrd_len_o),                // O [31:0]
                      .mrd_count_o(mrd_count_o),            // O [31:0]
                      .mrd_tlp_tc_o(mrd_tlp_tc_o),          // O [2:0]
                      .mrd_64b_en_o(mrd_64b_en_o),          // O
                      .mrd_phant_func_dis1_o(mrd_phant_func_dis1_o), // O
                      .mrd_up_addr_o(mrd_up_addr_o),        // O [7:0]
                      .mrd_relaxed_order_o(mrd_relaxed_order_o), // O
                      .mrd_nosnoop_o(mrd_nosnoop_o),        // O
                      .mrd_wrr_cnt_o(mrd_wrr_cnt_o),        // O [7:0]

                      .mwr_start_o(mwr_start_o),            // O
                      .mwr_int_dis_o(mwr_int_dis_o),        // O
                      .mwr_done_i(mwr_done_i),              // I
                      .mwr_addr_o(mwr_addr_o),              // O [31:0]
                      .mwr_len_o(mwr_len_o),                // O [31:0]
                      .mwr_count_o(mwr_count_o),            // O [31:0]
                      .mwr_data_o(mwr_data_o),              // O [31:0]
                      .mwr_tlp_tc_o(mwr_tlp_tc_o),          // O [2:0]
                      .mwr_64b_en_o(mwr_64b_en_o),          // O
                      .mwr_phant_func_dis1_o(mwr_phant_func_dis1_o), // O
                      .mwr_up_addr_o(mwr_up_addr_o),        // O [7:0]
                      .mwr_relaxed_order_o(mwr_relaxed_order_o), // O
                      .mwr_nosnoop_o(mwr_nosnoop_o),        // O
                      .mwr_wrr_cnt_o(mwr_wrr_cnt_o),        // O [7:0]

`ifdef PCIE2_0

                      .pl_directed_link_change( pl_directed_link_change ),
                      .pl_ltssm_state( pl_ltssm_state ),
                      .pl_directed_link_width( pl_directed_link_width ),
                      .pl_directed_link_speed( pl_directed_link_speed ),
                      .pl_directed_link_auton( pl_directed_link_auton ),
                      .pl_upstream_preemph_src( pl_upstream_preemph_src ),
                      .pl_sel_link_width( pl_sel_link_width ),
                      .pl_sel_link_rate( pl_sel_link_rate ),
                      .pl_link_gen2_capable( pl_link_gen2_capable ),
                      .pl_link_partner_gen2_supported( pl_link_partner_gen2_supported ),
                      .pl_initial_link_width( pl_initial_link_width ),
                      .pl_link_upcfg_capable( pl_link_upcfg_capable ),
                      .pl_lane_reversal_mode( pl_lane_reversal_mode ),
                      .pl_speed_change_err_i(pl_speed_change_err),
                      .pl_width_change_err_i(pl_width_change_err),
                      .clr_pl_width_change_err(clr_pl_width_change_err),
                      .clr_pl_speed_change_err(clr_pl_speed_change_err),
                      .clear_directed_speed_change_i( clear_directed_speed_change ),
`endif

                      .cpl_ur_found_i(cpl_ur_found_i),      // I
                      .cpl_ur_tag_i(cpl_ur_tag_i),          // I [7:0]

                      .cpld_data_o(cpld_data_o),            // O [31:0]
                      .cpld_found_i(cpld_found_i),          // I [31:0]
                      .cpld_data_size_i(cpld_data_size_i),  // I [31:0]
                      .cpld_malformed_i(cpld_malformed_i),  // I
                      .cpld_data_err_i(cpld_data_err_i),    // I
                      .cpl_streaming_o(cpl_streaming_o),    // O
                      .rd_metering_o(rd_metering_o),        // O
                      .cfg_interrupt_di(cfg_interrupt_di),  // O
                      .cfg_interrupt_do(cfg_interrupt_do),  // I
                      .cfg_interrupt_mmenable(cfg_interrupt_mmenable),    // I
                      .cfg_interrupt_msienable(cfg_interrupt_msienable),  // I
                      .cfg_interrupt_legacyclr(cfg_interrupt_legacyclr),  // O
                      .trn_rnp_ok_n_o(trn_rnp_ok_n_o),                    // O
                      .trn_tstr_n_o (trn_tstr_n_o)                        // O

                     );


endmodule

