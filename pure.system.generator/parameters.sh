#!/bin/bash

mol_name=SOL
cg_charge_group_name=CMW
ex_charge_group_name=EXW
force_field="gromos53a6"

mdrun_command="mpiexec mdrun_mpi"
mdrun_options=""
epsilon_rf=60					# 60 is for spc water..
itp_file="tops/spc.itp"			# 
adress_itp_file="tops/spc.adress.itp"	# the COM top should be included!!
block_conf_file="confs/spc.block.gro"	# building block of conf
input_conf_file="confs/spc.input.gro"	# input conf for productive run

make_file=machine.dep/Makefile.hlrn
env_file=machine.dep/env.sh.hlrn
submit_file=machine.dep/auto.hlrn.sh
