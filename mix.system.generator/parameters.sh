#!/bin/bash

mol1_name=MeOH
mol2_name=Meth
cg1_charge_group_name=CMW
cg2_charge_group_name=CMC
ex1_charge_group_name=EXW
ex2_charge_group_name=EXC

force_field="gromos53a6"

mdrun_command="mpiexec mdrun_mpi"
mdrun_options="-v"
epsilon_rf=19					# 60 is for spc water..

atom1_itp_file="tops/methanol.itp"			# 
adress1_itp_file="tops/methanol.adress.itp"		# the COM top should be included!!
cg1_itp_file="tops/methanol.cg.itp"			# 

atom2_itp_file="tops/methane.itp"		# 
adress2_itp_file="tops/methane.adress.itp"	# the COM top should be included!!
cg2_itp_file="tops/methane.cg.itp"		# 

block_conf_file="confs/*.gro"		# building block of conf
input_conf_file="confs/input*.gro"		# input conf for productive run

make_file=machine.dep/Makefile.hlrn
env_file=machine.dep/env.sh.hlrn
submit_file=machine.dep/auto.hlrn.sh
