#!/bin/bash

source parameters.sh

function do_insertion () {
    filename=$1
    sed -e "s/INSERT_FORCE_FIELD/$force_field/g" $filename |\
    sed -e "s/INSERT_EX_NAME/$ex_charge_group_name/g" |\
    sed -e "s/INSERT_CG_NAME/$cg_charge_group_name/g" |\
    sed -e "s/INSERT_ATOM_ITP/$atom_itp/g" |\
    sed -e "s/INSERT_ADRESS_ITP/$adress_itp/g" |\
    sed -e "s/INSERT_MOL_NAME/$mol_name/g" > tmp.tmp.tmp
    mv -f tmp.tmp.tmp $filename
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


echo "# gnereating system: $target_dir"
cp -a template.sys $target_dir

echo "# prepare atom template"
cp -a $itp_file			$target_dir/tools/atom.template/
cp -a tops/topol.top		$target_dir/tools/atom.template/
do_insertion			$target_dir/tools/atom.template/topol.top

echo "# copy block conf"
cp -a $block_conf_file		$target_dir/block.gro

echo "# prepare gen.wca"
cp -a $make_file		$target_dir/tools/gen.wca/Makefile

echo "# prepare gen.conf"
cp -a $make_file		$target_dir/tools/gen.conf/Makefile

echo "# prepare tf template"
cp -a $adress_itp_file		$target_dir/tools/tf.template/
cp -a tops/topol.adress.top	$target_dir/tools/tf.template/topol.top
do_insertion			$target_dir/tools/tf.template/topol.top
do_insertion			$target_dir/tools/tf.template/grompp.mdp
do_insertion			$target_dir/tools/tf.template/settings.xml

echo "# prepare sh scripts"
do_insertion			$target_dir/gen.tf.sh
do_insertion			$target_dir/parameters.sh

