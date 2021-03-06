#!/bin/bash

function set_parameter () {
    file=$1
    seed=`date +%s`

    # adress setup
    adress_type="region"
    box_x=`tail $init_ex_conf -n 1 | awk '{print $1}'`
    box_y=`tail $init_ex_conf -n 1 | awk '{print $2}'`
    box_z=`tail $init_ex_conf -n 1 | awk '{print $3}'`
    adress_ex_width=$ex_region_size
    adress_hy_width=$hy_region_size
    box_hx=`echo "$box_x/2.0" | bc -l`
    box_hy=`echo "$box_y/2.0" | bc -l`
    box_hz=`echo "$box_z/2.0" | bc -l`
    adress_reference_coords="$box_hx $box_hy $box_hz"
    
    sed -e "/^nsteps /s/=.*/= $nsteps/g" $file |\
    sed -e "/^nstxout /s/=.*/= $nstxout/g" |\
    sed -e "/^nstvout /s/=.*/= $nstvout/g" |\
    sed -e "/^nstenergy /s/=.*/= $nstenergy/g" |\
    sed -e "/^nstxtcout /s/=.*/= $nstxtcout/g" |\
    sed -e "/^userreal1 /s/=.*/= $T1/g" |\
    sed -e "/^userreal2 /s/=.*/= $T2/g" |\
    sed -e "/^userreal3 /s/=.*/= $thick/g" |\
    sed -e "/^userreal4 /s/=.*/= $tau_t/g" |\
    sed -e "/^accelerate /s/=.*/= 0.0 0.0 $accelerate/g" |\
    sed -e "/^dt /s/=.*/= $dt/g" > tmp
    mv -f tmp $file
}

function cal_vol_set_parameter () {
    file=$1
    seed=`date +%s`

    sed -e "/^nsteps /s/=.*/= $cal_vol_nsteps/g" $file |\
    sed -e "/^nstenergy /s/=.*/= $cal_vol_nstenergy/g" |\
    sed -e "/^nstcomm /s/=.*/= $cal_vol_nstenergy/g" |\
    sed -e "/^nstxtcout /s/=.*/= $cal_vol_nstxtcout/g" |\
    sed -e "/^adress /s/=.*/= no/g" |\
    sed -e "/^Pcoupl /s/=.*/= Parrinello-Rahman/g" |\
    sed -e "/^gen_vel /s/=.*/= no/g" |\
    sed -e "/^epsilon_rf /s/=.*/= $gmx_epsilon_rf/g" |\
    sed -e "/^dt /s/=.*/= $cal_vol_dt/g" > tmp
    mv -f tmp $file
#    sed -e "/^Pcoupl /s/=.*/= Berendsen/g" |\
}

function cal_vol_set_parameter_warm () {
    file=$1
    seed=`date +%s`

    sed -e "/^nsteps /s/=.*/= 200000/g" $file |\
    sed -e "/^nstenergy /s/=.*/= $cal_vol_nstenergy/g" |\
    sed -e "/^nstcomm /s/=.*/= $cal_vol_nstenergy/g" |\
    sed -e "/^nstxtcout /s/=.*/= $cal_vol_nstxtcout/g" |\
    sed -e "/^adress /s/=.*/= no/g" |\
    sed -e "/^Pcoupl /s/=.*/= berendsen/g" |\
    sed -e "/^gen_vel /s/=.*/= no/g" |\
    sed -e "/^epsilon_rf /s/=.*/= $gmx_epsilon_rf/g" |\
    sed -e "/^dt /s/=.*/= 0.0002/g" > tmp
    mv -f tmp $file
#    sed -e "/^Pcoupl /s/=.*/= Berendsen/g" |\
}

function post_process () {
    output_dir=$1
    rm -fr $output_dir
    mkdir  $output_dir
    cp conf.gro		$output_dir/
    cp confout.gro	$output_dir/
    cp traj.trr		$output_dir/
    cp topol.top	$output_dir/
    cp grompp.mdp	$output_dir/
    cp *itp		$output_dir/
    cp *log		$output_dir/
}

