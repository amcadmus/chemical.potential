#!/bin/bash

source env.sh
source parameters.sh
source functions.sh

mylog=`pwd`/cal.vol.log
makelog=`pwd`/make.log
rm -f $mylog
make -C tools/gen.conf -j8

# prepare conf.gro
echo "# prepare conf.gro"
## gen from base (default spc216.gro)
genconf -f $base_conf -o conf.gro -nbox $n_base_block -shuffle &>> $mylog
## resize to right density
boxx=`tail conf.gro -n 1 | awk '{print $1}'`
boxy=`tail conf.gro -n 1 | awk '{print $2}'`
boxz=`tail conf.gro -n 1 | awk '{print $3}'`
natom=`head -n 2 conf.gro | tail -n 1`
nmol=`echo "$natom / 3" | bc`
now_density=`echo "$natom / 3 / ($boxx * $boxy * $boxz)" | bc -l`
scale=`echo "($now_density / $number_density)" | bc -l`
editconf -f conf.gro -o out.gro -scale $scale 1 1 &>> $mylog
mv -f out.gro conf.gro
boxx=`tail conf.gro -n 1 | awk '{print $1}'`
boxy=`tail conf.gro -n 1 | awk '{print $2}'`
boxz=`tail conf.gro -n 1 | awk '{print $3}'`

newboxx=`printf "%.1f" $boxx`
scalex=`echo "$newboxx / $boxx" | bc -l`
scaleyz=`echo "sqrt(1./$scalex)" | bc -l`
editconf -f conf.gro -o out.gro -scale $scalex $scaleyz $scaleyz &>> $mylog
mv -f out.gro conf.gro
boxx=`tail conf.gro -n 1 | awk '{print $1}'`
boxy=`tail conf.gro -n 1 | awk '{print $2}'`
boxz=`tail conf.gro -n 1 | awk '{print $3}'`

## replace water by ch4
nch4=`./tools/gen.conf/change.ch4 -f conf.gro -o out.gro -r $ch4_ratio | grep "nmol ch4" | awk '{print $5}'`
nwat=`echo "$nmol - $nch4" | bc`
mv -f out.gro conf.gro

## warm run
rm -fr warmup
cp -a tools/atom.template ./warmup
cd warmup
mv ../conf.gro .
sed "s/SOL.*/SOL $nwat/g" topol.top |
sed "s/Methane.*/Methane $nch4/g" > tmp.top
mv -f tmp.top topol.top
cal_vol_set_parameter grompp.mdp

grompp &>> $mylog
mdrun -v &>> $mylog

rm -fr ../conf.gro
if test ! -f confout.gro; then
    echo "no file confout.gro, exit!"
    exit
fi
cp confout.gro ../conf.gro
cd ..
