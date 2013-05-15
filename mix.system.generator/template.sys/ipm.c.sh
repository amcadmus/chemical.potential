#!/bin/bash

source env.sh
source parameters.sh
source functions.sh

mylog=`pwd`/ipm.c.log
makelog=`pwd`/make.log
rm -f $mylog $makelog
cwd=`pwd`

function set_parameter_ipm_C () {
    file=$1
    sed -e "/^nsteps /s/=.*/= $ipm_C_nsteps/g" $file |\
    sed -e "/^integrator /s/=.*/= tpi/g" |\
    sed -e "/^nstlist /s/=.*/= 1/g" > tmp
    mv -f tmp $file
}

# ##################################################
# particle insertion c
# ##################################################
echo "# particle insertion c"

# prepare dir
echo "# prepare dir"
rm -fr ipm.c
mkdir -p ipm.c
cp ipm.traj/confout.gro	ipm.c/conf.gro
cp ipm.traj/*itp	ipm.c/
cp ipm.traj/table*xvg	ipm.c/
cp ipm.traj/grompp.mdp	ipm.c/
cp ipm.traj/topol.top	ipm.c/
cd ipm.c/
ln -s ../ipm.traj/traj.xtc .

# prepare grompp.mdp
echo "# prepare grompp.mdp"
set_parameter_ipm_C grompp.mdp

# prepare conf.gro
echo "# prepare conf.gro"
num_lines=`grep INSERT_CG_NAME conf.gro | wc -l | awk '{print $1}'`
head -n 1 conf.gro > out.gro
echo $(($num_lines+1)) >> out.gro
grep INSERT_CG_NAME conf.gro >> out.gro
grep INSERT_CG_NAME conf.gro | tail -n 1 >> out.gro
tail -n 1 conf.gro >> out.gro

mv -f out.gro conf.gro

# prepare index file
echo "# prepare index file"
echo "a INSERT_CG_NAME" > command.tmp
echo "q" >> command.tmp
cat command.tmp  | make_ndx -f conf.gro &> $mylog
rm -fr command.tmp

# prepare topol.top
echo "# prepare topol.top"
echo "INSERT_MOL_NAME 1" >> topol.top

# run ipm
echo "# run ipm"
grompp -n index.ndx &> $mylog
INSERT_MDRUN_COMMAND -rerun traj.xtc &> $mylog

