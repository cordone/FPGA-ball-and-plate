#!/bin/bash -f
xv_path="/var/local/xilinx-local/Vivado/2016.2"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto 8b88da8e353b4e9987c87d8e5f0027fd -m64 --debug typical --relax --mt 8 -L xbip_utils_v3_0_6 -L xbip_pipe_v3_0_2 -L xbip_bram18k_v3_0_2 -L mult_gen_v12_0_11 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot ball_position_controller_tb_behav xil_defaultlib.ball_position_controller_tb xil_defaultlib.glbl -log elaborate.log
