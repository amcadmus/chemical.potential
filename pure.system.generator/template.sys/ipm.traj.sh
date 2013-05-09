#!/bin/bash

source env.sh
source parameters.sh
source functions.sh

mylog=`pwd`/ipm.traj.log
makelog=`pwd`/make.log
rm -f $mylog $makelog
make -C ./tools/gen.conf/ clean
make -C ./tools/gen.conf/ -j8 &> /dev/null
make -C ./tools/gen.wca/ clean
make -C ./tools/gen.wca/ -j8 &> /dev/null
cwd=`pwd`
target_dir=ipm.traj

# prepare potentials
echo "# prepare potentials"
cd ./tools/gen.wca
./gen.wca --sigma $poten_INSERT_MOL_NAME_sigma -o table_INSERT_CG_NAME_INSERT_CG_NAME.xvg
rm -f ../tf.template/table_INSERT_CG_NAME_INSERT_CG_NAME.xvg
mv table_INSERT_CG_NAME_INSERT_CG_NAME.xvg ../../
cd ../..

# make dir
echo "# make dir"
if test -d $target_dir; then
    mv $target_dir $target_dir.`date +%s`
fi
mkdir -p $target_dir

# prepare conf.gro
echo "# prepare conf.gro"
rm -f conf.gro
if test ! -f $input_conf; then
    echo "cannot find file $input_conf, exit"
    exit
fi
nSOL=`./tools/gen.conf/nresd -f $input_conf | grep SOL | awk '{print $2}'`

# prepare topol.top
echo "# prepare topol.top"
cp tools/tf.template/topol.cg.top ./
sed "s/^SOL.*/SOL $nSOL/g" topol.cg.top > tmp.top
mv -f tmp.top $target_dir/topol.top
rm -f topol.cg.top
cp tools/tf.template/topol.atom.top ./
sed "s/^SOL.*/SOL $nSOL/g" topol.atom.top > tmp.top
mv -f tmp.top $target_dir/topol.atom.top
rm -f topol.atom.top
cp tools/tf.template/INSERT_CG_ITP ./$target_dir/
cp tools/tf.template/INSERT_ATOM_ITP ./$target_dir/
cd ./$target_dir/
gmxdump -p topol.atom.top > tmp.top 2> /dev/null
cd ..
./tools/gen.conf/atom2cg --cg-name INSERT_CG_NAME -f $input_conf -o ./$target_dir/conf.gro -p ./$target_dir/tmp.top
rm -f ./$target_dir/tmp.top 

echo "# prepare grompp.mdp"
cp tools/tf.template/grompp.mdp .
sed -e "/^nsteps /s/=.*/= $ipm_gen_traj_nsteps_0/g" grompp.mdp |\
    sed -e "/^nstenergy /s/=.*/= $ipm_nstenergy/g" |\
    sed -e "/^nstxtcout /s/=.*/= $ipm_nstxtcout/g" |\
    sed -e "/^tau_t /s/=.*/= $ipm_tau_t/g" |\
    sed -e "/^adress /s/=.*/= no/g" |\
    sed -e "/^energygrps /s/=.*/= INSERT_CG_NAME/g" |\
    sed -e "/^dt /s/=.*/= $ipm_dt/g" > tmp.tmp.tmp
grep -v 'adress_' tmp.tmp.tmp > $target_dir/grompp.mdp
rm -f grompp.mdp tmp.tmp.tmp

echo "# prepare table of cg"
cp -L table_INSERT_CG_NAME_INSERT_CG_NAME.xvg ./$target_dir
if test -f tools/tf.template/table.xvg; then
    cp tools/tf.template/table.xvg ./$target_dir
fi

cd $target_dir

# prepare index file
echo "# prepare index file"
echo "a INSERT_CG_NAME" > command.tmp
echo "q" >> command.tmp
cat command.tmp  | make_ndx -f conf.gro &> $mylog
rm -fr command.tmp

# run simulation 0
echo "# run simulation 0"
grompp -n index.ndx &> $mylog
INSERT_MDRUN_COMMAND INSERT_MDRUN_OPTIONS &> $mylog

# reset init conf
echo "# reset init conf"
mv confout.gro conf.gro
grocleanit
sed -e "/^nsteps /s/=.*/= $ipm_gen_traj_nsteps_1/g" grompp.mdp > tmp.tmp.tmp
mv -f tmp.tmp.tmp grompp.mdp

# run simulation 1
echo "# run simulation 1"
grompp -n index.ndx &> $mylog
INSERT_MDRUN_COMMAND INSERT_MDRUN_OPTIONS &> $mylog

cd $cwd

