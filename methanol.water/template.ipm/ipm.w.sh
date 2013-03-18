#!/bin/bash

source env.sh
source parameters.sh
source functions.sh

mylog=`pwd`/ipm.w.log
makelog=`pwd`/make.log
rm -f $mylog $makelog
cwd=`pwd`

# ##################################################
# particle insertion w
# ##################################################
echo "# particle insertion w"

# prepare dir
echo "# prepare dir"
rm -fr dir.ipm.w
mkdir -p dir.ipm.w
cp dir.gen.traj/confout.gro	dir.ipm.w/conf.gro
cp dir.gen.traj/*itp		dir.ipm.w/
cp dir.gen.traj/table*xvg	dir.ipm.w/
cp dir.gen.traj/grompp.mdp	dir.ipm.w/
cp dir.gen.traj/topol.top	dir.ipm.w/
cd dir.ipm.w/
ln -s ../dir.gen.traj/traj.xtc .

# prepare grompp.mdp
echo "# prepare grompp.mdp"
set_parameter_ipm_W grompp.mdp

# prepare conf.gro
echo "# prepare conf.gro"
num_lines=`grep CM conf.gro | wc -l | awk '{print $1}'`
head -n 1 conf.gro > out.gro
echo $(($num_lines+1)) >> out.gro
grep CM conf.gro >> out.gro
grep CM conf.gro | head -n 1 >> out.gro
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
echo "SOL 1" >> topol.top 

# run ipm
echo "# run ipm"
grompp -n index.ndx &>> $mylog
mdrun -rerun traj.xtc &>> $mylog
