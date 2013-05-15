#!/bin/bash

source parameters.sh

function do_insertion () {
    filename=$1
    sed -e "s/INSERT_FORCE_FIELD/$force_field/g" $filename |\
    sed -e "s/INSERT_EX_NAME/$ex_charge_group_name/g" |\
    sed -e "s/INSERT_CG_NAME/$cg_charge_group_name/g" |\
    sed -e "s/INSERT_ATOM_ITP/$atom_itp/g" |\
    sed -e "s/INSERT_ADRESS_ITP/$adress_itp/g" |\
    sed -e "s/INSERT_CG_ITP/$cg_itp/g" |\
    sed -e "s/INSERT_MDRUN_COMMAND/$mdrun_command/g" |\
    sed -e "s/INSERT_MDRUN_OPTIONS/$mdrun_options/g" |\
    sed -e "s/INSERT_EPSILON_RF/$epsilon_rf/g" |\
    sed -e "s/INSERT_MOL_NAME/$mol_name/g" > tmp.tmp.tmp
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

target_dir=pure.$mol_name
if test -d $target_dir; then
    echo "# backup existing $target_dir"
    mv $target_dir $target_dir.`date +%s`
fi
num_slice=`echo $itp_file | fgrep -o / | wc -l`
num_slice=$(($num_slice+1))
atom_itp=`echo $itp_file | cut -f $num_slice -d'/'`
num_slice=`echo $adress_itp_file | fgrep -o / | wc -l`
num_slice=$(($num_slice+1))
adress_itp=`echo $adress_itp_file | cut -f $num_slice -d'/'`
num_slice=`echo $cg_itp_file | fgrep -o / | wc -l`
num_slice=$(($num_slice+1))
cg_itp=`echo $cg_itp_file | cut -f $num_slice -d'/'`


echo "# gnereating system: $target_dir"
cp -a template.sys		$target_dir
do_copy_file $env_file		$target_dir/env.sh
do_copy_file $submit_file	$target_dir/

echo "# prepare atom template"
do_copy_file $itp_file		$target_dir/tools/atom.template/
do_copy_file tops/topol.top	$target_dir/tools/atom.template/
do_insertion			$target_dir/tools/atom.template/topol.top

echo "# copy block conf"
test ! -d $target_dir/confs/	&& rm -f $target_dir/confs && mkdir -p $target_dir/confs/
do_copy_file $block_conf_file	$target_dir/confs/block.gro

echo "# copy simul conf"
do_copy_file $input_conf_file	$target_dir/confs/input.gro

echo "# prepare gen.wca"
do_copy_file $make_file		$target_dir/tools/gen.wca/Makefile

echo "# prepare gen.conf"
do_copy_file $make_file		$target_dir/tools/gen.conf/Makefile

echo "# prepare tf template"
do_copy_file $itp_file		$target_dir/tools/tf.template/
do_copy_file $adress_itp_file	$target_dir/tools/tf.template/
do_copy_file $cg_itp_file	$target_dir/tools/tf.template/
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
do_insertion			$target_dir/ipm.c.sh
chmod a+x			$target_dir/ipm.c.sh
do_insertion			$target_dir/parameters.sh
sed -e "s/^input_conf=.*/input_conf=confs\/input.gro/g" $target_dir/parameters.sh | \
sed -e "s/^base_conf=.*/base_conf=confs\/block.gro/g" > tmp.tmp.tmp
mv -f tmp.tmp.tmp $target_dir/parameters.sh
