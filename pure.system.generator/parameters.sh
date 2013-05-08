#!/bin/bash

mol_name=MeOH
cg_charge_group_name=CMC
ex_charge_group_name=EXC
force_field="gromos53a6"

itp_file="tops/methanol.itp"			# 
adress_itp_file="tops/methanol.adress.itp"	# the COM top should be included!!
block_conf_file="confs/methanol.gro"		# building block of conf
input_conf_file="confs/methanol.gro"		# input conf for productive run
make_file=makefiles/Makefile.fu
