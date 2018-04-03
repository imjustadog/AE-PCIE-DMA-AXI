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
//-- Filename: BMD_64_TX_ENGINE.v
//--
//-- Description: 64 bit Local-Link Transmit Unit.
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

`define BMD_64_CPLD_FMT_TYPE   7'b10_01010
`define BMD_64_MWR_FMT_TYPE    7'b10_00000
`define BMD_64_MWR64_FMT_TYPE  7'b11_00000
`define BMD_64_MRD_FMT_TYPE    7'b00_00000
`define BMD_64_MRD64_FMT_TYPE  7'b01_00000

`define BMD_64_TX_RST_STATE    8'b00000001
`define BMD_64_TX_CPLD_QW1     8'b00000010
`define BMD_64_TX_CPLD_WIT     8'b00000100
`define BMD_64_TX_MWR_QW1      8'b00001000
`define BMD_64_TX_MWR64_QW1    8'b00010000
`define BMD_64_TX_MWR_QWN      8'b00100000
`define BMD_64_TX_MRD_QW1      8'b01000000
`define BMD_64_TX_MRD_QWN      8'b10000000

module BMD_TX_ENGINE (

                        clk,
                        rst_n,

                        trn_td,
                        trn_trem_n,
                        trn_tsof_n,
                        trn_teof_n,
                        trn_tsrc_rdy_n,
                        trn_tsrc_dsc_n,
                        trn_tdst_rdy_n,
                        trn_tdst_dsc_n,
                        trn_tbuf_av,

                        req_compl_i,    
                        compl_done_o,  

                        req_tc_i,     
                        req_td_i,    
                        req_ep_i,   
                        req_attr_i,
                        req_len_i,         
                        req_rid_i,        
                        req_tag_i,       
                        req_be_i,
                        req_addr_i,     

                        // BMD Read Access

                        rd_addr_o,   
                        rd_be_o,    
                        rd_data_i,


                        // Initiator Reset
          
                        init_rst_i,

                        // Write Initiator

                        mwr_start_i,
                        mwr_int_dis_i,
                        mwr_len_i,
                        mwr_tag_i,
                        mwr_lbe_i,
                        mwr_fbe_i,
                        mwr_addr_i,
                        mwr_data_i,
                        mwr_count_i,
                        mwr_done_o,
                        mwr_tlp_tc_i,
                        mwr_64b_en_i,
                        mwr_phant_func_dis1_i,
                        mwr_up_addr_i,
                        mwr_relaxed_order_i,
                        mwr_nosnoop_i,
                        mwr_wrr_cnt_i,

                        // Read Initiator

                        mrd_start_i,
                        mrd_int_dis_i,
                        mrd_len_i,
                        mrd_tag_i,
                        mrd_lbe_i,
                        mrd_fbe_i,
                        mrd_addr_i,
                        mrd_count_i,
                        mrd_done_i,
                        mrd_tlp_tc_i,
                        mrd_64b_en_i,
                        mrd_phant_func_dis1_i,
                        mrd_up_addr_i,
                        mrd_relaxed_order_i,
                        mrd_nosnoop_i,
                        mrd_wrr_cnt_i,

                        cur_mrd_count_o,

                        cfg_msi_enable_i,
                        cfg_interrupt_n_o,
                        cfg_interrupt_assert_n_o,
                        cfg_interrupt_rdy_n_i,
                        cfg_interrupt_legacyclr,

                        completer_id_i,
                        cfg_ext_tag_en_i,
                        cfg_bus_mstr_enable_i,
                        cfg_phant_func_en_i,
                        cfg_phant_func_supported_i


                        );

    input               clk;
    input               rst_n;
 
    output [63:0]       trn_td;
    output [7:0]        trn_trem_n;
    output              trn_tsof_n;
    output              trn_teof_n;
    output              trn_tsrc_rdy_n;
    output              trn_tsrc_dsc_n;
    input               trn_tdst_rdy_n;
    input               trn_tdst_dsc_n;
    input [5:0]         trn_tbuf_av;

    input               req_compl_i;
    output              compl_done_o;

    input [2:0]         req_tc_i;
    input               req_td_i;
    input               req_ep_i;
    input [1:0]         req_attr_i;
    input [9:0]         req_len_i;
    input [15:0]        req_rid_i;
    input [7:0]         req_tag_i;
    input [7:0]         req_be_i;
    input [10:0]        req_addr_i;
    
    output [6:0]        rd_addr_o;
    output [3:0]        rd_be_o;
    input  [31:0]       rd_data_i;

    input               init_rst_i;

    input               mwr_start_i;
    input               mwr_int_dis_i;
    input  [31:0]       mwr_len_i;
    input  [7:0]        mwr_tag_i;
    input  [3:0]        mwr_lbe_i;
    input  [3:0]        mwr_fbe_i;
    input  [31:0]       mwr_addr_i;
    input  [31:0]       mwr_data_i;
    input  [31:0]       mwr_count_i;
    output              mwr_done_o;
    input  [2:0]        mwr_tlp_tc_i;
    input               mwr_64b_en_i;
    input               mwr_phant_func_dis1_i;
    input  [7:0]        mwr_up_addr_i;
    input               mwr_relaxed_order_i;
    input               mwr_nosnoop_i;
    input  [7:0]        mwr_wrr_cnt_i;


    input               mrd_start_i;
    input               mrd_int_dis_i;
    input  [31:0]       mrd_len_i;
    input  [7:0]        mrd_tag_i;
    input  [3:0]        mrd_lbe_i;
    input  [3:0]        mrd_fbe_i;
    input  [31:0]       mrd_addr_i;
    input  [31:0]       mrd_count_i;
    input               mrd_done_i;
    input  [2:0]        mrd_tlp_tc_i;
    input               mrd_64b_en_i;
    input               mrd_phant_func_dis1_i;
    input  [7:0]        mrd_up_addr_i;
    input               mrd_relaxed_order_i;
    input               mrd_nosnoop_i;
    input  [7:0]        mrd_wrr_cnt_i;

    output [15:0]       cur_mrd_count_o;

    input               cfg_msi_enable_i;
    output              cfg_interrupt_n_o;
    output              cfg_interrupt_assert_n_o;
    input               cfg_interrupt_rdy_n_i;
    input               cfg_interrupt_legacyclr;

    input [15:0]        completer_id_i;
    input               cfg_ext_tag_en_i;
    input               cfg_bus_mstr_enable_i;

    input               cfg_phant_func_en_i;
    input [1:0]         cfg_phant_func_supported_i;


    // Local registers

    reg [63:0]          trn_td;
    reg [7:0]           trn_trem_n;
    reg                 trn_tsof_n;
    reg                 trn_teof_n;
    reg                 trn_tsrc_rdy_n;
    reg                 trn_tsrc_dsc_n;
 
    reg [11:0]          byte_count;
    reg [06:0]          lower_addr;

    reg                 req_compl_q;                 

    reg [7:0]           bmd_64_tx_state;

    reg                 compl_done_o;
    reg                 mwr_done_o;

    reg                 mrd_done;

    reg [15:0]          cur_wr_count;
    reg [15:0]          cur_rd_count;
   
    reg [9:0]           cur_mwr_dw_count;
  
    reg [12:0]          mwr_len_byte;
    reg [12:0]          mrd_len_byte;

    reg [31:0]          pmwr_addr;
    reg [31:0]          pmrd_addr;

    reg [31:0]          tmwr_addr;
    reg [31:0]          tmrd_addr;

    reg [15:0]          rmwr_count;
    reg [15:0]          rmrd_count;

    reg                 serv_mwr;
    reg                 serv_mrd;

    reg  [7:0]          tmwr_wrr_cnt;
    reg  [7:0]          tmrd_wrr_cnt;

    // Local wires
   
    wire [15:0]         cur_mrd_count_o = cur_rd_count;
    wire                cfg_bm_en = cfg_bus_mstr_enable_i;
    wire [31:0]         mwr_addr  = mwr_addr_i;
    wire [31:0]         mrd_addr  = mrd_addr_i;
    wire [31:0]         mwr_data_i_sw = {mwr_data_i[07:00],
                                         mwr_data_i[15:08],
                                         mwr_data_i[23:16],
                                         mwr_data_i[31:24]};

    wire  [2:0]         mwr_func_num = (!mwr_phant_func_dis1_i && cfg_phant_func_en_i) ? 
                                       ((cfg_phant_func_supported_i == 2'b00) ? 3'b000 : 
                                        (cfg_phant_func_supported_i == 2'b01) ? {cur_wr_count[8], 2'b00} : 
                                        (cfg_phant_func_supported_i == 2'b10) ? {cur_wr_count[9:8], 1'b0} : 
                                        (cfg_phant_func_supported_i == 2'b11) ? {cur_wr_count[10:8]} : 3'b000) : 3'b000;

    wire  [2:0]         mrd_func_num = (!mrd_phant_func_dis1_i && cfg_phant_func_en_i) ? 
                                       ((cfg_phant_func_supported_i == 2'b00) ? 3'b000 : 
                                        (cfg_phant_func_supported_i == 2'b01) ? {cur_rd_count[8], 2'b00} : 
                                        (cfg_phant_func_supported_i == 2'b10) ? {cur_rd_count[9:8], 1'b0} : 
                                        (cfg_phant_func_supported_i == 2'b11) ? {cur_rd_count[10:8]} : 3'b000) : 3'b000;

    /*
     * Present address and byte enable to memory module
     */

    assign rd_addr_o = req_addr_i[10:2];
    assign rd_be_o =   req_be_i[3:0];

    /*
     * Calculate byte count based on byte enable
     */

    always @ (rd_be_o) begin

      casex (rd_be_o[3:0])
      
        4'b1xx1 : byte_count = 12'h004;
        4'b01x1 : byte_count = 12'h003;
        4'b1x10 : byte_count = 12'h003;
        4'b0011 : byte_count = 12'h002;
        4'b0110 : byte_count = 12'h002;
        4'b1100 : byte_count = 12'h002;
        4'b0001 : byte_count = 12'h001;
        4'b0010 : byte_count = 12'h001;
        4'b0100 : byte_count = 12'h001;
        4'b1000 : byte_count = 12'h001;
        4'b0000 : byte_count = 12'h001;

      endcase

    end

    /*
     * Calculate lower address based on  byte enable
     */

    always @ (rd_be_o or req_addr_i) begin

      casex (rd_be_o[3:0])
      
        4'b0000 : lower_addr = {req_addr_i[4:0], 2'b00};
        4'bxxx1 : lower_addr = {req_addr_i[4:0], 2'b00};
        4'bxx10 : lower_addr = {req_addr_i[4:0], 2'b01};
        4'bx100 : lower_addr = {req_addr_i[4:0], 2'b10};
        4'b1000 : lower_addr = {req_addr_i[4:0], 2'b11};

      endcase

    end

    always @ ( posedge clk ) begin

        if (!rst_n ) begin

          req_compl_q <= 1'b0;

        end else begin 

          req_compl_q <= req_compl_i;

        end

    end

    /*
     *  Interrupt Controller
     */

    BMD_INTR_CTRL BMD_INTR_CTRL  (

      .clk(clk),                                     // I
      .rst_n(rst_n),                                 // I

      .init_rst_i(init_rst_i),                       // I

      .mrd_done_i(mrd_done_i & !mrd_int_dis_i),      // I
      .mwr_done_i(mwr_done_o & !mwr_int_dis_i),      // I

      .msi_on(cfg_msi_enable_i),                     // I

      .cfg_interrupt_rdy_n_i(cfg_interrupt_rdy_n_i), // I
      .cfg_interrupt_assert_n_o(cfg_interrupt_assert_n_o), // O
      .cfg_interrupt_n_o(cfg_interrupt_n_o),        // O
      .cfg_interrupt_legacyclr(cfg_interrupt_legacyclr) // I

    );


    /*
     *  Tx State Machine 
     */

    always @ ( posedge clk ) begin

        if (!rst_n ) begin

          trn_tsof_n        <= 1'b1;
          trn_teof_n        <= 1'b1;
          trn_tsrc_rdy_n    <= 1'b1;
          trn_tsrc_dsc_n    <= 1'b1;
          trn_td            <= 64'b0;
          trn_trem_n        <= 8'b0;
 
          cur_mwr_dw_count  <= 10'b0;

          compl_done_o      <= 1'b0;
          mwr_done_o        <= 1'b0;

          mrd_done          <= 1'b0;

          cur_wr_count      <= 16'b0;
          cur_rd_count      <= 16'b1;

          mwr_len_byte      <= 13'b0;
          mrd_len_byte      <= 13'b0;

          pmwr_addr         <= 32'b0;
          pmrd_addr         <= 32'b0;

          rmwr_count        <= 16'b0;
          rmrd_count        <= 16'b0;

          serv_mwr          <= 1'b1;
          serv_mrd          <= 1'b1;

          tmwr_wrr_cnt      <= 8'h00;
          tmrd_wrr_cnt      <= 8'h00;

          bmd_64_tx_state   <= `BMD_64_TX_RST_STATE;

        end else begin 

         
          if (init_rst_i ) begin

            trn_tsof_n        <= 1'b1;
            trn_teof_n        <= 1'b1;
            trn_tsrc_rdy_n    <= 1'b1;
            trn_tsrc_dsc_n    <= 1'b1;
            trn_td            <= 64'b0;
            trn_trem_n        <= 8'b0;
   
            cur_mwr_dw_count  <= 10'b0;
  
            compl_done_o      <= 1'b0;
            mwr_done_o        <= 1'b0;

            mrd_done          <= 1'b0;
  
            cur_wr_count      <= 16'b0;
            cur_rd_count      <= 16'b1;

            mwr_len_byte      <= 13'b0;
            mrd_len_byte      <= 13'b0;

            pmwr_addr         <= 32'b0;
            pmrd_addr         <= 32'b0;

            rmwr_count        <= 16'b0;
            rmrd_count        <= 16'b0;

            serv_mwr          <= 1'b1;
            serv_mrd          <= 1'b1;

            tmwr_wrr_cnt      <= 8'h00;
            tmrd_wrr_cnt      <= 8'h00;

            bmd_64_tx_state   <= `BMD_64_TX_RST_STATE;

          end

          mwr_len_byte        <= 4 * mwr_len_i[10:0];
          mrd_len_byte        <= 4 * mrd_len_i[10:0];
          rmwr_count          <= mwr_count_i[15:0];
          rmrd_count          <= mrd_count_i[15:0];

          case ( bmd_64_tx_state ) 

            `BMD_64_TX_RST_STATE : begin

              compl_done_o       <= 1'b0;

              // PIO read completions always get highest priority

              if (req_compl_q && 
                  !compl_done_o &&
                  !trn_tdst_rdy_n &&
                  trn_tdst_dsc_n) begin

                trn_tsof_n       <= 1'b0;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { {1'b0}, 
                                      `BMD_64_CPLD_FMT_TYPE, 
                                      {1'b0}, 
                                      req_tc_i, 
                                      {4'b0}, 
                                      req_td_i, 
                                      req_ep_i, 
                                      req_attr_i, 
                                      {2'b0}, 
                                      req_len_i,
                                      completer_id_i, 
                                      {3'b0}, 
                                      {1'b0}, 
                                      byte_count };
                trn_trem_n        <= 8'b0;

                bmd_64_tx_state   <= `BMD_64_TX_CPLD_QW1;

              end else if (mwr_start_i && 
                           !mwr_done_o &&
                           serv_mwr &&
                           !trn_tdst_rdy_n &&
                           trn_tdst_dsc_n && 
                           cfg_bm_en) begin
             
                trn_tsof_n       <= 1'b0;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { {1'b0}, 
                                      {mwr_64b_en_i ? 
                                       `BMD_64_MWR64_FMT_TYPE :  
                                       `BMD_64_MWR_FMT_TYPE}, 
                                      {1'b0}, 
                                      mwr_tlp_tc_i, 
                                      {4'b0}, 
                                      1'b0, 
                                      1'b0, 
                                      {mwr_relaxed_order_i, mwr_nosnoop_i}, // 2'b00, 
                                      {2'b0}, 
                                      mwr_len_i[9:0],
                                      {completer_id_i[15:3], mwr_func_num}, 
                                      cfg_ext_tag_en_i ? cur_wr_count[7:0] : {3'b0, cur_wr_count[4:0]},
                                      (mwr_len_i[9:0] == 1'b1) ? 4'b0 : mwr_lbe_i,
                                      mwr_fbe_i};
                trn_trem_n        <= 8'b0;
                cur_mwr_dw_count  <= mwr_len_i[9:0];
                
                // Weighted Round Robin
                if (mwr_start_i && !mwr_done_o && (tmwr_wrr_cnt != mwr_wrr_cnt_i)) begin
                  serv_mwr        <= 1'b1;
                  serv_mrd        <= 1'b0;
                  tmwr_wrr_cnt    <= tmwr_wrr_cnt + 1'b1;
                end else if (mrd_start_i && !mrd_done) begin
                  serv_mwr        <= 1'b0;
                  serv_mrd        <= 1'b1;
                  tmwr_wrr_cnt    <= 8'h00;
                end else begin
                  serv_mwr        <= 1'b0;
                  serv_mrd        <= 1'b0;
                  tmwr_wrr_cnt    <= 8'h00;
                end
                
                if (mwr_64b_en_i)
				  bmd_64_tx_state   <= `BMD_64_TX_MWR64_QW1;
                else
				  bmd_64_tx_state   <= `BMD_64_TX_MWR_QW1;
                

              end else if (mrd_start_i && 
                           !mrd_done &&
                           serv_mrd &&
                           !trn_tdst_rdy_n &&
                           trn_tdst_dsc_n && 
                           cfg_bm_en) begin
             
                trn_tsof_n       <= 1'b0;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { {1'b0}, 
                                      {mrd_64b_en_i ? 
                                       `BMD_64_MRD64_FMT_TYPE : 
                                       `BMD_64_MRD_FMT_TYPE}, 
                                      {1'b0}, 
                                      mrd_tlp_tc_i, 
                                      {4'b0}, 
                                      1'b0, 
                                      1'b0, 
                                      {mrd_relaxed_order_i, mrd_nosnoop_i}, // 2'b00, 
                                      {2'b0}, 
                                      mrd_len_i[9:0],
                                      {completer_id_i[15:3], mrd_func_num}, 
                                      cfg_ext_tag_en_i ? cur_rd_count[7:0] : {3'b0, cur_rd_count[4:0]},
                                      (mrd_len_i[9:0] == 1'b1) ? 4'b0 : mrd_lbe_i,
                                      mrd_fbe_i};
                trn_trem_n        <= 8'b0;

                // Weighted Round Robin
                if (mrd_start_i && !mrd_done && (tmrd_wrr_cnt != mrd_wrr_cnt_i)) begin
                  serv_mrd        <= 1'b1;
                  serv_mwr        <= 1'b0;
                  tmrd_wrr_cnt    <= tmrd_wrr_cnt + 1'b1;
                end else if (mwr_start_i && !mwr_done_o) begin
                  serv_mrd        <= 1'b0;
                  serv_mwr        <= 1'b1;
                  tmrd_wrr_cnt    <= 8'h00;
                end else begin
                  serv_mrd        <= 1'b0;
                  serv_mwr        <= 1'b0;
                  tmrd_wrr_cnt    <= 8'h00;
                end

                bmd_64_tx_state   <= `BMD_64_TX_MRD_QW1;
                
              end else  begin

                if(!trn_tdst_rdy_n) begin

                  trn_tsof_n        <= 1'b1;
                  trn_teof_n        <= 1'b1;
                  trn_tsrc_rdy_n    <= 1'b1;
                  trn_tsrc_dsc_n    <= 1'b1;
                  trn_td            <= 64'b0;
                  trn_trem_n        <= 8'b0;

                  serv_mwr          <= ~serv_mwr;
                  serv_mrd          <= ~serv_mrd;

                end
 
                bmd_64_tx_state   <= `BMD_64_TX_RST_STATE;

              end

            end

            `BMD_64_TX_CPLD_QW1 : begin

              if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin

                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b0;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { req_rid_i, 
                                      req_tag_i, 
                                      {1'b0}, 
                                      lower_addr,
                                      rd_data_i };
                trn_trem_n       <= 8'h00;
                compl_done_o     <= 1'b1;

                bmd_64_tx_state  <= `BMD_64_TX_CPLD_WIT;

              end else if (!trn_tdst_dsc_n) begin

                trn_tsrc_dsc_n   <= 1'b0;

                bmd_64_tx_state  <= `BMD_64_TX_CPLD_WIT;

              end else
                bmd_64_tx_state  <= `BMD_64_TX_CPLD_QW1;

            end

            `BMD_64_TX_CPLD_WIT : begin

              if ( (!trn_tdst_rdy_n) || (!trn_tdst_dsc_n) ) begin

                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b1;
                trn_tsrc_dsc_n   <= 1'b1;

                bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;

              end else
                bmd_64_tx_state  <= `BMD_64_TX_CPLD_WIT;

            end

            `BMD_64_TX_MWR_QW1 : begin

              if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin

                trn_tsof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                if (cur_wr_count == 0)
                  tmwr_addr       = mwr_addr;
                else 
                  tmwr_addr       = pmwr_addr + mwr_len_byte;
                trn_td           <= {{tmwr_addr[31:2], 2'b00}, mwr_data_i_sw};
                pmwr_addr        <= tmwr_addr;

                  cur_wr_count <= cur_wr_count + 1'b1;

                if (cur_mwr_dw_count == 1'h1) begin

                  trn_teof_n       <= 1'b0;
                  cur_mwr_dw_count <= cur_mwr_dw_count - 1'h1; 
                  trn_trem_n       <= 8'h00;

                  if (cur_wr_count == (rmwr_count - 1'b1))  begin

                    cur_wr_count <= 0; 
                    mwr_done_o   <= 1'b1;

                  end

                  bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;

                end else begin

                  cur_mwr_dw_count <= cur_mwr_dw_count - 1'h1; 
                  trn_trem_n       <= 8'hFF;
                  bmd_64_tx_state  <= `BMD_64_TX_MWR_QWN;

                end

              end else if (!trn_tdst_dsc_n) begin

                bmd_64_tx_state    <= `BMD_64_TX_RST_STATE;
                trn_tsrc_dsc_n     <= 1'b0;

              end else
                bmd_64_tx_state    <= `BMD_64_TX_MWR_QW1;

            end

            `BMD_64_TX_MWR64_QW1 : begin

              if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin

                trn_tsof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                if (cur_wr_count == 0)
                  tmwr_addr       = mwr_addr;
                else 
                  tmwr_addr       = {pmwr_addr[31:24], pmwr_addr[23:0] + mwr_len_byte};
                trn_td           <= {{24'b0},mwr_up_addr_i,tmwr_addr[31:2],{2'b0}};
                pmwr_addr        <= tmwr_addr;

                cur_wr_count <= cur_wr_count + 1'b1;

                bmd_64_tx_state  <= `BMD_64_TX_MWR_QWN;

              end else if (!trn_tdst_dsc_n) begin

                bmd_64_tx_state    <= `BMD_64_TX_RST_STATE;
                trn_tsrc_dsc_n     <= 1'b0;

              end else
                bmd_64_tx_state    <= `BMD_64_TX_MWR64_QW1;

            end

            `BMD_64_TX_MWR_QWN : begin

              if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin

                trn_tsrc_rdy_n   <= 1'b0;

                if (cur_mwr_dw_count == 1'h1) begin

                  trn_td           <= {mwr_data_i_sw, 32'hd0_da_d0_da};
                  trn_trem_n       <= 8'h0F;
                  trn_teof_n       <= 1'b0;
                  cur_mwr_dw_count <= cur_mwr_dw_count - 1'h1; 
                  bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;

                  if (cur_wr_count == rmwr_count)  begin

                    cur_wr_count <= 0; 
                    mwr_done_o   <= 1'b1;

                  end 

                end else if (cur_mwr_dw_count == 2'h2) begin

                  trn_td           <= {mwr_data_i_sw, mwr_data_i_sw};
                  trn_trem_n       <= 8'h00;
                  trn_teof_n       <= 1'b0;
                  cur_mwr_dw_count <= cur_mwr_dw_count - 2'h2; 
                  bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;

                  if (cur_wr_count == rmwr_count)  begin

                    cur_wr_count <= 0; 
                    mwr_done_o   <= 1'b1;

                  end

                end else begin

                  trn_td           <= {mwr_data_i_sw, mwr_data_i_sw};
                  trn_trem_n       <= 8'hFF;
                  cur_mwr_dw_count <= cur_mwr_dw_count - 2'h2; 
                  bmd_64_tx_state  <= `BMD_64_TX_MWR_QWN;

                end

              end else if (!trn_tdst_dsc_n) begin

                bmd_64_tx_state    <= `BMD_64_TX_RST_STATE;
                trn_tsrc_dsc_n     <= 1'b0;

              end else
                bmd_64_tx_state    <= `BMD_64_TX_MWR_QWN;

            end

            `BMD_64_TX_MRD_QW1 : begin

              if ((!trn_tdst_rdy_n) && (trn_tdst_dsc_n)) begin

                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b0;
                trn_tsrc_rdy_n   <= 1'b0;
                if (cur_rd_count == 1)
                  tmrd_addr       = mrd_addr;
                else 
                  tmrd_addr       = {pmrd_addr[31:24], pmrd_addr[23:0] + mrd_len_byte};
                if (mrd_64b_en_i) begin
                  trn_td         <= {{24'b0},{mrd_up_addr_i},{tmrd_addr[31:2],2'b0}};
                  trn_trem_n     <= 8'h00;
                end else begin
                  trn_td         <= {{tmrd_addr[31:2], 2'b00}, 32'hd0_da_d0_da};
                  trn_trem_n     <= 8'h0F;
                end
                pmrd_addr        <= tmrd_addr;

                if (cur_rd_count == rmrd_count) begin

                  cur_rd_count   <= 0; 
                  mrd_done       <= 1'b1;

                end else 
                  cur_rd_count <= cur_rd_count + 1'b1;

                bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;

              end else if (!trn_tdst_dsc_n) begin

                bmd_64_tx_state  <= `BMD_64_TX_RST_STATE;
                trn_tsrc_dsc_n   <= 1'b0;

              end else
                bmd_64_tx_state  <= `BMD_64_TX_MRD_QW1;

            end

          endcase

        end

    end

endmodule // BMD_64_TX_ENGINE

