#!/bin/bash

source env.sh
source parameters.sh
source functions.sh

mylog=`pwd`/gen.traj.log
makelog=`pwd`/make.log
rm -f $mylog $makelog
cwd=`pwd`

# prepare dir
echo "# prepare dir"
if test ! -d $target_dir/tf; then
    echo "no dir $target_dir/tf, exit"
    exit
fi
if test ! -d $target_dir/tf/step_001; then
    echo "no dir $target_dir/tf/step_001, exit"
    exit
fi
cd $target_dir/tf
last_dir=`ls | grep step_ | tail -n 1`
cd $cwd
rm -rf dir.gen.traj
mkdir -p dir.gen.traj
cp $target_dir/tf/$last_dir/grompp.mdp  ./dir.gen.traj
cp $target_dir/tf/$last_dir/topol.top   ./dir.gen.traj
cp $target_dir/tf/$last_dir/confout.gro ./dir.gen.traj
cp $target_dir/tf/$last_dir/table*.xvg  ./dir.gen.traj
cp tops/*itp ./dir.gen.traj
cd dir.gen.traj

# prepare grompp.mdp
echo "# prepare grompp.mdp"
set_parameter_gen_traj_0 grompp.mdp

# prepare topol.top
echo "# prepare topol.top"
set_top_gen_traj topol.top

# prepare conf.gro
echo "# prepare conf.gro"
grep "CM" confout.gro > tmp.gro
num_lines=`wc -l tmp.gro | awk '{print $1}'`
echo "" > conf.gro
echo $num_lines >> conf.gro
cat tmp.gro >> conf.gro
tail -n 1 confout.gro >> conf.gro
rm -rf tmp.gro confout.gro

# prepare index file
echo "# prepare index file"
echo "a CMW" > command.tmp
echo "a CMC" >> command.tmp
echo "q" >> command.tmp
cat command.tmp  | make_ndx -f conf.gro &>> $mylog
rm -fr command.tmp

# run simulation 0
echo "# run simulation 0"
grompp -n index.ndx &>> $mylog
mdrun -v &>> $mylog

# reset init conf
echo "# reset init conf"
mv confout.gro conf.gro
grocleanit
set_parameter_gen_traj_1 grompp.mdp

# run simulation 1
echo "# run simulation 1"
grompp -n index.ndx &>> $mylog
mdrun -v &>> $mylog

cd $cwd

