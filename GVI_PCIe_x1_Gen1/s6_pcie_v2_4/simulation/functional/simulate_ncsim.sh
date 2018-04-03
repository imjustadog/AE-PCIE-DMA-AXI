#!/bin/sh

# set up the working directory
rm -rf INCA* work
mkdir work

# compile all of the files
ncvlog -work work $XILINX/verilog/src/glbl.v

ncvlog -work work -update -linedebug -status \
  -define SIMULATION -define DISABLE_COLLISION_CHECK -define NCV \
  -file board.f ${XILINX}/verilog/src/unisims/PCIE_2_0.v ${XILINX}/verilog/src/unisims/GTXE1.v

# elaborate and run the simulation
ncelab -work work -logfile ncelab.log -access +rwc -status \
  -timescale 1ns/1ps work.board work.glbl
# set BATCH_MODE=0 to run simulation in GUI mode
BATCH_MODE=1

if [ $BATCH_MODE == 1 ]; then

  # run the simulation in batch mode
  ncsim work.board

else

  # run the simulation in GUI mode
  ncsim -gui work.board -input @"simvision -input wave.sv"

fi

