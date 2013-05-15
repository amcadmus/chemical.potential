#!/bin/bash

n_base_block="4 2 2"
base_conf=tools/gen.conf/methanol.gro
input_conf=./confs/04-02-02.gro
init_guess_INSERT_CG_NAME_tf=./tabletf_INSERT_CG_NAME.xvg
# number_density=33.286		# the number density of spce.

# cal.vol.sh
cal_vol_nsteps=40000
cal_vol_dt=0.002
cal_vol_nstenergy=100
cal_vol_nstxtcout=200

# gen.tf.sh parameters
gmx_dt=0.001
gmx_nsteps=10000
gmx_nstenergy=50
gmx_nstxtcout=50
gmx_tau_t=1.0
gmx_epsilon_rf=INSERT_EPSILON_RF
gmx_rcut=0.9

ex_region_r=0.5
hy_region_r=2.75
tf_extension=0.05
tf_step=0.01
tf_spline_extension=0.1
tf_spline_step=0.42142857142857142857
INSERT_MOL_NAME_tf_prefactor=0.02
equi_time_discard=10

poten_INSERT_MOL_NAME_sigma=0.4

tf_iterations_max=20

# ipm parameters
ipm_dt=0.002
ipm_gen_traj_nsteps_0=100000
ipm_gen_traj_nsteps_1=1600000
ipm_C_nsteps=2000000
ipm_nstenergy=200
ipm_nstxtcout=200
ipm_tau_t=0.1

# run.tf.sh parameters
#run_dir=./run
tf_file=tabletf.xvg
dt=0.002
nsteps=500000
nstxout=0
nstvout=0
nstenergy=100
nstxtcout=1000

