#!/bin/bash

mol1_name=SOL
mol2_name=MeOH
cg1_charge_group_name=CMW
cg2_charge_group_name=CMC
ex1_charge_group_name=EXW
ex2_charge_group_name=EXC

force_field="gromos53a6"

mdrun_command="mpiexec mdrun_mpi"
mdrun_options="-v"
epsilon_rf=60					# 60 is for spc water..

atom1_itp_file="tops/spc.itp"			# 
adress1_itp_file="tops/spc.adress.itp"		# the COM top should be included!!
cg1_itp_file="tops/spc.cg.itp"			# 

atom2_itp_file="tops/methanol.itp"		# 
adress2_itp_file="tops/methanol.adress.itp"	# the COM top should be included!!
cg2_itp_file="tops/methanol.cg.itp"		# 

block_conf_file="confs/*.gro"		# building block of conf
input_conf_file="confs/input*.gro"		# input conf for productive run

make_file=machine.dep/Makefile.hlrn
env_file=machine.dep/env.sh.hlrn
submit_file=machine.dep/auto.hlrn.sh
