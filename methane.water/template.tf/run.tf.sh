#!/bin/bash

source env.sh
source parameters.sh

mylog=`pwd`/run.tf.log
makelog=`pwd`/make.log
rm -f $mylog
rm -f $makelog
# if test ! -d $run_dir;
#     then echo "# make dir $run_dir"
#     mkdir -p $run_dir
# fi

if test ! -f $tf_file; then
    echo "no tf table file found, exit"
    exit
fi

# prepare conf.gro
echo "# prepare conf.gro"
## gen from base (default spc216.gro)
genconf -f $base_conf -o conf.gro -nbox $n_base_block &>> $mylog
## resize to right density
boxx=`tail conf.gro -n 1 | awk '{print $1}'`
boxy=`tail conf.gro -n 1 | awk '{print $2}'`
boxz=`tail conf.gro -n 1 | awk '{print $3}'`
natom=`head -n 2 conf.gro | tail -n 1`
nmol=`echo "$natom / 3" | bc`
now_density=`echo "$natom / 3 / ($boxx * $boxy * $boxz)" | bc -l`
scale=`echo "($now_density / $number_density)" | bc -l`
editconf -f conf.gro -o out.gro -scale $scale 1.0000 1.0000 &>> $mylog
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

## warm run
rm -fr warmup
cp -a tools/atom.template ./warmup
cd warmup
mv ../conf.gro .
sed "s/SOL.*/SOL $nmol/g" topol.top > tmp.top
mv -f tmp.top topol.top
seed=` date +%s`
sed -e "/^gen_seed/s/=.*/= $seed/g" grompp.mdp > tmp.mdp
mv -f tmp.mdp grompp.mdp
grompp &>> $mylog
mdrun -v &>> $mylog
rm -fr ../conf.gro
if test ! -f confout.gro; then
    echo "no file confout.gro, exit!"
    exit
fi
cp confout.gro ../conf.gro
cd ..
## add COM site
make -C tools/gen.conf/ clean &> $makelog
make -j4 -C tools/gen.conf/ &> $makelog
tools/gen.conf/stupid.add.com -f conf.gro -o out.gro &>> $mylog
mv -f out.gro conf.gro

# prepare grompp.mdp
echo "# prepare grompp.mdp"
rm -fr grompp.mdp
cp tools/tf.template/grompp.mdp .
half_boxx=`echo "$boxx/2.0" | bc -l`
half_boxy=`echo "$boxy/2.0" | bc -l`
half_boxz=`echo "$boxz/2.0" | bc -l`
sed -e "/^adress_ex_width/s/=.*/= $ex_region_r/g" grompp.mdp |\
sed -e "/^adress_hy_width/s/=.*/= $hy_region_r/g" |\
sed -e "/^dt/s/=.*/= $dt/g" |\
sed -e "/^nsteps/s/=.*/= $nsteps/g" |\
sed -e "/^nstxout/s/=.*/= $nstxout/g" |\
sed -e "/^nstvout/s/=.*/= $nstvout/g" |\
sed -e "/^nstxtcout/s/=.*/= $nstxtcout/g" |\
sed -e "/^nstenergy/s/=.*/= $nstenergy/g" |\
sed -e "/^adress_reference_coords/s/=.*/= $half_boxx $half_boxy $half_boxz/g" > grompp.mdp.tmp
mv -f grompp.mdp.tmp grompp.mdp

# prepare index file
echo "# prepare index file"
echo "a COM" > command.tmp
echo "name 3 CG" >> command.tmp
echo "a HW1 HW2 OW" >> command.tmp
echo "name 4 EX" >> command.tmp
echo "q" >> command.tmp
cat command.tmp  | make_ndx -f conf.gro &>> $mylog
rm -fr command.tmp

# prepare topol.top
echo "# prepare topol.top"
rm -fr topol.top
cp tools/tf.template/topol.top .
cp tools/tf.template/adress_spce.itp .
sed "s/SOL.*/SOL $nmol/g" topol.top > tmp.top
mv -f tmp.top topol.top

# prepare tables
cp tools/tf.template/table_CG_CG.xvg .
cp tools/tf.template/table.xvg .
mv -f $tf_file tabletf.xvg.tmptmptmp
mv -f tabletf.xvg.tmptmptmp tabletf.xvg

# run adress
grompp -n index.ndx &>> $mylog
mdrun -dd 2 2 2 -v &>> $mylog

