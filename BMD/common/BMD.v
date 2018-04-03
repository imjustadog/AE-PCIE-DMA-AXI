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
//-- Filename: BMD.v
//--
//-- Description: Bus Master Device (BMD) Module
//--              
//--              The module designed to operate with 32 bit and 64 bit interfaces.
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

module BMD #
  (
   parameter INTERFACE_WIDTH = 64,
   parameter INTERFACE_TYPE = 4'b0010,
   parameter FPGA_FAMILY = 8'h14
   )
    (

                  trn_clk,
                  trn_reset_n,
                  trn_lnk_up_n,

                  trn_td,
                  trn_trem_n,
                  trn_tsof_n,
                  trn_teof_n,
                  trn_tsrc_rdy_n,
                  trn_tsrc_dsc_n,
                  trn_tdst_rdy_n,
                  trn_tdst_dsc_n,
                  trn_tbuf_av,

                  trn_rd,
                  trn_rrem_n,
                  trn_rsof_n,
                  trn_reof_n,
                  trn_rsrc_rdy_n,
                  trn_rsrc_dsc_n,
                  trn_rdst_rdy_n,
                  trn_rbar_hit_n,
                  trn_rnp_ok_n,
                  
                  trn_rcpl_streaming_n, //only for Block Plus
                  
                  cfg_to_turnoff_n,
                  cfg_turnoff_ok_n,
        
                  cfg_interrupt_n,
                  cfg_interrupt_rdy_n,
                  cfg_interrupt_assert_n,
                  cfg_interrupt_di,
                  cfg_interrupt_do,
                  cfg_interrupt_mmenable,
                  cfg_interrupt_msienable,

                  cfg_neg_max_lnk_width,
                  cfg_prg_max_payload_size,
                  cfg_max_rd_req_size,
                  cfg_rd_comp_bound,

                  cfg_phant_func_en,
                  cfg_phant_func_supported,


                  cfg_dwaddr,
                  cfg_rd_en_n,
                  cfg_do,
                  cfg_rd_wr_done_n,
                  trn_tstr_n,        //only for V6/S6

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

                  cpld_data_size_hwm,     // HWMark for Completion Data (DWs)
                  cur_rd_count_hwm,       // HWMark for Read Count Allowed
                  cpld_size,
                  cur_mrd_count,

                  cfg_completer_id,
                  cfg_ext_tag_en,
                  cfg_bus_mstr_enable

                  ); // synthesis syn_hier = "hard"

    ///////////////////////////////////////////////////////////////////////////////
    // Port Declarations
    ///////////////////////////////////////////////////////////////////////////////

    input         trn_clk;         
    input         trn_reset_n;
    input         trn_lnk_up_n;

    output [INTERFACE_WIDTH-1:0] trn_td;
    output [(INTERFACE_WIDTH/8)-1:0]  trn_trem_n;

    output        trn_tsof_n;
    output        trn_teof_n;
    output        trn_tsrc_rdy_n;
    output        trn_tsrc_dsc_n;
    input         trn_tdst_rdy_n;
    input         trn_tdst_dsc_n;
    input  [5:0]  trn_tbuf_av;
    output        trn_tstr_n;


    input [INTERFACE_WIDTH-1:0]  trn_rd;
    input [(INTERFACE_WIDTH/8)-1:0]   trn_rrem_n;

    input         trn_rsof_n;
    input         trn_reof_n;
    input         trn_rsrc_rdy_n;
    input         trn_rsrc_dsc_n;
    output        trn_rdst_rdy_n;
    input [6:0]   trn_rbar_hit_n;
    output        trn_rnp_ok_n;

    output        trn_rcpl_streaming_n;
    input         cfg_to_turnoff_n;
    output        cfg_turnoff_ok_n;

    output        cfg_interrupt_n;
    input         cfg_interrupt_rdy_n;
    output        cfg_interrupt_assert_n;
    output  [7:0] cfg_interrupt_di;
    input   [7:0] cfg_interrupt_do;
    input   [2:0] cfg_interrupt_mmenable;
    input         cfg_interrupt_msienable;

    input [15:0]  cfg_completer_id;
    input         cfg_ext_tag_en;
    input         cfg_bus_mstr_enable;
    input [5:0]   cfg_neg_max_lnk_width;
    input [2:0]   cfg_prg_max_payload_size;
    input [2:0]   cfg_max_rd_req_size;
    input         cfg_rd_comp_bound;

    input         cfg_phant_func_en;
    input [1:0]   cfg_phant_func_supported;

   
    output [9:0]  cfg_dwaddr;
    output        cfg_rd_en_n;
    input  [31:0] cfg_do;
    input         cfg_rd_wr_done_n;

`ifdef PCIE2_0
    output [1:0]  pl_directed_link_change;
    input  [5:0]  pl_ltssm_state;
    output [1:0]  pl_directed_link_width;
    output        pl_directed_link_speed;
    output        pl_directed_link_auton;
    output        pl_upstream_preemph_src;
    input  [1:0]  pl_sel_link_width;
    input         pl_sel_link_rate;
    input         pl_link_gen2_capable;
    input         pl_link_partner_gen2_supported;
    input  [2:0]  pl_initial_link_width;
    input         pl_link_upcfg_capable;
    input  [1:0]  pl_lane_reversal_mode;
`endif

    output [31:0] cpld_data_size_hwm;     // HWMark for Completion Data (DWs)
    output [15:0] cur_rd_count_hwm;       // HWMark for Read Count Allowed
    output [31:0] cpld_size;
    output [15:0] cur_mrd_count;



    // Local wires

    wire          req_compl;
    wire          compl_done;
    wire          bmd_reset_n = trn_reset_n & ~trn_lnk_up_n;
    wire [5:0]    cfg_cap_max_lnk_width;
    wire [2:0]    cfg_cap_max_payload_size;

    BMD_EP# 
       (
        .INTERFACE_WIDTH(INTERFACE_WIDTH),
        .INTERFACE_TYPE(INTERFACE_TYPE),
        .FPGA_FAMILY(FPGA_FAMILY)
 
        )
        BMD_EP (

                  .clk  ( trn_clk ),                           // I
                  .rst_n ( bmd_reset_n ),                      // I

                  .trn_td ( trn_td ),                          // O [63/31:0]
                  .trn_trem_n ( trn_trem_n ),                  // O [7:0]
                  .trn_tsof_n ( trn_tsof_n ),                  // O
                  .trn_teof_n ( trn_teof_n ),                  // O
                  .trn_tsrc_rdy_n ( trn_tsrc_rdy_n ),          // O
                  .trn_tsrc_dsc_n ( trn_tsrc_dsc_n ),          // O
                  .trn_tdst_rdy_n ( trn_tdst_rdy_n ),          // I
                  .trn_tdst_dsc_n ( trn_tdst_dsc_n ),          // I
                  .trn_tbuf_av ( trn_tbuf_av ),                // I [5:0]
                  .trn_tstr_n ( trn_tstr_n ),                  // O

                  .trn_rd ( trn_rd ),                          // I [63/31:0]
                  .trn_rrem_n ( trn_rrem_n ),                  // I
                  .trn_rsof_n ( trn_rsof_n ),                  // I
                  .trn_reof_n ( trn_reof_n ),                  // I
                  .trn_rsrc_rdy_n ( trn_rsrc_rdy_n ),          // I
                  .trn_rsrc_dsc_n ( trn_rsrc_dsc_n ),          // I
                  .trn_rdst_rdy_n ( trn_rdst_rdy_n ),          // O
                  .trn_rbar_hit_n ( trn_rbar_hit_n ),          // I [6:0]
                  .trn_rnp_ok_n ( trn_rnp_ok_n ),              // O
                  .trn_rcpl_streaming_n( trn_rcpl_streaming_n ), // O


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
`endif

                  .req_compl_o(req_compl),                     // O
                  .compl_done_o(compl_done),                   // O

                  .cfg_interrupt_n(cfg_interrupt_n),           // O
                  .cfg_interrupt_rdy_n(cfg_interrupt_rdy_n),   // I
                  .cfg_interrupt_assert_n(cfg_interrupt_assert_n), // O

                  .cfg_interrupt_di ( cfg_interrupt_di ),      // O       
                  .cfg_interrupt_do ( cfg_interrupt_do ),      // I       
                  .cfg_interrupt_mmenable ( cfg_interrupt_mmenable ),     // I
                  .cfg_interrupt_msienable ( cfg_interrupt_msienable ),   // I
                  .cfg_completer_id ( cfg_completer_id ),      // I [15:0]

                  .cfg_ext_tag_en ( cfg_ext_tag_en ),              // I
                  .cfg_cap_max_lnk_width( cfg_cap_max_lnk_width ), // I [5:0]
                  .cfg_neg_max_lnk_width( cfg_neg_max_lnk_width ), // I [5:0]

                  .cfg_cap_max_payload_size( cfg_cap_max_payload_size ), // I [2:0]
                  .cfg_prg_max_payload_size( cfg_prg_max_payload_size ), // I [2:0]
                  .cfg_max_rd_req_size( cfg_max_rd_req_size ),           // I [2:0]
                  .cfg_msi_enable(cfg_interrupt_msienable),              // I
                  .cfg_rd_comp_bound( cfg_rd_comp_bound ),               // I
                  .cfg_phant_func_en(cfg_phant_func_en),                 // I
                  .cfg_phant_func_supported(cfg_phant_func_supported),   // I [1:0] 

                  .cpld_data_size_hwm(cpld_data_size_hwm),
                  .cur_rd_count_hwm(cur_rd_count_hwm),       
                  .cpld_size(cpld_size),
                  .cur_mrd_count(cur_mrd_count),

                  .cfg_bus_mstr_enable ( cfg_bus_mstr_enable )     // I

                  );

    BMD_TO_CTRL BMD_TO  (

                  .clk( trn_clk ),                             // I
                  .rst_n( bmd_reset_n ),                       // I

                  .req_compl_i( req_compl ),                   // I
                  .compl_done_i( compl_done ),                 // I

                  .cfg_to_turnoff_n( cfg_to_turnoff_n ),       // I
                  .cfg_turnoff_ok_n( cfg_turnoff_ok_n )        // O
     
                  );

    BMD_CFG_CTRL BMD_CF  (

                  .clk( trn_clk ),                             // I
                  .rst_n( bmd_reset_n ),                       // I

                  .cfg_bus_mstr_enable( cfg_bus_mstr_enable ), // I

                  .cfg_dwaddr( cfg_dwaddr ),                    // O [9:0]
                  .cfg_rd_en_n( cfg_rd_en_n ),                  // O
                  .cfg_do( cfg_do ),                            // I [31:0]
                  .cfg_rd_wr_done_n( cfg_rd_wr_done_n ),        // I

                  .cfg_cap_max_lnk_width( cfg_cap_max_lnk_width ),       // O [5:0]
                  .cfg_cap_max_payload_size( cfg_cap_max_payload_size )  // O [2:0]
//                  .cfg_msi_enable(cfg_msi_enable)                        // O
     
                  );
   
endmodule // BMD
