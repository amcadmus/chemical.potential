#!/bin/bash

base_conf=tools/gen.conf/spc216.gro
n_base_block="4 2 2"
number_density=33.286
ch4_ratio=0.01
cg_pot_dir=./tools/tf.template/
conf_dir=../cal.vol
init_guess_SOL_tf=./tools/tabletf_SOL.xvg
init_guess_Meht_tf=./tools/tabletf_Meth.xvg

# cal.vol.sh
cal_vol_nsteps=4000000
cal_vol_dt=0.002
cal_vol_nstenergy=100
cal_vol_nstxtcout=200

# gen.tf.sh parameters
gmx_nsteps=16000000
gmx_nstenergy=200
gmx_nstxtcout=1000

ex_region_r=0.5
hy_region_r=2.75
tf_extension=0.05
tf_step=0.01
tf_spline_extension=0.1
tf_spline_step=0.42142857142857142857
tf_prefactor=0.039

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

