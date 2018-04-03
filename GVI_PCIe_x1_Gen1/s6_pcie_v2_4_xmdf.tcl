# The package naming convention is <core_name>_xmdf
package provide s6_pcie_v2_4_xmdf 1.0

# This includes some utilities that support common XMDF operations
package require utilities_xmdf

# Define a namespace for this package. The name of the name space
# is <core_name>_xmdf
namespace eval ::s6_pcie_v2_4_xmdf {
# Use this to define any statics
}

# Function called by client to rebuild the params and port arrays
# Optional when the use context does not require the param or ports
# arrays to be available.
proc ::s6_pcie_v2_4_xmdf::xmdfInit { instance } {
# Variable containg name of library into which module is compiled
# Recommendation: <module_name>
# Required
utilities_xmdf::xmdfSetData $instance Module Attributes Name s6_pcie_v2_4
}
# ::s6_pcie_v2_4_xmdf::xmdfInit

# Function called by client to fill in all the xmdf* data variables
# based on the current settings of the parameters
proc ::s6_pcie_v2_4_xmdf::xmdfApplyParams { instance } {

set fcount 0
# Array containing libraries that are assumed to exist
# Examples include unisim and xilinxcorelib
# Optional
# In this example, we assume that the unisim library will
# be magically
# available to the simulation and synthesis tool
utilities_xmdf::xmdfSetData $instance FileSet $fcount type logical_library
utilities_xmdf::xmdfSetData $instance FileSet $fcount logical_library unisim
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/source/s6_pcie_v2_4.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/source/gtpa1_dual_wrapper.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/source/gtpa1_dual_wrapper_tile.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/source/pcie_bram_s6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/source/pcie_bram_top_s6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/source/pcie_brams_s6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/source/axi_basic_tx_thrtl_ctl.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/source/axi_basic_rx.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/source/axi_basic_rx_null_gen.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/source/axi_basic_rx_pipeline.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/source/axi_basic_tx_pipeline.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/source/axi_basic_tx.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/source/axi_basic_top.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4.veo
utilities_xmdf::xmdfSetData $instance FileSet $fcount type verilog_template
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4_verilog_example_project.xise
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/example_design/PIO.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/example_design/PIO_32_RX_ENGINE.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/example_design/PIO_32_TX_ENGINE.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/example_design/PIO_EP.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/example_design/PIO_EP_MEM.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/example_design/PIO_EP_MEM_ACCESS.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/example_design/PIO_TO_CTRL.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/example_design/pcie_app_s6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/example_design/xilinx_pcie_1_1_ep_s6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/implement/implement.bat
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/implement/implement.sh
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/implement/xst.prj
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/implement/xst.scr
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/example_design/xilinx_pcie_1_lane_ep_xc6slx45t-csg324-3.ucf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/functional/simulate_mti.do
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/functional/simulate_ncsim.sh
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/functional/simulate_vcs.sh
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/functional/simulate_isim.sh
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/functional/wave.do
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/functional/wave.sv
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/functional/wave.tcl
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/functional/wave.wcfg
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/functional/isim_cmd.tcl
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/functional/board.f
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/functional/board.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/functional/sys_clk_gen.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/functional/sys_clk_gen_ds.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/tests/tests.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pci_exp_usrapp_com.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pci_exp_usrapp_cfg.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pci_exp_usrapp_rx.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pci_exp_usrapp_tx.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pci_exp_usrapp_pl.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/xilinx_pcie_2_0_rport_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pcie_2_0_rport_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pcie_2_0_v6_rp.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount


utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pcie_clocking_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pcie_reset_delay_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pcie_pipe_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pcie_pipe_lane_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pcie_pipe_misc_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/gtx_wrapper_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/gtx_tx_sync_rate_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pcie_gtx_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pcie_bram_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pcie_brams_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pcie_bram_top_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/pcie_upconfig_fix_3451_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/gtx_rx_valid_filter_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4/simulation/dsport/gtx_drp_chanalign_fix_3752_v6.v
utilities_xmdf::xmdfSetData $instance FileSet $fcount type Ignore
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4.xco
utilities_xmdf::xmdfSetData $instance FileSet $fcount type coregen_ip
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path s6_pcie_v2_4_xmdf.tcl
utilities_xmdf::xmdfSetData $instance FileSet $fcount type AnyView
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount associated_module s6_pcie_v2_4
incr fcount

}

# ::s6_pcie_v2_4_xmdf::xmdfApplyParams

