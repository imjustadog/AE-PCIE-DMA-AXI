REM file: implement.bat

REM -----------------------------------------------------------------------------
REM  Script to synthesize and implement the RTL provided for the clocking wizard
REM -----------------------------------------------------------------------------

REM Clean up the results directory
rmdir /S /Q results
mkdir results

REM Synthesize the Verilog Wrapper Files
echo 'Synthesizing example design with XST'
xst -ifn xst.scr
move xilinx_pcie_1_1_ep_s6.ngc .\results\s6_pcie_v2_4_top.ngc

cd results

echo 'Running ngdbuild'
ngdbuild -verbose -uc ..\..\example_design\xilinx_pcie_1_lane_ep_xc6slx45t-csg324-3.ucf s6_pcie_v2_4_top.ngc
echo 'Running map'
map -o mapped.ncd s6_pcie_v2_4_top.ngd mapped.pcf

echo 'Running par'
par -w mapped.ncd routed.ncd mapped.pcf

echo 'Running trce'
trce -u -e 100 routed.ncd mapped.pcf

echo 'Running netgen to create gate level model'
netgen -ofmt verilog -sim -ne -sdf_path ..\..\implement\results -tm xilinx_pcie_1_1_ep_s6 -w routed.ncd

echo 'Running design through bitgen'
bitgen -w routed.ncd routed.bit mapped.pcf

cd ..

