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
target_dir=dir.ipm.traj

# prepare potentials
echo "# prepare potentials"
cd ./tools/gen.wca
table_xup=`echo "$gmx_rcut + 1.0 + 0.2" | bc -l`
./gen.wca --xup $table_xup --sigma $poten_INSERT_MOL1_NAME_sigma -o table_INSERT_CG1_NAME_INSERT_CG1_NAME.xvg
./gen.wca --xup $table_xup --sigma $poten_INSERT_MOL2_NAME_sigma -o table_INSERT_CG2_NAME_INSERT_CG2_NAME.xvg
./gen.wca --xup $table_xup --sigma $poten_CROX_sigma		 -o table_INSERT_CG1_NAME_INSERT_CG2_NAME.xvg
rm -f ../tf.template/table_INSERT_CG1_NAME_INSERT_CG1_NAME.xvg
rm -f ../tf.template/table_INSERT_CG1_NAME_INSERT_CG2_NAME.xvg
rm -f ../tf.template/table_INSERT_CG2_NAME_INSERT_CG2_NAME.xvg
mv -f table_INSERT_CG1_NAME_INSERT_CG1_NAME.xvg ../../
mv -f table_INSERT_CG1_NAME_INSERT_CG2_NAME.xvg ../../
mv -f table_INSERT_CG2_NAME_INSERT_CG2_NAME.xvg ../../
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
nINSERT_MOL1_NAME=`./tools/gen.conf/nresd -f $input_conf | grep INSERT_MOL1_NAME | awk '{print $2}'`
nINSERT_MOL2_NAME=`./tools/gen.conf/nresd -f $input_conf | grep INSERT_MOL2_NAME | awk '{print $2}'`

# prepare topol.top
echo "# prepare topol.top"
cp tools/tf.template/topol.cg.top ./
sed "s/^INSERT_MOL1_NAME.*/INSERT_MOL1_NAME $nINSERT_MOL1_NAME/g" topol.cg.top |\
sed "s/^INSERT_MOL2_NAME.*/INSERT_MOL2_NAME $nINSERT_MOL2_NAME/g" > tmp.top
mv -f tmp.top $target_dir/topol.top
rm -f topol.cg.top
cp tools/tf.template/topol.atom.top ./
sed "s/^INSERT_MOL1_NAME.*/INSERT_MOL1_NAME $nINSERT_MOL1_NAME/g" topol.atom.top |\
sed "s/^INSERT_MOL2_NAME.*/INSERT_MOL2_NAME $nINSERT_MOL2_NAME/g" > tmp.top
mv -f tmp.top $target_dir/topol.atom.top
rm -f topol.atom.top
cp tools/tf.template/INSERT_CG1_ITP ./$target_dir/
cp tools/tf.template/INSERT_CG2_ITP ./$target_dir/
cp tools/tf.template/INSERT_ATOM1_ITP ./$target_dir/
cp tools/tf.template/INSERT_ATOM2_ITP ./$target_dir/
cd ./$target_dir/
gmxdump -p topol.atom.top > tmp.top 2> /dev/null
cd ..
./tools/gen.conf/atom2cg --cg-name "INSERT_CG1_NAME INSERT_CG2_NAME" -f $input_conf -o ./$target_dir/conf.gro -p ./$target_dir/tmp.top
rm -f ./$target_dir/tmp.top 

echo "# prepare grompp.mdp"
cp tools/tf.template/grompp.mdp .
sed -e "/^nsteps /s/=.*/= $ipm_gen_traj_nsteps_0/g" grompp.mdp |\
    sed -e "/^nstenergy /s/=.*/= $ipm_nstenergy/g" |\
    sed -e "/^nstxtcout /s/=.*/= $ipm_nstxtcout/g" |\
    sed -e "/^tau_t /s/=.*/= $ipm_tau_t/g" |\
    sed -e "/^adress /s/=.*/= no/g" |\
    sed -e "/^energygrps /s/=.*/= INSERT_CG1_NAME INSERT_CG2_NAME/g" |\
    sed -e "/^dt /s/=.*/= $ipm_dt/g" > tmp.tmp.tmp
grep -v 'adress_' tmp.tmp.tmp > $target_dir/grompp.mdp
rm -f grompp.mdp tmp.tmp.tmp

echo "# prepare table of cg"
cp -L table_INSERT_CG1_NAME_INSERT_CG1_NAME.xvg ./$target_dir
cp -L table_INSERT_CG1_NAME_INSERT_CG2_NAME.xvg ./$target_dir
cp -L table_INSERT_CG2_NAME_INSERT_CG2_NAME.xvg ./$target_dir
if test -f tools/tf.template/table.xvg; then
    cp tools/tf.template/table.xvg ./$target_dir
fi

cd $target_dir

# prepare index file
echo "# prepare index file"
echo "a INSERT_CG1_NAME" >  command.tmp
echo "a INSERT_CG2_NAME" >> command.tmp
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

