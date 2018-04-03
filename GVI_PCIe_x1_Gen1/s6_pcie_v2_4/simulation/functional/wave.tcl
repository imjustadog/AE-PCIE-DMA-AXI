gui_open_window Wave
set {SYS Interface} {SYS Interface}
gui_sg_create ${SYS Interface}
gui_sg_addsignal -group ${SYS Interface} { {board.EP.sys_clk_c} {board.EP.sys_reset_n_c} }
set {TRN Common} {TRN Common}
gui_sg_create ${TRN Common}
gui_sg_addsignal -group ${TRN Common} { {board.EP.trn_clk} {board.EP.trn_reset_n} {board.EP.trn_lnk_up_n} {board.EP.trn_fc_sel} {board.EP.trn_fc_cpld} {board.EP.trn_fc_cplh} {board.EP.trn_fc_npd} {board.EP.trn_fc_nph} {board.EP.trn_fc_pd} {board.EP.trn_fc_ph} }
set {TRN Rx} {TRN Rx}
gui_sg_create ${TRN Rx}
gui_sg_addsignal -group ${TRN Rx} { {board.EP.trn_rbar_hit_n} {board.EP.trn_rsrc_rdy_n} {board.EP.trn_rdst_rdy_n} {board.EP.trn_rsof_n} {board.EP.trn_reof_n} {board.EP.trn_rd} {board.EP.trn_rerrfwd_n} {board.EP.trn_rsrc_dsc_n} {board.EP.trn_rnp_ok_n} }
set {TRN Tx} {TRN Tx}
gui_sg_create ${TRN Tx}
gui_sg_addsignal -group ${TRN Tx} { {board.EP.trn_tsrc_rdy_n} {board.EP.trn_tdst_rdy_n} {board.EP.trn_tsof_n} {board.EP.trn_teof_n} {board.EP.trn_td} {board.EP.trn_tstr_n} {board.EP.trn_terrfwd_n} {board.EP.trn_tsrc_dsc_n} {board.EP.trn_terr_drop_n} {board.EP.trn_tbuf_av} {board.EP.trn_tcfg_req_n} {board.EP.trn_tcfg_gnt_n} }

gui_list_add_group -id Wave.1 -after {New Group} {{SYS Interface}}
gui_list_add_group -id Wave.1 -after {New Group} {{TRN Common}}
gui_list_add_group -id Wave.1 -after {New Group} {{TRN Rx}}
gui_list_add_group -id Wave.1 -after {New Group} {{TRN Tx}}

