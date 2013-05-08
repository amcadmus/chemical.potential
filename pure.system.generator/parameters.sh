#!/bin/bash

mol_name=SOL
cg_charge_group_name=CMW
ex_charge_group_name=EXW
force_field="gromos53a6"

mdrun_command="mdrun"
mdrun_options=""
epsilon_rf=80					# 60 is for spc water..
itp_file="tops/spce.itp"			# 
adress_itp_file="tops/spce.adress.itp"	# the COM top should be included!!
block_conf_file="confs/spce.block.gro"	# building block of conf
input_conf_file="confs/spce.input.gro"	# input conf for productive run

make_file=machine.dep/Makefile.fu
env_file=machine.dep/env.sh.fu
submit_file=machine.dep/auto.adagio.sh
