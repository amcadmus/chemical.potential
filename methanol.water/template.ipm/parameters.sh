#!/bin/bash

MeOH_ratio=0.1
target_dir=../tf.vol.0.010.short.3
conf_dir=../cal.vol

# gen.tf.sh parameters
gen_traj_nsteps_0=100000
gen_traj_nsteps_1=1600000

gmx_dt=0.002
gmx_taut=0.5
gmx_nstenergy=200
gmx_nstxtcout=200

ipm_C_nsteps=2000000
ipm_W_nsteps=2000000


