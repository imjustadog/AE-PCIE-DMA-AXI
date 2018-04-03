#
# Simulator
#

database require simulator -hints {
    simulator "ncsim -gui work.board"
}

#
# groups
#
catch {group new -name {SYS Interface} -overlay 0}
catch {group new -name {AXI Common} -overlay 0}
catch {group new -name {AXI Rx} -overlay 0}
catch {group new -name {AXI Tx} -overlay 0}

group using {SYS Interface}
group set -overlay 0
group set -comment {}
group clear 0 end

group insert \
    board.EP.sys_clk_c \
    board.EP.sys_reset_n_c

group using {AXI Common}
group set -overlay 0
group set -comment {}
group clear 0 end

group insert \
    board.EP.user_clk \
    board.EP.user_reset \
    board.EP.user_lnk_up \
    {board.EP.fc_sel[2:0]} \
    {board.EP.fc_cpld[11:0]} \
    {board.EP.fc_cplh[7:0]} \
    {board.EP.fc_npd[11:0]} \
    {board.EP.fc_nph[7:0]} \
    {board.EP.fc_pd[11:0]} \
    {board.EP.fc_ph[7:0]}

group using {AXI Rx}
group set -overlay 0
group set -comment {}
group clear 0 end

group insert \
    {board.EP.m_axis_rx_tdata[31:0]} \
    board.EP.m_axis_rx_tready \
    board.EP.m_axis_rx_tvalid \
    board.EP.m_axis_rx_tlast \
    {board.EP.m_axis_rx_tuser[21:0]} \
    board.EP.rx_np_ok

group using {AXI Tx}
group set -overlay 0
group set -comment {}
group clear 0 end
group insert \
{board.EP.s_axis_tx_tdata[31:0]} \
board.EP.s_axis_tx_tready \
board.EP.s_axis_tx_tvalid \
board.EP.s_axis_tx_tlast  \
{board.EP.s_axis_tx_tuser[3:0]}  \
{board.EP.tx_buf_av[4:0]} \
board.EP.tx_err_drop \
board.EP.tx_cfg_req \
board.EP.tx_cfg_gnt
#
# Design Browser windows
#
if {[catch {window new WatchList -name "Design Browser 1" -geometry 700x500+0+462}] != ""} {
    window geometry "Design Browser 1" 700x500+0+462
}
window target "Design Browser 1" on
browser using {Design Browser 1}
browser set \
    -scope simulator::board.EP
browser yview see simulator::board.EP
browser timecontrol set -lock 0

#
# Waveform windows
#
if {[catch {window new WaveWindow -name "Waveform 1" -geometry 800x600+0+0}] != ""} {
    window geometry "Waveform 1" 800x600+0+0
}
window target "Waveform 1" on
waveform using {Waveform 1}
waveform sidebar visibility partial
waveform set \
    -primarycursor TimeA \
    -signalnames name \
    -signalwidth 175 \
    -units ns \
    -valuewidth 75
cursor set -using TimeA -time 0
cursor set -using TimeA -marching 1
waveform baseline set -time 0

set groupId [waveform add -groups {{SYS Interface}}]

set groupId [waveform add -groups {{AXI Common}}]

set groupId [waveform add -groups {{AXI Rx}}]

set groupId [waveform add -groups {{AXI Tx}}]


waveform xview limits 0 2000ns

#
# Console window
#
console set -windowname Console
