//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------
//-- Filename: pci_exp_32b_app.v
//--
//-- Description:  PCI Express Endpoint Core 32 bit interface sample application
//--               design. 
//--
//------------------------------------------------------------------------------


module  pci_exp_32b_app (

                        trn_clk,
                        trn_reset_n,
                        trn_lnk_up_n, 
            
                        trn_td,
                        trn_tsof_n,
                        trn_teof_n,
                        trn_tsrc_rdy_n,
                        trn_tdst_rdy_n,
                        trn_tsrc_dsc_n,
                        trn_tdst_dsc_n,
                        trn_terrfwd_n,
                        trn_tbuf_av,
            
                        trn_rd,
                        trn_rsof_n,
                        trn_reof_n,
                        trn_rsrc_rdy_n,
                        trn_rsrc_dsc_n,
                        trn_rdst_rdy_n,
                        trn_rerrfwd_n,
                        trn_rnp_ok_n,
                        trn_rbar_hit_n,
                        trn_rfc_nph_av,
                        trn_rfc_npd_av,
                        trn_rfc_ph_av,
                        trn_rfc_pd_av,
                        trn_rfc_cplh_av,
                        trn_rfc_cpld_av,
            
                        cfg_do,
                        cfg_rd_wr_done_n,
                        cfg_di,
                        cfg_byte_en_n,
                        cfg_dwaddr,
                        cfg_wr_en_n,
                        cfg_rd_en_n,
                        cfg_err_cor_n,
                        cfg_err_ur_n,
                        cfg_err_ecrc_n,
                        cfg_err_cpl_timeout_n,
                        cfg_err_cpl_abort_n,
                        cfg_err_cpl_unexpect_n,
                        cfg_err_posted_n,
                        cfg_err_tlp_cpl_header,
                        cfg_interrupt_n,
                        cfg_interrupt_rdy_n,
                        cfg_interrupt_assert_n,
                        cfg_interrupt_di,
                        cfg_interrupt_do,
                        cfg_interrupt_mmenable,
                        cfg_interrupt_msienable,
                        cfg_turnoff_ok_n,
                        cfg_to_turnoff_n,
                        cfg_pm_wake_n,
                        cfg_status,
                        cfg_command,
                        cfg_dstatus,
                        cfg_dcommand,
                        cfg_lstatus,
                        cfg_lcommand,

                        cfg_bus_number,
                        cfg_device_number,
                        cfg_function_number,
                        cfg_pcie_link_state_n,
                        cfg_dsn,
                        cfg_trn_pending_n
                        

                        );   

input                                             trn_clk;
input                                             trn_reset_n;
input                                             trn_lnk_up_n; 
output [(`PCI_EXP_TRN_DATA_WIDTH - 1):0]          trn_td;
output                                            trn_tsof_n;
output                                            trn_teof_n;
output                                            trn_tsrc_rdy_n;
input                                             trn_tdst_rdy_n;
output                                            trn_tsrc_dsc_n;
input                                             trn_tdst_dsc_n;
output                                            trn_terrfwd_n;
input  [(`PCI_EXP_TRN_BUF_AV_WIDTH - 1):0]        trn_tbuf_av;

input  [(`PCI_EXP_TRN_DATA_WIDTH - 1):0]          trn_rd;
input                                             trn_rsof_n;
input                                             trn_reof_n;
input                                             trn_rsrc_rdy_n;
input                                             trn_rsrc_dsc_n;
output                                            trn_rdst_rdy_n;
input                                             trn_rerrfwd_n;
output                                            trn_rnp_ok_n;

input  [(`PCI_EXP_TRN_BAR_HIT_WIDTH - 1):0]       trn_rbar_hit_n;
input  [(`PCI_EXP_TRN_FC_HDR_WIDTH - 1):0]        trn_rfc_nph_av;
input  [(`PCI_EXP_TRN_FC_DATA_WIDTH - 1):0]       trn_rfc_npd_av;
input  [(`PCI_EXP_TRN_FC_HDR_WIDTH - 1):0]        trn_rfc_ph_av;
input  [(`PCI_EXP_TRN_FC_DATA_WIDTH - 1):0]       trn_rfc_pd_av;
input  [(`PCI_EXP_TRN_FC_HDR_WIDTH - 1):0]        trn_rfc_cplh_av;
input  [(`PCI_EXP_TRN_FC_DATA_WIDTH - 1):0]       trn_rfc_cpld_av;

input  [(`PCI_EXP_CFG_DATA_WIDTH - 1):0]          cfg_do;
output [(`PCI_EXP_CFG_DATA_WIDTH - 1):0]          cfg_di;
output [(`PCI_EXP_CFG_DATA_WIDTH/8 - 1):0]        cfg_byte_en_n;
output [(`PCI_EXP_CFG_ADDR_WIDTH - 1):0]          cfg_dwaddr;
input                                             cfg_rd_wr_done_n;
output                                            cfg_wr_en_n;
output                                            cfg_rd_en_n;
output                                            cfg_err_cor_n;
output                                            cfg_err_ur_n;
output                                            cfg_err_ecrc_n;
output                                            cfg_err_cpl_timeout_n;
output                                            cfg_err_cpl_abort_n;
output                                            cfg_err_cpl_unexpect_n;
output                                            cfg_err_posted_n;
output                                            cfg_interrupt_n;
input                                             cfg_interrupt_rdy_n;
output                                            cfg_interrupt_assert_n;
output [7:0]                                      cfg_interrupt_di;
input  [7:0]                                      cfg_interrupt_do;
input  [2:0]                                      cfg_interrupt_mmenable;
input                                             cfg_interrupt_msienable;
output                                            cfg_turnoff_ok_n;
input                                             cfg_to_turnoff_n;
output                                            cfg_pm_wake_n;
output [(`PCI_EXP_CFG_CPLHDR_WIDTH - 1):0]        cfg_err_tlp_cpl_header;
input  [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]           cfg_status;
input  [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]           cfg_command;
input  [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]           cfg_dstatus;
input  [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]           cfg_dcommand;
input  [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]           cfg_lstatus;
input  [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]           cfg_lcommand;
input  [(`PCI_EXP_CFG_BUSNUM_WIDTH - 1):0]        cfg_bus_number;
input  [(`PCI_EXP_CFG_DEVNUM_WIDTH - 1):0]        cfg_device_number;
input  [(`PCI_EXP_CFG_FUNNUM_WIDTH - 1):0]        cfg_function_number;
input  [(`PCI_EXP_LNK_STATE_WIDTH - 1):0]         cfg_pcie_link_state_n;
output                                            cfg_trn_pending_n;
output [(`PCI_EXP_CFG_DSN_WIDTH - 1):0]           cfg_dsn;                          

// Local wires and registers
//wire                                              cfg_ext_tag_en;
//wire   [2:0]                                      cfg_max_rd_req_size;
//wire   [2:0]                                      cfg_max_payload_size;

//
// Core input tie-offs
//

assign trn_rnp_ok_n = 1'b0;
assign trn_terrfwd_n = 1'b1;

assign cfg_err_cor_n = 1'b1;
assign cfg_err_ur_n = 1'b1;
assign cfg_err_ecrc_n = 1'b1;
assign cfg_err_cpl_timeout_n = 1'b1;
assign cfg_err_cpl_abort_n = 1'b1;
assign cfg_err_cpl_unexpect_n = 1'b1;
assign cfg_err_posted_n = 1'b0;
assign cfg_pm_wake_n = 1'b1;
assign cfg_trn_pending_n = 1'b1;
//`ifndef BMDAPP
//assign cfg_interrupt_n = 1'b1;
//assign cfg_interrupt_assert_n = 1'b0;
assign cfg_interrupt_di = 8'b0;
//`endif

//assign cfg_dwaddr = 0;
assign cfg_err_tlp_cpl_header = 0;

assign cfg_di = 0;
assign cfg_byte_en_n = 4'hf;
assign cfg_wr_en_n = 1;
//assign cfg_rd_en_n = 1;
assign cfg_dsn = {`PCI_EXP_EP_DSN_2, `PCI_EXP_EP_DSN_1};

//
// Programmable I/O Module
//

wire [15:0] cfg_completer_id = {cfg_bus_number,
                                cfg_device_number,
                                cfg_function_number};

wire cfg_bus_mstr_enable = cfg_command[2];

//assign cfg_ext_tag_en = cfg_dcommand[8];
//assign cfg_max_rd_req_size = cfg_dcommand[14:12];
//assign cfg_max_payload_size = cfg_dcommand[7:5];

wire        cfg_ext_tag_en           = cfg_dcommand[8];
wire  [5:0] cfg_neg_max_lnk_width    = cfg_lstatus[9:4];
wire  [2:0] cfg_prg_max_payload_size = cfg_dcommand[7:5];
wire  [2:0] cfg_max_rd_req_size      = cfg_dcommand[14:12];
wire        cfg_rd_comp_bound        = cfg_lcommand[3];
 
parameter INTERFACE_WIDTH = 32;
 parameter INTERFACE_TYPE = 4'b0001;
 parameter FPGA_FAMILY = 8'h20; 


       BMD#
       (
        .INTERFACE_WIDTH(INTERFACE_WIDTH),
        .INTERFACE_TYPE(INTERFACE_TYPE),
        .FPGA_FAMILY(FPGA_FAMILY)
        )
        BMD(
        .trn_clk ( trn_clk ),                        // I
        .trn_reset_n ( trn_reset_n ),                // I
        .trn_lnk_up_n ( trn_lnk_up_n ),              // I

        .trn_td ( trn_td ),
        .trn_tsof_n ( trn_tsof_n ),                  // O [31:0]
        .trn_teof_n ( trn_teof_n ),                  // O
        .trn_tsrc_rdy_n ( trn_tsrc_rdy_n ),          // O
        .trn_tsrc_dsc_n ( trn_tsrc_dsc_n ),          // O
        .trn_tdst_rdy_n ( trn_tdst_rdy_n ),          // I
        .trn_tdst_dsc_n ( trn_tdst_dsc_n ),          // I
        .trn_tbuf_av ( trn_tbuf_av ),               // I [5:0]

        .trn_rd ( trn_rd ),                          // I [31:0]
        .trn_rsof_n ( trn_rsof_n ),                  // I
        .trn_reof_n ( trn_reof_n ),                  // I
        .trn_rsrc_rdy_n ( trn_rsrc_rdy_n ),          // I
        .trn_rsrc_dsc_n ( trn_rsrc_dsc_n ),          // I
        .trn_rdst_rdy_n ( trn_rdst_rdy_n ),          // O
        .trn_rbar_hit_n ( trn_rbar_hit_n ),         // I [6:0]

        .cfg_to_turnoff_n ( cfg_to_turnoff_n ),      // I
        .cfg_turnoff_ok_n ( cfg_turnoff_ok_n ),      // O

        .cfg_interrupt_n(cfg_interrupt_n),           // O
        .cfg_interrupt_rdy_n(cfg_interrupt_rdy_n),   // I

        .cfg_interrupt_msienable(cfg_interrupt_msienable), // I
        .cfg_interrupt_assert_n(cfg_interrupt_assert_n),   // O

        .cfg_ext_tag_en(cfg_ext_tag_en),                // I 

        .cfg_neg_max_lnk_width(cfg_neg_max_lnk_width),       // I [5:0]
        .cfg_prg_max_payload_size(cfg_prg_max_payload_size), // I [5:0]
        .cfg_max_rd_req_size(cfg_max_rd_req_size),           // I [2:0]
        .cfg_rd_comp_bound(cfg_rd_comp_bound),          // I

        .cfg_dwaddr(cfg_dwaddr),                        // O [11:0]
        .cfg_rd_en_n(cfg_rd_en_n),                      // O
        .cfg_do(cfg_do),                                // I [31:0]
        .cfg_rd_wr_done_n(cfg_rd_wr_done_n),            // I

        .cfg_completer_id ( cfg_completer_id ),      // I [15:0]
        .cfg_bus_mstr_enable (cfg_bus_mstr_enable )  // I

        );
endmodule // pci_exp_32b_app
