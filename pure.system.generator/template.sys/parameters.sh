#!/bin/bash

base_conf=tools/gen.conf/methanol.gro
n_base_block="4 2 2"
number_density=33.286
cg_pot_dir=./tools/tf.template/
input_conf=./confs/04-02-02.gro
init_guess_INSERT_MOL_NAME_tf=./tools/tabletf_INSERT_MOL_NAME.xvg

# cal.vol.sh
cal_vol_nsteps=40000
cal_vol_dt=0.002
cal_vol_nstenergy=100
cal_vol_nstxtcout=200

# gen.tf.sh parameters
gmx_dt=0.001
gmx_nsteps=100000
gmx_nstenergy=50
gmx_nstxtcout=50
gmx_tau_t=1.0

ex_region_r=0.5
hy_region_r=2.75
tf_extension=0.05
tf_step=0.01
tf_spline_extension=0.1
tf_spline_step=0.42142857142857142857
tf_prefactor=0.039
INSERT_MOL_NAME_tf_prefactor=0.02
equi_time_discard=10

poten_INSERT_MOL_NAME_sigma=0.4

tf_iterations_max=20

# run.tf.sh parameters
#run_dir=./run
tf_file=tabletf.xvg
dt=0.002
nsteps=500000
nstxout=0
nstvout=0
nstenergy=100
nstxtcout=1000

