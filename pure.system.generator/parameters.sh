#!/bin/bash

mol_name=MeOH
cg_charge_group_name=CMC
ex_charge_group_name=EXC
force_field="gromos43a1"

mdrun_command="mpiexec mdrun_mpi"
mdrun_options="-v"
epsilon_rf=19				# 60 is for spc water..
itp_file="tops/methanol.itp"			# 
adress_itp_file="tops/methanol.adress.itp"	# the COM top should be included!!
cg_itp_file="tops/methanol.cg.itp"		# 
block_conf_file="confs/methanol.block.gro"	# building block of conf
input_conf_file="confs/methanol.input.gro"	# input conf for productive run

make_file=machine.dep/Makefile.hlrn
env_file=machine.dep/env.sh.hlrn
submit_file=machine.dep/auto.hlrn.sh
