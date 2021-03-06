#!/bin/bash

source parameters.sh

function prep_itp () {
    filename=$1
    cgname=$2
    sed -e "s/PREP_INSERT_CG_NAME/$cgname/g" $filename > tmp.tmp.tmp
    mv -f tmp.tmp.tmp $filename
}

function do_insertion () {
    filename=$1
    sed -e "s/INSERT_FORCE_FIELD/$force_field/g" $filename |\
    sed -e "s/INSERT_EX1_NAME/$ex1_charge_group_name/g" |\
    sed -e "s/INSERT_EX2_NAME/$ex2_charge_group_name/g" |\
    sed -e "s/INSERT_CG1_NAME/$cg1_charge_group_name/g" |\
    sed -e "s/INSERT_CG2_NAME/$cg2_charge_group_name/g" |\
    sed -e "s/INSERT_MOL1_NAME/$mol1_name/g" |\
    sed -e "s/INSERT_MOL2_NAME/$mol2_name/g" |\
    sed -e "s/INSERT_ATOM1_ITP/$atom1_itp/g" |\
    sed -e "s/INSERT_ATOM2_ITP/$atom2_itp/g" |\
    sed -e "s/INSERT_ADRESS1_ITP/$adress1_itp/g" |\
    sed -e "s/INSERT_ADRESS2_ITP/$adress2_itp/g" |\
    sed -e "s/INSERT_CG1_ITP/$cg1_itp/g" |\
    sed -e "s/INSERT_CG2_ITP/$cg2_itp/g" |\
    sed -e "s/INSERT_MDRUN_COMMAND/$mdrun_command/g" |\
    sed -e "s/INSERT_MDRUN_OPTIONS/$mdrun_options/g" |\
    sed -e "s/INSERT_EPSILON_RF/$epsilon_rf/g" > tmp.tmp.tmp
    mv -f tmp.tmp.tmp $filename
}

function do_copy_file () {
    sfile=$1
    dfile=$2
    if test ! -f $sfile; then
	echo "# no file $sfile"
	exit
    fi
    cp -L $sfile $dfile
}

target_dir=mixed.$mol1_name.$mol2_name
if test -d $target_dir; then
    echo "# backup existing $target_dir"
    mv $target_dir $target_dir.`date +%s`
fi

num_slice=`echo $atom1_itp_file | fgrep -o / | wc -l`
num_slice=$(($num_slice+1))
atom1_itp=`echo $atom1_itp_file | cut -f $num_slice -d'/'`
num_slice=`echo $adress1_itp_file | fgrep -o / | wc -l`
num_slice=$(($num_slice+1))
adress1_itp=`echo $adress1_itp_file | cut -f $num_slice -d'/'`
num_slice=`echo $cg1_itp_file | fgrep -o / | wc -l`
num_slice=$(($num_slice+1))
cg1_itp=`echo $cg1_itp_file | cut -f $num_slice -d'/'`

num_slice=`echo $atom2_itp_file | fgrep -o / | wc -l`
num_slice=$(($num_slice+1))
atom2_itp=`echo $atom2_itp_file | cut -f $num_slice -d'/'`
num_slice=`echo $adress2_itp_file | fgrep -o / | wc -l`
num_slice=$(($num_slice+1))
adress2_itp=`echo $adress2_itp_file | cut -f $num_slice -d'/'`
num_slice=`echo $cg2_itp_file | fgrep -o / | wc -l`
num_slice=$(($num_slice+1))
cg2_itp=`echo $cg2_itp_file | cut -f $num_slice -d'/'`

echo "# gnereating system: $target_dir"
cp -a template.sys		$target_dir
do_copy_file $env_file		$target_dir/env.sh
do_copy_file $submit_file	$target_dir/

echo "# prepare atom template"
do_copy_file $atom1_itp_file	$target_dir/tools/atom.template/
do_copy_file $atom2_itp_file	$target_dir/tools/atom.template/
do_copy_file tops/topol.top	$target_dir/tools/atom.template/
do_insertion			$target_dir/tools/atom.template/topol.top

echo "# copy block conf"
test ! -d $target_dir/confs/	&& rm -f $target_dir/confs && mkdir -p $target_dir/confs/
cp $block_conf_file		$target_dir/confs/

echo "# copy simul conf"
#cp $input_conf_file		$target_dir/confs/

echo "# prepare gen.wca"
do_copy_file $make_file		$target_dir/tools/gen.wca/Makefile

echo "# prepare gen.conf"
do_copy_file $make_file		$target_dir/tools/gen.conf/Makefile

echo "# prepare tf template"
do_copy_file $atom1_itp_file	$target_dir/tools/tf.template/
do_copy_file $atom2_itp_file	$target_dir/tools/tf.template/
do_copy_file $adress1_itp_file	$target_dir/tools/tf.template/
do_copy_file $adress2_itp_file	$target_dir/tools/tf.template/
do_copy_file $cg1_itp_file	$target_dir/tools/tf.template/
do_copy_file $cg2_itp_file	$target_dir/tools/tf.template/
prep_itp			$target_dir/tools/tf.template/$adress1_itp INSERT_CG1_NAME
prep_itp			$target_dir/tools/tf.template/$adress2_itp INSERT_CG2_NAME
prep_itp			$target_dir/tools/tf.template/$cg1_itp INSERT_CG1_NAME
prep_itp			$target_dir/tools/tf.template/$cg2_itp INSERT_CG2_NAME
do_insertion			$target_dir/tools/tf.template/$adress1_itp
do_insertion			$target_dir/tools/tf.template/$adress2_itp
do_insertion			$target_dir/tools/tf.template/$cg1_itp
do_insertion			$target_dir/tools/tf.template/$cg2_itp
do_copy_file tops/topol.adress.top	$target_dir/tools/tf.template/topol.top
do_insertion			$target_dir/tools/tf.template/topol.top
do_copy_file tops/topol.cg.top	$target_dir/tools/tf.template/topol.cg.top
do_insertion			$target_dir/tools/tf.template/topol.cg.top
do_copy_file tops/topol.top	$target_dir/tools/tf.template/topol.atom.top
do_insertion			$target_dir/tools/tf.template/topol.atom.top
do_insertion			$target_dir/tools/tf.template/grompp.mdp
do_insertion			$target_dir/tools/tf.template/settings.xml

echo "# prepare sh scripts"
do_insertion			$target_dir/gen.tf.sh
chmod a+x			$target_dir/gen.tf.sh
do_insertion			$target_dir/cal.vol.sh
chmod a+x			$target_dir/cal.vol.sh
do_insertion			$target_dir/ipm.traj.sh
chmod a+x			$target_dir/ipm.traj.sh
do_insertion			$target_dir/ipm.cg1.sh
chmod a+x			$target_dir/ipm.cg1.sh
do_insertion			$target_dir/ipm.cg2.sh
chmod a+x			$target_dir/ipm.cg2.sh
do_insertion			$target_dir/parameters.sh
sed -e "s/^input_conf=.*/input_conf=confs\/input.gro/g" $target_dir/parameters.sh | \
sed -e "s/^base_conf=.*/base_conf=confs\/block.gro/g" > tmp.tmp.tmp
mv -f tmp.tmp.tmp $target_dir/parameters.sh
