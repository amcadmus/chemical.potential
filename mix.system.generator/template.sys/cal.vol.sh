#!/bin/bash

source env.sh
source parameters.sh
source functions.sh

mylog=`pwd`/cal.vol.log
makelog=`pwd`/make.log
rm -f $mylog
make -C tools/gen.conf clean &> $makelog
make -C tools/gen.conf -j8 &> $makelog
dir_name=run

if test -d $dir_name; then
    echo "# existing dir $dir_name, move"
    mv $dir_name $dir_name.`date +%s`
fi

# prepare conf.gro
echo "# prepare conf.gro"
echo "## gen from base conf: $base_conf"
genconf -f $base_conf -o conf.gro -nbox $n_base_block -shuffle &> $mylog
echo '## get num mol'
nINSERT_MOL1_NAME=`./tools/gen.conf/nresd -f conf.gro | grep INSERT_MOL1_NAME | awk '{print $2}'` 
nINSERT_MOL2_NAME=`./tools/gen.conf/nresd -f conf.gro | grep INSERT_MOL2_NAME | awk '{print $2}'` 

## warm run
echo '## warm run'
rm -fr $dir_name
cp -a tools/atom.template ./$dir_name
cd $dir_name
mv ../conf.gro .
sed "s/^INSERT_MOL1_NAME.*/INSERT_MOL1_NAME $nINSERT_MOL1_NAME/g" topol.top |\
sed "s/^INSERT_MOL2_NAME.*/INSERT_MOL2_NAME $nINSERT_MOL2_NAME/g" > tmp.top
mv -f tmp.top topol.top
cp ../parameters.sh .

cal_vol_set_parameter_warm grompp.mdp
grompp &> $mylog
INSERT_MDRUN_COMMAND INSERT_MDRUN_OPTIONS 

## production run
echo '## production run'
mv -f confout.gro conf.gro
cal_vol_set_parameter grompp.mdp
grompp &> $mylog
INSERT_MDRUN_COMMAND INSERT_MDRUN_OPTIONS 

## rescale box
echo '## rescale box'
cal_vol_time=`echo "$cal_vol_dt * $cal_vol_nsteps" | bc -l`
cal_vol_btime=`echo "$cal_vol_time / 2.0" | bc -l`
echo 11 12 13 | g_energy -b $cal_vol_btime > energy.out
newboxx=`grep Box-X energy.out | awk '{print $2}'`
newboxy=`grep Box-Y energy.out | awk '{print $2}'`
newboxz=`grep Box-Z energy.out | awk '{print $2}'`
boxx=`tail confout.gro -n 1 | awk '{print $1}'`
boxy=`tail confout.gro -n 1 | awk '{print $2}'`
boxz=`tail confout.gro -n 1 | awk '{print $3}'`
scalex=`echo "$newboxx / $boxx" | bc -l`
scaley=`echo "$newboxy / $boxy" | bc -l`
scalez=`echo "$newboxz / $boxz" | bc -l`

editconf -f confout.gro -o out.gro -scale $scalex $scaley $scalez &> $mylog

cd ..
