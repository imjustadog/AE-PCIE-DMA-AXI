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
//-- Filename: BMD_EP_MEM.v
//--
//-- Description: Endpoint control and status registers
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

module BMD_EP_MEM# (
 parameter INTERFACE_TYPE = 4'b0010,
   parameter FPGA_FAMILY = 8'h14


)
(
                      clk,                   // I
                      rst_n,                 // I

                      cfg_cap_max_lnk_width, // I [5:0]
                      cfg_neg_max_lnk_width, // I [5:0]

                      cfg_cap_max_payload_size,  // I [2:0]
                      cfg_prg_max_payload_size,  // I [2:0]
                      cfg_max_rd_req_size,   // I [2:0]

                      a_i,                   // I [8:0]
                      wr_en_i,               // I 
                      rd_d_o,                // O [31:0]
                      wr_d_i,                // I [31:0]

                      init_rst_o,            // O

                      mrd_start_o,           // O
                      mrd_int_dis_o,         // O
                      mrd_done_o,            // O
                      mrd_addr_o,            // O [31:0]
                      mrd_len_o,             // O [31:0]
                      mrd_tlp_tc_o,          // O [2:0]
                      mrd_64b_en_o,          // O
                      mrd_phant_func_dis1_o,  // O
                      mrd_up_addr_o,         // O [7:0]
                      mrd_count_o,           // O [31:0]
                      mrd_relaxed_order_o,   // O
                      mrd_nosnoop_o,         // O
                      mrd_wrr_cnt_o,         // O [7:0]

                      mwr_start_o,           // O
                      mwr_int_dis_o,         // O 
                      mwr_done_i,            // I
                      mwr_addr_o,            // O [31:0]
                      mwr_len_o,             // O [31:0]
                      mwr_tlp_tc_o,          // O [2:0]
                      mwr_64b_en_o,          // O
                      mwr_phant_func_dis1_o,  // O
                      mwr_up_addr_o,         // O [7:0]
                      mwr_count_o,           // O [31:0]
                      mwr_data_o,            // O [31:0]
                      mwr_relaxed_order_o,   // O
                      mwr_nosnoop_o,         // O
                      mwr_wrr_cnt_o,         // O [7:0]

                      cpl_ur_found_i,        // I [7:0] 
                      cpl_ur_tag_i,          // I [7:0]

                      cpld_data_o,           // O [31:0]
                      cpld_found_i,          // I [31:0]
                      cpld_data_size_i,      // I [31:0]
                      cpld_malformed_i,      // I
                      cpld_data_err_i,       // I
                      cpl_streaming_o,       // O
                      rd_metering_o,         // O
                      cfg_interrupt_di,      // O
                      cfg_interrupt_do,      // I
                      cfg_interrupt_mmenable,   // I
                      cfg_interrupt_msienable,  // I
                      cfg_interrupt_legacyclr,  // O
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
                      pl_width_change_err_i,
                      pl_speed_change_err_i,
                      clr_pl_width_change_err,
                      clr_pl_speed_change_err,
                      clear_directed_speed_change_i,

`endif
                      trn_rnp_ok_n_o,
                      trn_tstr_n_o
                      );

    input             clk;
    input             rst_n;

    input [5:0]       cfg_cap_max_lnk_width;
    input [5:0]       cfg_neg_max_lnk_width;

    input [2:0]       cfg_cap_max_payload_size;
    input [2:0]       cfg_prg_max_payload_size;
    input [2:0]       cfg_max_rd_req_size;

    input [6:0]       a_i;
    input             wr_en_i;
    output [31:0]     rd_d_o;
    input  [31:0]     wr_d_i;

    // CSR bits

    output            init_rst_o;

    output            mrd_start_o;
    output            mrd_int_dis_o;
    output            mrd_done_o;
    output [31:0]     mrd_addr_o;
    output [31:0]     mrd_len_o;
    output [2:0]      mrd_tlp_tc_o;
    output            mrd_64b_en_o;
    output            mrd_phant_func_dis1_o;
    output [7:0]      mrd_up_addr_o;
    output [31:0]     mrd_count_o;
    output            mrd_relaxed_order_o;
    output            mrd_nosnoop_o;
    output [7:0]      mrd_wrr_cnt_o;

    output            mwr_start_o;
    output            mwr_int_dis_o;
    input             mwr_done_i;
    output [31:0]     mwr_addr_o;
    output [31:0]     mwr_len_o;
    output [2:0]      mwr_tlp_tc_o;
    output            mwr_64b_en_o;
    output            mwr_phant_func_dis1_o;
    output [7:0]      mwr_up_addr_o;
    output [31:0]     mwr_count_o;
    output [31:0]     mwr_data_o;
    output            mwr_relaxed_order_o;
    output            mwr_nosnoop_o;
    output [7:0]      mwr_wrr_cnt_o;

    input  [7:0]      cpl_ur_found_i;
    input  [7:0]      cpl_ur_tag_i;

    output [31:0]     cpld_data_o;
    input  [31:0]     cpld_found_i;
    input  [31:0]     cpld_data_size_i;
    input             cpld_malformed_i;
    input             cpld_data_err_i;
    output            cpl_streaming_o;
    output            rd_metering_o;

    output            trn_rnp_ok_n_o;
    output            trn_tstr_n_o;
    output [7:0]      cfg_interrupt_di;
    input  [7:0]      cfg_interrupt_do;
    input  [2:0]      cfg_interrupt_mmenable;
    input             cfg_interrupt_msienable;
    output            cfg_interrupt_legacyclr;

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

    input             pl_width_change_err_i;
    input             pl_speed_change_err_i;
    output            clr_pl_width_change_err;
    output            clr_pl_speed_change_err;
    input             clear_directed_speed_change_i;

`endif


    // Local Regs

    reg [31:0]        rd_d_o /* synthesis syn_direct_enable = 0 */; 

    reg               init_rst_o;

    reg               mrd_start_o;
    reg               mrd_int_dis_o;
    reg [31:0]        mrd_addr_o;
    reg [31:0]        mrd_len_o;
    reg [31:0]        mrd_count_o;
    reg [2:0]         mrd_tlp_tc_o;
    reg               mrd_64b_en_o;
    reg               mrd_phant_func_dis1_o;
    reg [7:0]         mrd_up_addr_o;
    reg               mrd_relaxed_order_o;
    reg               mrd_nosnoop_o;
    reg [7:0]         mrd_wrr_cnt_o;

    reg               mwr_start_o;
    reg               mwr_int_dis_o;
    reg [31:0]        mwr_addr_o;
    reg [31:0]        mwr_len_o;
    reg [31:0]        mwr_count_o;
    reg [31:0]        mwr_data_o;
    reg [2:0]         mwr_tlp_tc_o;
    reg               mwr_64b_en_o;
    reg               mwr_phant_func_dis1_o;
    reg [7:0]         mwr_up_addr_o;
    reg               mwr_relaxed_order_o;
    reg               mwr_nosnoop_o;
    reg [7:0]         mwr_wrr_cnt_o;

    reg [31:0]        mrd_perf;
    reg [31:0]        mwr_perf;
 
    reg [31:0]        mrd_perf_post;
    reg [31:0]        mwr_perf_post;
    
   
    reg               mrd_done_o;

    reg [31:0]        cpld_data_o;
    reg [20:0]        expect_cpld_data_size;  // 2 GB max
    reg [20:0]        cpld_data_size;         // 2 GB max
    reg               cpld_done;

    reg               cpl_streaming_o;
    reg               rd_metering_o;
    reg               trn_rnp_ok_n_o;
    reg               trn_tstr_n_o;

    reg [7:0]         INTDI;
    reg               LEGACYCLR;
   
`ifdef PCIE2_0

    reg [1:0]         pl_directed_link_change;
    reg [1:0]         pl_directed_link_width;
    wire              pl_directed_link_speed;
    reg [1:0]         pl_directed_link_speed_binary;
    reg               pl_directed_link_auton;
    reg               pl_upstream_preemph_src;
    reg               pl_width_change_err;
    reg               pl_speed_change_err;
    reg               clr_pl_width_change_err;
    reg               clr_pl_speed_change_err;
    wire [1:0]        pl_sel_link_rate_binary;

`endif  
   
    wire [7:0]        fpga_family;
    wire [3:0]        interface_type;
    wire [7:0]        version_number;


    assign version_number = 8'h16;
    assign interface_type = INTERFACE_TYPE;
    assign fpga_family = FPGA_FAMILY;

/*`ifdef BMD_64
    assign interface_type = 4'b0010;
`else // BMD_32
    assign interface_type = 4'b0001;
`endif // BMD_64

`ifdef VIRTEX2P 
    assign fpga_family = 8'h11;
`endif // VIRTEX2P 

`ifdef VIRTEX4FX
    assign fpga_family = 8'h12;
`endif // VIRTEX4FX

`ifdef PCIEBLK
    assign fpga_family = 8'h13;
`endif // PCIEBLK

`ifdef SPARTAN3
    assign fpga_family = 8'h18;
`endif // SPARTAN3

`ifdef SPARTAN3E
    assign fpga_family = 8'h28;
`endif // SPARTAN3E

`ifdef SPARTAN3A
    assign fpga_family = 8'h38;
`endif // SPARTAN3A

*/
assign cfg_interrupt_di[7:0] = INTDI[7:0];
assign cfg_interrupt_legacyclr = LEGACYCLR;
//assign cfg_interrupt_di = 8'haa;


`ifdef PCIE2_0

   assign pl_sel_link_rate_binary = (pl_sel_link_rate == 0) ? 2'b01 : 2'b10;
   assign pl_directed_link_speed = (pl_directed_link_speed_binary == 2'b01) ?
                                                0 : 1;
`endif



    always @(posedge clk ) begin
    
        if ( !rst_n ) begin

          init_rst_o  <= 1'b0;

          mrd_start_o <= 1'b0;
          mrd_int_dis_o <= 1'b0;
          mrd_addr_o  <= 32'b0;
          mrd_len_o   <= 32'b0;
          mrd_count_o <= 32'b0;
          mrd_tlp_tc_o <= 3'b0;
          mrd_64b_en_o <= 1'b0;
          mrd_up_addr_o <= 8'b0;
          mrd_relaxed_order_o <= 1'b0;
          mrd_nosnoop_o <= 1'b0;
          mrd_phant_func_dis1_o <= 1'b0;

          mwr_phant_func_dis1_o <= 1'b0;
          mwr_start_o <= 1'b0;
          mwr_int_dis_o <= 1'b0;
          mwr_addr_o  <= 32'b0;
          mwr_len_o   <= 32'b0;
          mwr_count_o <= 32'b0;
          mwr_data_o  <= 32'b0;
          mwr_tlp_tc_o <= 3'b0;
          mwr_64b_en_o <= 1'b0;
          mwr_up_addr_o <= 8'b0;
          mwr_relaxed_order_o <= 1'b0;
          mwr_nosnoop_o <= 1'b0;

          cpld_data_o <= 32'b0;
          cpl_streaming_o <= 1'b1;
          rd_metering_o <= 1'b0;
          trn_rnp_ok_n_o <= 1'b0;
          trn_tstr_n_o <= 1'b0;
          mwr_wrr_cnt_o <= 8'h08;
          mrd_wrr_cnt_o <= 8'h08;

`ifdef PCIE2_0

          clr_pl_width_change_err <= 1'b0;
          clr_pl_speed_change_err <= 1'b0;
          pl_directed_link_change <= 2'h0;
          pl_directed_link_width  <= 2'h0;
          pl_directed_link_speed_binary  <= 2'b0; 
          pl_directed_link_auton  <= 1'b0;
          pl_upstream_preemph_src <= 1'b0;
          pl_width_change_err     <= 0;
          pl_speed_change_err     <= 0;

`endif          
          INTDI   <= 8'h00;
          LEGACYCLR  <=  1'b0;     

        end else begin

`ifdef PCIE2_0

         if (a_i[6:0] != 7'b010011)   // Reg#19
         begin
            pl_width_change_err <= pl_width_change_err_i;
            pl_speed_change_err <= pl_speed_change_err_i;
            pl_directed_link_change <=
                        clear_directed_speed_change_i ? 0 :    // 1
                        pl_directed_link_change;               // 0
         end

`endif

          case (a_i[6:0])
        
            // 00-03H : Reg # 0 
            // Byte0[0]: Initiator Reset (RW) 0= no reset 1=reset.
            // Byte2[19:16]: Data Path Width
            // Byte3[31:24]: FPGA Family
            7'b0000000: begin
          
              if (wr_en_i)
                init_rst_o  <= wr_d_i[0];
        
              rd_d_o <= {fpga_family, {4'b0}, interface_type, version_number, {7'b0}, init_rst_o};
              
              if (init_rst_o) begin
               
                mwr_start_o <= 1'b0;
                mrd_start_o <= 1'b0;

              end
             
            end

            // 04-07H :  Reg # 1
            // Byte0[0]: Memory Write Start (RW) 0=no start, 1=start
            // Byte0[7]: Memory Write Inter Disable (RW) 1=disable
            // Byte1[0]: Memory Write Done  (RO) 0=not done, 1=done
            // Byte2[0]: Memory Read Start (RW) 0=no start, 1=start
            // Byte2[7]: Memory Read Inter Disable (RW) 1=disable
            // Byte3[0]: Memory Read Done  (RO) 0=not done, 1=done
            7'b0000001: begin

              if (wr_en_i) begin
                mwr_start_o  <= wr_d_i[0];
                mwr_relaxed_order_o <=  wr_d_i[5];
                mwr_nosnoop_o <= wr_d_i[6];
                mwr_int_dis_o <= wr_d_i[7];
                mrd_start_o  <= wr_d_i[16];
                mrd_relaxed_order_o <=  wr_d_i[21];
                mrd_nosnoop_o <= wr_d_i[22];
                mrd_int_dis_o <= wr_d_i[23];
              end 

              rd_d_o <= {cpld_data_err_i, 6'b0, mrd_done_o,
                         mrd_int_dis_o, 4'b0, mrd_nosnoop_o, mrd_relaxed_order_o, mrd_start_o, 
                         7'b0, mwr_done_i,
                         mwr_int_dis_o, 4'b0, mwr_nosnoop_o, mwr_relaxed_order_o, mwr_start_o};

            end

            // 08-0BH : Reg # 2
            // Memory Write DMA Address (RW)
            7'b0000010: begin

              if (wr_en_i)
                mwr_addr_o  <= wr_d_i;
              
              rd_d_o <= mwr_addr_o;

            end

            // 0C-0FH : Reg # 3
            // Memory Write length in DWORDs (RW)
            7'b0000011: begin

              if (wr_en_i) begin
                mwr_len_o  <= wr_d_i[15:0];
                mwr_tlp_tc_o  <= wr_d_i[18:16];
                mwr_64b_en_o <= wr_d_i[19];
                mwr_phant_func_dis1_o <= wr_d_i[20];
                mwr_up_addr_o <= wr_d_i[31:24];
              end

              rd_d_o <= {mwr_up_addr_o, 
                         3'b0, mwr_phant_func_dis1_o, mwr_64b_en_o, mwr_tlp_tc_o, 
                         mwr_len_o[15:0]};

            end

            // 10-13H : Reg # 4
            // Memory Write Packet Count (RW)
            7'b0000100: begin

              if (wr_en_i)
                mwr_count_o  <= wr_d_i;
              
              rd_d_o <= mwr_count_o;

            end

            // 14-17H : Reg # 5
            // Memory Write Packet DWORD Data (RW)
            7'b000101: begin

              if (wr_en_i)
                mwr_data_o  <= wr_d_i;
              
              rd_d_o <= mwr_data_o;

            end

            // 18-1BH : Reg # 6
            // Completion Packet DWORD expected Data (RW)
            7'b000110: begin

              if (wr_en_i)
                cpld_data_o  <= wr_d_i;

              rd_d_o <= cpld_data_o;

            end

            // 1C-1FH : Reg # 7
            // Read DMA Address (RW)
            7'b000111: begin

              if (wr_en_i)
                mrd_addr_o  <= wr_d_i;
              
              rd_d_o <= mrd_addr_o;

            end

            // 20-23H : Reg # 8
            // Read length in DWORDs (RW)
            7'b001000: begin

              if (wr_en_i) begin
                mrd_len_o  <= wr_d_i[15:0];
                mrd_tlp_tc_o  <= wr_d_i[18:16];
                mrd_64b_en_o <= wr_d_i[19];
                mrd_phant_func_dis1_o <= wr_d_i[20];
                mrd_up_addr_o <= wr_d_i[31:24];
              end
              
              rd_d_o <= {mrd_up_addr_o, 
                         3'b0, mrd_phant_func_dis1_o, mrd_64b_en_o, mrd_tlp_tc_o, 
                         mrd_len_o[15:0]};

            end

            // 24-27H : Reg # 9
            // Read Packet Count (RW)
            7'b001001: begin

              if (wr_en_i)
                mrd_count_o  <= wr_d_i;
              
              rd_d_o <= mrd_count_o;

            end

            // 28-2BH : Reg # 10 
            // Memory Write Performance (RO)
            7'b001010: begin

              rd_d_o <= mwr_perf_post;

            end

            // 2C-2FH  : Reg # 11
            // Memory Read  Performance (RO)
            7'b001011: begin

              rd_d_o <= mrd_perf_post;

            end

            // 30-33H  : Reg # 12
            // Memory Read Completion Status (RO)
            7'b001100: begin

              rd_d_o <= {{15'b0}, cpld_malformed_i, cpl_ur_tag_i, cpl_ur_found_i};

            end

            // 34-37H  : Reg # 13
            // Memory Read Completion with Data Detected (RO)
            7'b001101: begin

              rd_d_o <= {cpld_found_i};

            end

            // 38-3BH  : Reg # 14
            // Memory Read Completion with Data Size (RO)
            7'b001110: begin

              rd_d_o <= {cpld_data_size_i};

            end

            // 3C-3FH : Reg # 15
            // Link Width (RO)
            7'b001111: begin

              rd_d_o <= {16'b0, 
                         2'b0, cfg_neg_max_lnk_width, 
                         2'b0, cfg_cap_max_lnk_width};

            end

            // 40-43H : Reg # 16
            // Link Payload (RO)
            7'b010000: begin

              rd_d_o <= {8'b0,
                         5'b0, cfg_max_rd_req_size, 
                         5'b0, cfg_prg_max_payload_size, 
                         5'b0, cfg_cap_max_payload_size};

            end

            // 44-47H : Reg # 17
            // WRR MWr
            // WRR MRd
            // Rx NP TLP Control
            // Completion Streaming Control (RW)
            // Read Metering Control (RW)

            7'b010001: begin

              if (wr_en_i) begin
                cpl_streaming_o <= wr_d_i[0];
                rd_metering_o <= wr_d_i[1];
                trn_rnp_ok_n_o <= wr_d_i[8];
                trn_tstr_n_o <= wr_d_i[9];
                mwr_wrr_cnt_o <= wr_d_i[23:16];
                mrd_wrr_cnt_o <= wr_d_i[31:24];
              end
        
              rd_d_o <= {mrd_wrr_cnt_o, 
                         mwr_wrr_cnt_o, 
                         6'b0, trn_tstr_n_o, trn_rnp_ok_n_o, 
                         6'b0, rd_metering_o, cpl_streaming_o};

            end


            // 48-4BH : Reg # 18
            // INTDI (RW)
            // INTDO
            // MMEN
            // MSIEN

            7'b010010: begin
               if (wr_en_i) begin
                  INTDI[7:0] <= wr_d_i[7:0];  
                  LEGACYCLR <= wr_d_i[8];
               end


               rd_d_o <= {4'h0, 
                          cfg_interrupt_msienable,
                          cfg_interrupt_mmenable[2:0],
                          cfg_interrupt_do[7:0],
                          7'h0,
                          LEGACYCLR,
                          INTDI[7:0]};
            end

`ifdef PCIE2_0
            // 4C-4FH : Reg # 19
            // CHG(RW), LTS, TW(RW), TS(RW), A(RW), P(RW), CW, CS, G2S, PG2S, 
            // LILW, LUC, SCE, WCE, LR

            7'b010011: begin
               if (wr_en_i) begin
                   clr_pl_width_change_err       <= wr_d_i[29];
                   clr_pl_speed_change_err       <= wr_d_i[28];
                   pl_upstream_preemph_src       <= wr_d_i[15];    // P
                   pl_directed_link_auton        <= wr_d_i[14];    // A
                   pl_directed_link_speed_binary <= wr_d_i[13:12]; // TS
                   pl_directed_link_width        <= wr_d_i[9:8];   // TW
                   pl_directed_link_change       <= wr_d_i[1:0];   // CHG
               end else
               begin
                   clr_pl_width_change_err          <= 1'b0;
                   clr_pl_speed_change_err          <= 1'b0;
                   
                   pl_directed_link_change <= clear_directed_speed_change_i ?
                                      0 : pl_directed_link_change;  

               end

               rd_d_o <= { 
                  pl_lane_reversal_mode[1:0],             //LR   31:30
                  pl_width_change_err,                    //WCE     29
                  pl_speed_change_err,                    //SCE     28
                  pl_link_upcfg_capable,                  //LUC     27
                  pl_initial_link_width[2:0],             //LILW 26:24
                  pl_link_partner_gen2_supported,         //PG2S    23
                  pl_link_gen2_capable,                   //G2S     22
                  pl_sel_link_rate_binary[1:0],           //CS   21:20
                  2'b0,                                   //R1   19:18
                  pl_sel_link_width[1:0],                 // CW  17:16
                  pl_upstream_preemph_src,                //P       15
                  pl_directed_link_auton,                 //A       14
                  pl_directed_link_speed_binary[1:0],     //TS   13:12
                  2'b0,                                   //R0   11:10 
                  pl_directed_link_width[1:0],            //TW    9: 8
                  pl_ltssm_state[5:0],                    //LTS   7: 2
                  pl_directed_link_change[1:0]            //CHG   1: 0
                          };
            end
`endif


            // 50-7FH : Reserved
            default: begin

              rd_d_o <= 32'b0;

            end

          endcase

        end

    end


    /*
     * Memory Write Performance Instrumentation
     */

    always @(posedge clk ) begin

        if ( !rst_n ) begin

          mwr_perf <= 32'b0;

        end else begin

          if (init_rst_o)
            mwr_perf <= 32'b0;
          else if (mwr_start_o && !mwr_done_i)
            mwr_perf <= mwr_perf + 1'b1;

        end

    end

    /*
     * Memory Read Performance Instrumentation
     */

    always @(posedge clk ) begin

        if ( !rst_n ) begin

          mrd_perf <= 32'b0;

        end else begin

          if (init_rst_o)
            mrd_perf <= 32'b0;
          else if (mrd_start_o && !mrd_done_o)
            mrd_perf <= mrd_perf + 1'b1;

        end

    end


//Account for 128 bit interface calculation error in GUI
//

    always @(posedge clk ) begin

        if ( !rst_n ) begin
          mrd_perf_post <= 32'b0;
          mwr_perf_post <= 32'b0;
        end else if (interface_type == 4'b0011) begin
           mrd_perf_post <= mrd_perf << 1;
           mwr_perf_post <= mwr_perf << 1;
        end else begin
           mrd_perf_post <= mrd_perf;
           mwr_perf_post <= mwr_perf;
        end

    end



    always @(posedge clk ) begin

        if ( !rst_n ) begin

          expect_cpld_data_size  <=  21'b0;
          cpld_data_size         <=  21'b0;
          cpld_done              <=  1'b0;

        end else begin

          if (init_rst_o) begin

            expect_cpld_data_size <=  21'b0;
            cpld_data_size        <=  21'b0;
            cpld_done             <=  1'b0;

          end else begin

            expect_cpld_data_size <= mrd_len_o[15:0] * mrd_count_o[15:0];
            cpld_data_size        <= cpld_data_size_i[20:0];
            cpld_done             <= (expect_cpld_data_size == cpld_data_size);

          end

        end

    end

    always @(posedge clk ) begin

        if ( !rst_n )
          mrd_done_o <= 1'b0;
        else
          if (init_rst_o)
            mrd_done_o <= 1'b0;
          else if ( (mrd_start_o) && (!mrd_done_o) && (cpld_done) )
            mrd_done_o <= 1'b1;
    end

endmodule

