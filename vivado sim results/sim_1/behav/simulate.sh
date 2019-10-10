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
ExecStep $xv_path/bin/xsim ball_position_controller_tb_behav -key {Behavioral:sim_1:Functional:ball_position_controller_tb} -tclbatch ball_position_controller_tb.tcl -log simulate.log
