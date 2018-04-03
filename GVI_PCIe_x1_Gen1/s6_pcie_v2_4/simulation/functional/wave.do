onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {SYS Interface}
add wave -noupdate -format Logic /board/EP/sys_clk_c
add wave -noupdate -format Logic /board/EP/sys_reset_n_c
add wave -noupdate -divider {AXI Common}
add wave -noupdate -format Logic /board/EP/user_clk
add wave -noupdate -format Logic /board/EP/user_reset
add wave -noupdate -format Logic /board/EP/user_lnk_up
add wave -noupdate -format Literal /board/EP/fc_sel
add wave -noupdate -format Literal /board/EP/fc_cpld
add wave -noupdate -format Literal /board/EP/fc_cplh
add wave -noupdate -format Literal /board/EP/fc_npd
add wave -noupdate -format Literal /board/EP/fc_nph
add wave -noupdate -format Literal /board/EP/fc_pd
add wave -noupdate -format Literal /board/EP/fc_ph
add wave -noupdate -divider {AXI Rx}
add wave -noupdate -format Literal /board/EP/m_axis_rx_tdata
add wave -noupdate -format Logic /board/EP/m_axis_rx_tready
add wave -noupdate -format Logic /board/EP/m_axis_rx_tvalid
add wave -noupdate -format Logic /board/EP/m_axis_rx_tlast
add wave -noupdate -format Literal /board/EP/m_axis_rx_tuser
add wave -noupdate -format Logic /board/EP/rx_np_ok
add wave -noupdate -divider {AXI Tx}
add wave -noupdate -format Literal /board/EP/s_axis_tx_tdata
add wave -noupdate -format Logic /board/EP/s_axis_tx_tready
add wave -noupdate -format Logic /board/EP/s_axis_tx_tvalid
add wave -noupdate -format Logic /board/EP/s_axis_tx_tlast
add wave -noupdate -format Literal /board/EP/s_axis_tx_tuser
add wave -noupdate -format Literal /board/EP/tx_buf_av
add wave -noupdate -format Logic /board/EP/tx_err_drop
add wave -noupdate -format Logic /board/EP/tx_cfg_req
add wave -noupdate -format Logic /board/EP/tx_cfg_gnt
TreeUpdate [SetDefaultTree]
update
