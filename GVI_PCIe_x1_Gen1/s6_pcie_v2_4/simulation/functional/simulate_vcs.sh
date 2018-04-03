#!/bin/sh

# remove old files
rm -rf *.dat *.log vcs.key simv* csrc

# compile all the files and prepare the simulation
vcs   +alwaystrigger +v2k +cli -lca \
      -PP \
      +define+VCS \
      +libext+.v \
      -y $XILINX/verilog/src/simprims \
      -y $XILINX/verilog/src/unisims \
      -f $XILINX/secureip/vcs/gtxe1_vcs/gtxe1_cell.list.f \
      -f $XILINX/secureip/vcs/gtpa1_dual_vcs/gtpa1_dual_cell.list.f \
      -f $XILINX/secureip/vcs/pcie_2_0_vcs/pcie_2_0_cell.list.f \
      -f $XILINX/secureip/vcs/pcie_a1_vcs/pcie_a1_cell.list.f \
      $XILINX/verilog/src/glbl.v \
      -f board.f

# set BATCH_MODE=0 to save dump-file and launch GUI
BATCH_MODE=1

if (test -e ./simv); then
  if [ $BATCH_MODE == 1 ]; then

    # run the simulation in batch mode
    ./simv +TESTNAME=pio_writeReadBack_test0

  else

    # run the simulation and launch GUI to view dump-file
    ./simv +TESTNAME=pio_writeReadBack_test0 +dump_all

    dve -vpd board.vpd -session wave.tcl

  fi
fi

