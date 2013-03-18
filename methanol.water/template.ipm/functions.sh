#!/bin/bash

function set_top_gen_traj () {
    file=$1
    sed -e "/^CM/s/V/A/g" $file > tmp
    mv -f tmp $file
}

function set_parameter_gen_traj_0 () {
    file=$1
    seed=`date +%s`
    sed -e "/^nsteps /s/=.*/= $gen_traj_nsteps_0/g" $file |\
    sed -e "/^nstenergy /s/=.*/= $gmx_nstenergy/g" |\
    sed -e "/^nstxtcout /s/=.*/= $gmx_nstxtcout/g" |\
    sed -e "/^coulombtype /s/=.*/= user/g" |\
    sed -e "/^tau_t /s/=.*/= $gmx_taut/g" |\
    sed -e "/^adress/s/=.*/= no/g" |\
    sed -e "/^energygrps /s/=.*/= CMW CMC/g" |\
    sed -e "/^dt /s/=.*/= $gmx_dt/g" > tmp
    grep -v adress_ tmp > $file
    rm tmp -f
}

function set_parameter_gen_traj_1 () {
    file=$1
    seed=`date +%s`
    sed -e "/^nsteps /s/=.*/= $gen_traj_nsteps_1/g" $file |\
    sed -e "/^nstenergy /s/=.*/= $gmx_nstenergy/g" |\
    sed -e "/^nstxtcout /s/=.*/= $gmx_nstxtcout/g" |\
    sed -e "/^coulombtype /s/=.*/= user/g" |\
    sed -e "/^tau_t /s/=.*/= $gmx_taut/g" |\
    sed -e "/^adress/s/=.*/= no/g" |\
    sed -e "/^energygrps /s/=.*/= CMW CMC/g" |\
    sed -e "/^dt /s/=.*/= $gmx_dt/g" > tmp
    grep -v adress_ tmp > $file
    rm tmp -f
}

function set_parameter_ipm_C () {    
    file=$1
    sed -e "/^nsteps /s/=.*/= $ipm_C_nsteps/g" $file |\
    sed -e "/^integrator /s/=.*/= tpi/g" |\
    sed -e "/^nstlist /s/=.*/= 1/g" > tmp
    mv -f tmp $file
}


function set_parameter_ipm_W () {    
    file=$1
    sed -e "/^nsteps /s/=.*/= $ipm_W_nsteps/g" $file |\
    sed -e "/^integrator /s/=.*/= tpi/g" |\
    sed -e "/^nstlist /s/=.*/= 1/g" > tmp
    mv -f tmp $file
}


