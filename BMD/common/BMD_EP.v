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
//-- Filename: BMD_EP.v
//--
//-- Description: Bus Master Device I/O Endpoint module. 
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns


module BMD_EP#
  (
   parameter INTERFACE_WIDTH = 64,
   parameter INTERFACE_TYPE = 4'b0010,
   parameter FPGA_FAMILY = 8'h14

)
    (
                        clk,                 
                        rst_n,              

                        // LocalLink Tx

                        trn_td,
                        trn_trem_n,

                        trn_tsof_n,
                        trn_teof_n,
                        trn_tsrc_dsc_n,
                        trn_tsrc_rdy_n,
                        trn_tdst_dsc_n,
                        trn_tdst_rdy_n,
                        trn_tbuf_av,
                        trn_tstr_n,
        
                        // LocalLink Rx

                        trn_rd,

                        trn_rrem_n,

                        trn_rsof_n,
                        trn_reof_n,
                        trn_rsrc_rdy_n,
                        trn_rsrc_dsc_n,
                        trn_rdst_rdy_n,
                        trn_rbar_hit_n,
                        trn_rnp_ok_n,


                        trn_rcpl_streaming_n,


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
`endif        
                        // Turnoff access

                        req_compl_o,
                        compl_done_o,

                        // Configuration access
        
                        cfg_interrupt_n,
                        cfg_interrupt_rdy_n,
                        cfg_interrupt_assert_n,
                        cfg_interrupt_di,
                        cfg_interrupt_do,
                        cfg_interrupt_mmenable,
                        cfg_interrupt_msienable,
                        cfg_completer_id,

                        cfg_ext_tag_en,

                        cfg_cap_max_lnk_width,
                        cfg_neg_max_lnk_width,

                        cfg_cap_max_payload_size,
                        cfg_prg_max_payload_size,
                        cfg_max_rd_req_size,
                        cfg_msi_enable,
                        cfg_rd_comp_bound,

                        cfg_phant_func_en,
                        cfg_phant_func_supported,


                        cpld_data_size_hwm,
                        cpld_size,
                        cur_rd_count_hwm,
                        cur_mrd_count,

                        cfg_bus_mstr_enable
        
                       );

    input              clk;
    input              rst_n;

    // LocalLink Tx
    

    output [INTERFACE_WIDTH-1:0]     trn_td;
    output [(INTERFACE_WIDTH/8)-1:0]      trn_trem_n;

    output            trn_tsof_n;
    output            trn_teof_n;
    output            trn_tsrc_dsc_n;
    output            trn_tsrc_rdy_n;
    input             trn_tdst_dsc_n;
    input             trn_tdst_rdy_n;
    input  [5:0]      trn_tbuf_av;
    output            trn_tstr_n;
    
    // LocalLink Rx
    

    input [INTERFACE_WIDTH-1:0]      trn_rd;
    input [(INTERFACE_WIDTH/8)-1:0]       trn_rrem_n;

    input             trn_rsof_n;
    input             trn_reof_n;
    input             trn_rsrc_rdy_n;
    input             trn_rsrc_dsc_n;
    output            trn_rdst_rdy_n;
    input [6:0]       trn_rbar_hit_n;
    output            trn_rnp_ok_n;


    output            trn_rcpl_streaming_n;


`ifdef PCIE2_0

    output [1:0]      pl_directed_link_change;
    input  [5:0]      pl_ltssm_state; 
    output [1:0]      pl_directed_link_width;
    output            pl_directed_link_speed;
    output            pl_directed_link_auton;
    output            pl_upstream_preemph_src;
    input  [1:0]      pl_sel_link_width;
    input             pl_sel_link_rate;
    input             pl_link_gen2_capable;
    input             pl_link_partner_gen2_supported;
    input  [2:0]      pl_initial_link_width;
    input             pl_link_upcfg_capable;
    input  [1:0]      pl_lane_reversal_mode;

`endif
    
    output            req_compl_o;
    output            compl_done_o;
    
    output            cfg_interrupt_n;
    input             cfg_interrupt_rdy_n;
    output            cfg_interrupt_assert_n;

    output [7:0]      cfg_interrupt_di;
    input  [7:0]      cfg_interrupt_do;
    input  [2:0]      cfg_interrupt_mmenable;
    input             cfg_interrupt_msienable;

    input [15:0]      cfg_completer_id;
    input             cfg_ext_tag_en;
    input             cfg_bus_mstr_enable;
    input [5:0]       cfg_cap_max_lnk_width;
    input [5:0]       cfg_neg_max_lnk_width;

    input [2:0]       cfg_cap_max_payload_size;
    input [2:0]       cfg_prg_max_payload_size;
    input [2:0]       cfg_max_rd_req_size;
    input             cfg_msi_enable;
    input             cfg_rd_comp_bound;

    input             cfg_phant_func_en;
    input [1:0]       cfg_phant_func_supported;

    output [31:0]     cpld_data_size_hwm;     // HWMark for Completion Data (DWs)
    output [15:0]     cur_rd_count_hwm;       // HWMark for Read Count Allowed
    output [31:0]     cpld_size;
    output [15:0]     cur_mrd_count;



    // Local wires
    
    wire  [10:0]      rd_addr; 
    wire  [3:0]       rd_be; 
    wire  [31:0]      rd_data; 

    wire  [10:0]      req_addr; 

    wire  [7:0]       wr_be; 
    wire  [31:0]      wr_data; 
    wire              wr_en;
    wire              wr_busy;

    wire              req_compl;
    wire              compl_done;

    wire  [2:0]       req_tc;
    wire              req_td; 
    wire              req_ep; 
    wire  [1:0]       req_attr; 
    wire  [9:0]       req_len;
    wire  [15:0]      req_rid;
    wire  [7:0]       req_tag;
    wire  [7:0]       req_be;

    wire              init_rst;

    wire              mwr_start;
    wire              mwr_int_dis_o; 
    wire              mwr_done;
    wire  [31:0]      mwr_len;
    wire  [7:0]       mwr_tag;
    wire  [3:0]       mwr_lbe;
    wire  [3:0]       mwr_fbe;
    wire  [31:0]      mwr_addr;
    wire  [31:0]      mwr_count;
    wire  [31:0]      mwr_data;
    wire  [2:0]       mwr_tlp_tc_o;  
    wire              mwr_64b_en_o;
    wire              mwr_phant_func_en1;
    wire  [7:0]       mwr_up_addr_o;
    wire              mwr_relaxed_order;
    wire              mwr_nosnoop;
    wire  [7:0]       mwr_wrr_cnt;

    wire              mrd_start;
    wire              mrd_int_dis_o; 
    wire              mrd_done;
    wire  [31:0]      mrd_len;
    wire  [7:0]       mrd_tag;
    wire  [3:0]       mrd_lbe;
    wire  [3:0]       mrd_fbe;
    wire  [31:0]      mrd_addr;
    wire  [31:0]      mrd_count;
    wire  [2:0]       mrd_tlp_tc_o;  
    wire              mrd_64b_en_o;
    wire              mrd_phant_func_en1;
    wire  [7:0]       mrd_up_addr_o;
    wire              mrd_relaxed_order;
    wire              mrd_nosnoop;
    wire  [7:0]       mrd_wrr_cnt;
                     
    wire  [7:0]       cpl_ur_found;
    wire  [7:0]       cpl_ur_tag;

    wire  [31:0]      cpld_data;
    wire  [31:0]      cpld_found;
    wire  [31:0]      cpld_size;
    wire              cpld_malformed;
    wire              cpld_data_err;

    wire              mrd_start_o;
    wire [15:0]       cur_mrd_count;

    wire              cpl_streaming;              
    wire              rd_metering;
    wire              trn_rnp_ok_n_o;
    wire              trn_tstr_n_o;
    wire              cfg_interrupt_legacyclr;

`ifdef PCIE2_0

    wire [1:0]        pl_directed_link_change_o;
    wire [1:0]        pl_directed_link_width_o;
    wire              pl_directed_link_speed_o;
    wire              pl_directed_link_auton_o;

    reg  [5:0]        pl_ltssm_state_user; 
    reg  [1:0]        pl_sel_link_width_user;
    reg               pl_sel_link_rate_user;
    reg               pl_link_gen2_capable_user;
    reg               pl_link_partner_gen2_supported_user;
    reg  [2:0]        pl_initial_link_width_user;
    reg               pl_link_upcfg_capable_user;
    reg  [1:0]        pl_lane_reversal_mode_user;

`endif

    assign            trn_rnp_ok_n = trn_rnp_ok_n_o;
    assign            trn_tstr_n = trn_tstr_n_o;


    assign            trn_rcpl_streaming_n = ~cpl_streaming;



`ifdef PCIE2_0

   // Convert to user clock domain to ease timing for gen2 designs

   always @(posedge clk) begin

     if (!rst_n) begin

       pl_ltssm_state_user <= 6'b0; 
       pl_sel_link_width_user <= 2'b0;
       pl_sel_link_rate_user <= 1'b0;
       pl_link_gen2_capable_user <= 1'b0;
       pl_link_partner_gen2_supported_user <= 1'b0;
       pl_initial_link_width_user <= 3'b0;
       pl_link_upcfg_capable_user <= 1'b0;
       pl_lane_reversal_mode_user <= 2'b0;
    
     end else begin

       pl_ltssm_state_user <= pl_ltssm_state; 
       pl_sel_link_width_user <= pl_sel_link_width;
       pl_sel_link_rate_user <= pl_sel_link_rate;
       pl_link_gen2_capable_user <= pl_link_gen2_capable;
       pl_link_partner_gen2_supported_user <= pl_link_partner_gen2_supported;
       pl_initial_link_width_user <= pl_initial_link_width;
       pl_link_upcfg_capable_user <= pl_link_upcfg_capable;
       pl_lane_reversal_mode_user <= pl_lane_reversal_mode;
   
     end

   end

`endif


    //
    // ENDPOINT MEMORY : 
    // 

    BMD_EP_MEM_ACCESS#(
         .INTERFACE_TYPE(INTERFACE_TYPE),
        .FPGA_FAMILY(FPGA_FAMILY)
    )
       EP_MEM (

                   .clk(clk),                           // I
                   .rst_n(rst_n),                       // I

                   .cfg_cap_max_lnk_width(cfg_cap_max_lnk_width), // I [5:0]
                   .cfg_neg_max_lnk_width(cfg_neg_max_lnk_width), // I [5:0]

                   .cfg_cap_max_payload_size(cfg_cap_max_payload_size), // I [2:0]
                   .cfg_prg_max_payload_size(cfg_prg_max_payload_size), // I [2:0]
                   .cfg_max_rd_req_size(cfg_max_rd_req_size),           // I [2:0]

                   .addr_i(req_addr[6:0]),              // I [10:0]

                   // Read Port

                   .rd_be_i(rd_be),                     // I [3:0]
                   .rd_data_o(rd_data),                 // O [31:0]

                   // Write Port

                   .wr_be_i(wr_be),                     // I [7:0]
                   .wr_data_i(wr_data),                 // I [31:0]
                   .wr_en_i(wr_en),                     // I
                   .wr_busy_o(wr_busy),                 // O

                   .init_rst_o(init_rst),               // O

                   .mrd_start_o(mrd_start),             // O
                   .mrd_int_dis_o(mrd_int_dis_o),       // O
                   .mrd_done_o(mrd_done),               // O
                   .mrd_addr_o(mrd_addr),               // O [31:0]
                   .mrd_len_o(mrd_len),                 // O [31:0]
                   .mrd_count_o(mrd_count),             // O [31:0]
                   .mrd_tlp_tc_o(mrd_tlp_tc_o),         // O [2:0]
                   .mrd_64b_en_o(mrd_64b_en_o),         // O
                   .mrd_phant_func_dis1_o(mrd_phant_func_dis1), // O
                   .mrd_up_addr_o(mrd_up_addr_o),       // O [7:0]
                   .mrd_relaxed_order_o(mrd_relaxed_order), // O
                   .mrd_nosnoop_o(mrd_nosnoop),         // O
                   .mrd_wrr_cnt_o(mrd_wrr_cnt),         // O [7:0]

                   .mwr_start_o(mwr_start),             // O
                   .mwr_int_dis_o(mwr_int_dis_o),       // O
                   .mwr_done_i(mwr_done),               // I
                   .mwr_addr_o(mwr_addr),               // O [31:0]
                   .mwr_len_o(mwr_len),                 // O [31:0]
                   .mwr_count_o(mwr_count),             // O [31:0]
                   .mwr_data_o(mwr_data),               // O [31:0]
                   .mwr_tlp_tc_o(mwr_tlp_tc_o),         // O [2:0]
                   .mwr_64b_en_o(mwr_64b_en_o),         // O
                   .mwr_phant_func_dis1_o(mwr_phant_func_dis1), // O
                   .mwr_up_addr_o(mwr_up_addr_o),       // O [7:0]
                   .mwr_relaxed_order_o(mwr_relaxed_order), // O
                   .mwr_nosnoop_o(mwr_nosnoop),         // O
                   .mwr_wrr_cnt_o(mwr_wrr_cnt),         // O [7:0]

                   .cpl_ur_found_i(cpl_ur_found),       // I [7:0]
                   .cpl_ur_tag_i(cpl_ur_tag),           // I [7:0]

`ifdef PCIE2_0
                   .pl_directed_link_change( pl_directed_link_change ),
                   .pl_ltssm_state( pl_ltssm_state_user ),
                   .pl_directed_link_width( pl_directed_link_width ),
                   .pl_directed_link_speed( pl_directed_link_speed ),
                   .pl_directed_link_auton( pl_directed_link_auton ),
                   .pl_upstream_preemph_src( pl_upstream_preemph_src ),
                   .pl_sel_link_width( pl_sel_link_width_user ),
                   .pl_sel_link_rate( pl_sel_link_rate_user ),
                   .pl_link_gen2_capable( pl_link_gen2_capable_user ),
                   .pl_link_partner_gen2_supported( pl_link_partner_gen2_supported_user ),
                   .pl_initial_link_width( pl_initial_link_width_user ),
                   .pl_link_upcfg_capable( pl_link_upcfg_capable_user ),
                   .pl_lane_reversal_mode( pl_lane_reversal_mode_user ),
     
                   .pl_width_change_err( pl_width_change_err ),
                   .pl_speed_change_err( pl_speed_change_err ),
                   .clr_pl_width_change_err( clr_pl_width_change_err ),
                   .clr_pl_speed_change_err( clr_pl_speed_change_err ),
                   .clear_directed_speed_change( clear_directed_speed_change ),
`endif

                   .cpld_data_o(cpld_data),             // O [31:0]
                   .cpld_found_i(cpld_found),           // I [31:0]
                   .cpld_data_size_i(cpld_size),        // I [31:0]
                   .cpld_malformed_i(cpld_malformed),   // I 
                   .cpld_data_err_i(cpld_data_err),     // I
                   .cpl_streaming_o(cpl_streaming),     // O
                   .rd_metering_o(rd_metering),         // O
                   .cfg_interrupt_di(cfg_interrupt_di),         // O
                   .cfg_interrupt_do(cfg_interrupt_do),         // I
                   .cfg_interrupt_mmenable(cfg_interrupt_mmenable),     // I
                   .cfg_interrupt_msienable(cfg_interrupt_msienable),   // I
                   .cfg_interrupt_legacyclr(cfg_interrupt_legacyclr),   // O

                   .trn_rnp_ok_n_o(trn_rnp_ok_n_o),      // O
                   .trn_tstr_n_o ( trn_tstr_n_o  )       // O


                   );



`ifdef PCIE2_0

   BMD_GEN2 BMD_GEN2_I (

                   .pl_directed_link_change(pl_directed_link_change),
                   .pl_directed_link_width(pl_directed_link_width),
                   .pl_directed_link_speed(pl_directed_link_speed),
                   .pl_directed_link_auton(pl_directed_link_auton),
                   .pl_sel_link_width(pl_sel_link_width_user),
                   .pl_sel_link_rate(pl_sel_link_rate_user),
                   .pl_ltssm_state( pl_ltssm_state_user ),
                   .clk(clk),
                   .rst_n(rst_n),
     
                   .pl_width_change_err(pl_width_change_err),
                   .pl_speed_change_err(pl_speed_change_err),
                   .clr_pl_width_change_err(clr_pl_width_change_err),
                   .clr_pl_speed_change_err(clr_pl_speed_change_err),
                   .clear_directed_speed_change(clear_directed_speed_change)

                   );
`endif


    //
    // Local-Link Receive Controller :
    // 

    BMD_RX_ENGINE EP_RX (

                   .clk(clk),                           // I
                   .rst_n(rst_n),                       // I

                   .init_rst_i(init_rst),               // I

                   // LocalLink Rx
                   .trn_rd(trn_rd),                     // I [63/31:0]

                   .trn_rrem_n(trn_rrem_n),             // I [7:0]

                   .trn_rsof_n(trn_rsof_n),             // I
                   .trn_reof_n(trn_reof_n),             // I
                   .trn_rsrc_rdy_n(trn_rsrc_rdy_n),     // I
                   .trn_rsrc_dsc_n(trn_rsrc_dsc_n),     // I
                   .trn_rdst_rdy_n(trn_rdst_rdy_n),     // O
                   .trn_rbar_hit_n (trn_rbar_hit_n),    // I [6:0]

                   // Handshake with Tx engine 

                   .req_compl_o(req_compl),             // O
                   .compl_done_i(compl_done),           // I

                   .addr_o(req_addr),                   // O [10:0]

                   .req_tc_o(req_tc),                   // O [2:0]
                   .req_td_o(req_td),                   // O
                   .req_ep_o(req_ep),                   // O
                   .req_attr_o(req_attr),               // O [1:0]
                   .req_len_o(req_len),                 // O [9:0]
                   .req_rid_o(req_rid),                 // O [15:0]
                   .req_tag_o(req_tag),                 // O [7:0]
                   .req_be_o(req_be),                   // O [7:0]

                   // Memory Write Port

                   .wr_be_o(wr_be),                     // O [7:0]
                   .wr_data_o(wr_data),                 // O [31:0]
                   .wr_en_o(wr_en),                     // O
                   .wr_busy_i(wr_busy),                 // I
        
                   .cpl_ur_found_o(cpl_ur_found),       // O [7:0]
                   .cpl_ur_tag_o(cpl_ur_tag),           // O [7:0]

                   .cpld_data_i(cpld_data),             // I [31:0]
                   .cpld_found_o(cpld_found),           // O [31:0]
                   .cpld_data_size_o(cpld_size),        // O [31:0]
                   .cpld_malformed_o(cpld_malformed),   // O 
                   .cpld_data_err_o(cpld_data_err)      // O

                   
                   );

    //
    // Local-Link Transmit Controller
    // 

    BMD_TX_ENGINE EP_TX (

                   .clk(clk),                         // I
                   .rst_n(rst_n),                     // I

                   // LocalLink Tx
                   .trn_td(trn_td),                   // O [63/31:0]

                   .trn_trem_n(trn_trem_n),           // O [7:0]

                   .trn_tsof_n(trn_tsof_n),           // O
                   .trn_teof_n(trn_teof_n),           // O
                   .trn_tsrc_dsc_n(trn_tsrc_dsc_n),   // O
                   .trn_tsrc_rdy_n(trn_tsrc_rdy_n),   // O
                   .trn_tdst_dsc_n(trn_tdst_dsc_n),   // I
                   .trn_tdst_rdy_n(trn_tdst_rdy_n),   // I
                   .trn_tbuf_av(trn_tbuf_av),         // I [5:0]

                   // Handshake with Rx engine 
                   .req_compl_i(req_compl),           // I
                   .compl_done_o(compl_done),         // 0

                   .req_tc_i(req_tc),                 // I [2:0]
                   .req_td_i(req_td),                 // I
                   .req_ep_i(req_ep),                 // I
                   .req_attr_i(req_attr),             // I [1:0]
                   .req_len_i(req_len),               // I [9:0]
                   .req_rid_i(req_rid),               // I [15:0]
                   .req_tag_i(req_tag),               // I [7:0]
                   .req_be_i(req_be),                 // I [7:0]
                   .req_addr_i(req_addr),             // I [10:0]
                    
                   // Read Port

                   .rd_addr_o(rd_addr[6:0]),         // I [10:0]
                   .rd_be_o(rd_be),                  // I [3:0]
                   .rd_data_i(rd_data),              // O [31:0]

                   // Initiator Controls

                   .init_rst_i(init_rst),            // I

                   .mrd_start_i(mrd_start_o),        // I
                   .mrd_int_dis_i(mrd_int_dis_o),    // I
                   .mrd_done_i(mrd_done),            // I
                   .mrd_addr_i(mrd_addr),            // I [31:0]
                   .mrd_len_i(mrd_len),              // I [31:0]
                   .mrd_count_i(mrd_count),          // I [31:0]
                   .mrd_tlp_tc_i(mrd_tlp_tc_o),      // I [2:0]
                   .mrd_64b_en_i(mrd_64b_en_o),      // I
                   .mrd_phant_func_dis1_i(1'b1 /*mrd_phant_func_dis1*/), // I
                   .mrd_up_addr_i(mrd_up_addr_o),    // I [7:0]
                   .mrd_lbe_i(4'hF),        
                   .mrd_fbe_i(4'hF),
                   .mrd_tag_i(8'h0),
                   .cur_mrd_count_o(cur_mrd_count),  // O[15:0]
                   .mrd_relaxed_order_i(mrd_relaxed_order), // I
                   .mrd_nosnoop_i(mrd_nosnoop),             // I
                   .mrd_wrr_cnt_i(mrd_wrr_cnt),      // I [7:0]

                   .mwr_start_i(mwr_start),          // I
                   .mwr_int_dis_i(mwr_int_dis_o),    // I
                   .mwr_done_o(mwr_done),            // O
                   .mwr_addr_i(mwr_addr),            // I [31:0]
                   .mwr_len_i(mwr_len),              // I [31:0]
                   .mwr_count_i(mwr_count),          // I [31:0]
                   .mwr_data_i(mwr_data),            // I [31:0] 
                   .mwr_tlp_tc_i(mwr_tlp_tc_o),      // I [2:0]
                   .mwr_64b_en_i(mwr_64b_en_o),      // I
                   .mwr_phant_func_dis1_i(1'b1 /*mwr_phant_func_dis1*/), // I
                   .mwr_up_addr_i(mwr_up_addr_o),    // I [7:0]
                   .mwr_lbe_i(4'hF),
                   .mwr_fbe_i(4'hF),
                   .mwr_tag_i(8'h0),
                   .mwr_relaxed_order_i(mwr_relaxed_order), // I
                   .mwr_nosnoop_i(mwr_nosnoop),             // I
                   .mwr_wrr_cnt_i(mwr_wrr_cnt),       // I [7:0]

                   .cfg_msi_enable_i(cfg_msi_enable),            // I
                   .cfg_interrupt_n_o(cfg_interrupt_n),          // O
                   .cfg_interrupt_assert_n_o(cfg_interrupt_assert_n), // O
                   .cfg_interrupt_rdy_n_i(cfg_interrupt_rdy_n),  // I
                   .cfg_interrupt_legacyclr(cfg_interrupt_legacyclr),  // I
                   .completer_id_i(cfg_completer_id),            // I [15:0]
                   .cfg_ext_tag_en_i(cfg_ext_tag_en),            // I
                   .cfg_bus_mstr_enable_i(cfg_bus_mstr_enable),  // I
                   .cfg_phant_func_en_i(cfg_phant_func_en),                  // I
                   .cfg_phant_func_supported_i(cfg_phant_func_supported)     // I [1:0]

                   );

    assign req_compl_o  = req_compl;
    assign compl_done_o = compl_done;


    //
    // Read Transmit Throttle Unit :
    // 

    BMD_RD_THROTTLE RD_THR (

                    .clk(clk),                           // I
                    .rst_n(rst_n),                       // I

                    .init_rst_i(init_rst),               // I

                    .mrd_start_i(mrd_start),             // I
                    .mrd_len_i(mrd_len),                 // I
                    .mrd_cur_rd_count_i(cur_mrd_count),  // I [15:0]    

                    .cpld_found_i(cpld_found),           // I [31:0]
                    .cpld_data_size_i(cpld_size),        // I [31:0]
                    .cpld_malformed_i(cpld_malformed),   // I
                    .cpld_data_err_i(cpld_data_err),     // I

                    .cpld_data_size_hwm(cpld_data_size_hwm), // O [31:0]
                    .cur_rd_count_hwm(cur_rd_count_hwm),     // O [15:0]

                    .cfg_rd_comp_bound_i(cfg_rd_comp_bound), // I
                    .rd_metering_i(1'b0),             // I

                    .mrd_start_o(mrd_start_o)                // O

                    );







endmodule // BMD_EP

