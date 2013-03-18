#!/bin/bash

source env.sh
source parameters.sh
source functions.sh

mylog=`pwd`/ipm.c.log
makelog=`pwd`/make.log
rm -f $mylog $makelog
cwd=`pwd`

# ##################################################
# particle insertion c
# ##################################################
echo "# particle insertion c"

# prepare dir
echo "# prepare dir"
rm -fr dir.ipm.c
mkdir -p dir.ipm.c
cp dir.gen.traj/confout.gro	dir.ipm.c/conf.gro
cp dir.gen.traj/*itp		dir.ipm.c/
cp dir.gen.traj/table*xvg	dir.ipm.c/
cp dir.gen.traj/grompp.mdp	dir.ipm.c/
cp dir.gen.traj/topol.top	dir.ipm.c/
cd dir.ipm.c/
ln -s ../dir.gen.traj/traj.xtc .

# prepare grompp.mdp
echo "# prepare grompp.mdp"
set_parameter_ipm_C grompp.mdp

# prepare conf.gro
echo "# prepare conf.gro"
num_lines=`grep CM conf.gro | wc -l | awk '{print $1}'`
head -n 1 conf.gro > out.gro
echo $(($num_lines+1)) >> out.gro
grep CM conf.gro >> out.gro
grep CM conf.gro | tail -n 1 >> out.gro
tail -n 1 conf.gro >> out.gro

mv -f out.gro conf.gro

# prepare index file
echo "# prepare index file"
echo "a CMW" > command.tmp
echo "a CMC" >> command.tmp
echo "q" >> command.tmp
cat command.tmp  | make_ndx -f conf.gro &>> $mylog
rm -fr command.tmp

# prepare topol.top
echo "# prepare topol.top"
echo "MeOH 1" >> topol.top

# run ipm
echo "# run ipm"
grompp -n index.ndx &>> $mylog
mdrun -rerun traj.xtc &>> $mylog

