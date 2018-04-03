
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name BMD_design -dir "D:/GitHub/AE-PCIE-DMA-AXI/BMD_design/planAhead_run_1" -part xc6slx45tcsg324-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "D:/GitHub/AE-PCIE-DMA-AXI/BMD_design/xilinx_pcie_1_1_ep_s6.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/GitHub/AE-PCIE-DMA-AXI/BMD_design} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "D:/GitHub/AE-PCIE-DMA-AXI/GVI_PCIe_x1_Gen1/s6_pcie_v2_4/example_design/xilinx_pcie_1_lane_ep_xc6slx45t-csg324-3.ucf" [current_fileset -constrset]
add_files [list {D:/GitHub/AE-PCIE-DMA-AXI/GVI_PCIe_x1_Gen1/s6_pcie_v2_4/example_design/xilinx_pcie_1_lane_ep_xc6slx45t-csg324-3.ucf}] -fileset [get_property constrset [current_run]]
open_netlist_design
