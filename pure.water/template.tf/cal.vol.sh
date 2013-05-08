#!/bin/bash

source env.sh
source parameters.sh
source functions.sh

MeOH_ratio=0.0

mylog=`pwd`/cal.vol.log
makelog=`pwd`/make.log
rm -f $mylog
make -C tools/gen.conf -j8
dir_name=vol.`printf %.3f $MeOH_ratio`

if test -d $dir_name; then
    echo "# existing dir $dir_name, move"
    mv $dir_name $dir_name.`date +%s`
fi

# prepare conf.gro
echo "# prepare conf.gro"
## gen from base (default spc216.gro)
echo '## gen from base (default spc216.gro)'
genconf -f $base_conf -o conf.gro -nbox $n_base_block -shuffle &>> $mylog
## resize to right density
echo '## resize to right density'
boxx=`tail conf.gro -n 1 | awk '{print $1}'`
boxy=`tail conf.gro -n 1 | awk '{print $2}'`
boxz=`tail conf.gro -n 1 | awk '{print $3}'`
natom=`head -n 2 conf.gro | tail -n 1`
nmol=`echo "$natom / 3" | bc`
# now_density=`echo "$natom / 3 / ($boxx * $boxy * $boxz)" | bc -l`
# scale=`echo "($now_density / $number_density)" | bc -l`
# editconf -f conf.gro -o out.gro -scale $scale 1 1 &>> $mylog
# mv -f out.gro conf.gro
# boxx=`tail conf.gro -n 1 | awk '{print $1}'`
# boxy=`tail conf.gro -n 1 | awk '{print $2}'`
# boxz=`tail conf.gro -n 1 | awk '{print $3}'`

# newboxx=`printf "%.1f" $boxx`
# scalex=`echo "$newboxx / $boxx" | bc -l`
# scaleyz=`echo "sqrt(1./$scalex)" | bc -l`
# editconf -f conf.gro -o out.gro -scale $scalex $scaleyz $scaleyz &>> $mylog
# mv -f out.gro conf.gro
# boxx=`tail conf.gro -n 1 | awk '{print $1}'`
# boxy=`tail conf.gro -n 1 | awk '{print $2}'`
# boxz=`tail conf.gro -n 1 | awk '{print $3}'`

## replace water by MeOH
echo '## replace water by MeOH'
nMeOH=`./tools/gen.conf/change.MeOH -f conf.gro -o out.gro -r $MeOH_ratio | grep "nmol MeOH" | awk '{print $5}'`
nwat=`echo "$nmol - $nMeOH" | bc`
mv -f out.gro conf.gro

## warm run
echo '## warm run'
rm -fr $dir_name
cp -a tools/atom.template ./$dir_name
cd $dir_name
mv ../conf.gro .
sed "s/^SOL.*/SOL $nwat/g" topol.top |
sed "s/^Methanol.*/Methanol $nMeOH/g" > tmp.top
mv -f tmp.top topol.top
cp ../parameters.sh .

cal_vol_set_parameter_warm grompp.mdp
grompp &>> $mylog
mdrun -v &>> $mylog

## production run
echo '## production run'
mv -f confout.gro conf.gro
cal_vol_set_parameter grompp.mdp
grompp &>> $mylog
mdrun -v &>> $mylog

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

editconf -f confout.gro -o out.gro -scale $scalex $scaley $scalez &>> $mylog

cd ..
