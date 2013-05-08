#!/bin/bash

source env.sh
source parameters.sh

INSERT_MOL_NAME_ratio=1.0

mylog=`pwd`/gen.tf.log
makelog=`pwd`/make.log
rm -f $mylog
make -C ./tools/gen.conf/ clean
make -C ./tools/gen.conf/ -j8 &> /dev/null
make -C ./tools/gen.wca/ clean
make -C ./tools/gen.wca/ -j8 &> /dev/null

# prepare potentials
echo "# prepare potentials"
cd ./tools/gen.wca
./gen.wca --sigma $poten_INSERT_MOL_NAME_sigma -o table_INSERT_CG_NAME_INSERT_CG_NAME.xvg
rm -f ../tf.template/table_CM*_CM*.xvg
mv table_INSERT_CG_NAME_INSERT_CG_NAME.xvg ../tf.template/
cd ../..

# prepare conf.gro
echo "# prepare conf.gro"
rm -f conf.gro
if test ! -f $input_conf; then
    echo "cannot find file $input_conf, exit"
    exit
fi
cp $input_conf ./conf.gro
boxx=`tail conf.gro -n 1 | awk '{print $1}'`
boxy=`tail conf.gro -n 1 | awk '{print $2}'`
boxz=`tail conf.gro -n 1 | awk '{print $3}'`
half_boxx=`echo "$boxx/2.0" | bc -l`
half_boxy=`echo "$boxy/2.0" | bc -l`
half_boxz=`echo "$boxz/2.0" | bc -l`

# prepare dens.INSERT_MOL_NAME.xvg
echo "# prepare dens.INSERT_MOL_NAME.xvg"
rm -f dens.INSERT_MOL_NAME.xvg
for i in `seq 0 0.05 $boxx`;
do
    echo "$i 0 0" >> dens.INSERT_MOL_NAME.xvg
done

# copy dir
echo "# copy dir"
rm -fr tf
cp -a tools/tf.template ./tf

# prepare grompp.mdp
echo "# prepare grompp.mdp"
rm -fr grompp.mdp
cp tf/grompp.mdp .
sed -e "/^adress_ex_width/s/=.*/= $ex_region_r/g" grompp.mdp |\
sed -e "/^adress_hy_width/s/=.*/= $hy_region_r/g" |\
sed -e "/^adress /s/=.*/= yes/g" |\
sed -e "/^dt/s/=.*/= $gmx_dt/g" |\
sed -e "/^tau_t/s/=.*/= $gmx_tau_t/g" |\
sed -e "/^nsteps/s/=.*/= $gmx_nsteps/g" |\
sed -e "/^nstenergy/s/=.*/= $gmx_nstenergy/g" |\
sed -e "/^nstxtcout/s/=.*/= $gmx_nstxtcout/g" |\
sed -e "/^epsilon_rf/s/=.*/= $gmx_epsilon_rf/g" |\
sed -e "/^adress_reference_coords/s/=.*/= $half_boxx $half_boxy $half_boxz/g" > grompp.mdp.tmp
mv -f grompp.mdp.tmp grompp.mdp

# prepare settings.xml
echo "# prepare settings.xml"
rm -fr settings.xml
cp tf/settings.xml .
tf_min=`echo "$ex_region_r - $tf_extension" | bc -l`
tf_max=`echo "$ex_region_r + $hy_region_r + $tf_extension" | bc -l`
tf_spline_start=`echo "$ex_region_r - $tf_spline_extension" | bc -l`
tf_spline_end=`  echo "$ex_region_r + $hy_region_r + $tf_spline_extension" | bc -l`
half_boxx_1=`echo "$half_boxx + 1." | bc -l`
prefactor_l2=`grep -n prefactor settings.xml | tail -n 1 | cut -f 1 -d ":"`
sed -e "s/<min>.*<\/min>/<min>$tf_min<\/min>/g" settings.xml |\
sed -e "s/<max>.*<\/max>/<max>$tf_max<\/max>/g" |\
sed -e "s/<step>.*<\/step>/<step>$tf_step<\/step>/g" |\
sed -e "s/<spline_start>.*<\/spline_start>/<spline_start>$tf_spline_start<\/spline_start>/g" |\
sed -e "s/<spline_end>.*<\/spline_end>/<spline_end>$tf_spline_end<\/spline_end>/g" |\
sed -e "s/<spline_step>.*<\/spline_step>/<spline_step>$tf_spline_step<\/spline_step>/g" |\
sed -e "s/<table_end>.*<\/table_end>/<table_end>$half_boxx_1<\/table_end>/g" |\
sed -e "${prefactor_l2}s/<prefactor>.*<\/prefactor>/<prefactor>$INSERT_MOL_NAME_tf_prefactor<\/prefactor>/g" |\
sed -e "s/<equi_time>.*<\/equi_time>/<equi_time>$equi_time_discard<\/equi_time>/g" |\
sed -e "s/<iterations_max>.*<\/iterations_max>/<iterations_max>$tf_iterations_max<\/iterations_max>/g" > settings.xml.tmp
mv -f settings.xml.tmp settings.xml

# prepare topol.top
echo "# prepare topol.top"
nINSERT_MOL_NAME=`./tools/gen.conf/nresd -f conf.gro | grep INSERT_MOL_NAME | awk '{print $2}'`
rm -fr topol.top topol.atom.top
cp tf/topol.top .
sed "s/^INSERT_MOL_NAME.*/INSERT_MOL_NAME $nINSERT_MOL_NAME/g" topol.top > tmp.top
mv -f tmp.top topol.top
cp tf/topol.atom.top .
sed "s/^INSERT_MOL_NAME.*/INSERT_MOL_NAME $nINSERT_MOL_NAME/g" topol.atom.top > tmp.top
mv -f tmp.top topol.atom.top

# prepare table of cg
echo "# prepare table of cg"
rm -f tf/table_INSERT_CG_NAME_INSERT_CG_NAME.xvg
cp -L $cg_pot_dir/table_INSERT_CG_NAME_INSERT_CG_NAME.xvg ./tf/

# prepare initial guess
echo "# prepare initial guess"
if test -f $init_guess_INSERT_MOL_NAME_tf; then
    cp $init_guess_INSERT_MOL_NAME_tf ./tf/INSERT_MOL_NAME.pot.in
fi

# copy all file to tf
echo "# copy files to tf"
rm -fr tf/conf.gro tf/dens.INSERT_MOL_NAME.xvg tf/grompp.mdp tf/index.ndx tf/settings.xml tf/topol.top
mv -f conf.gro dens.INSERT_MOL_NAME.xvg grompp.mdp settings.xml topol.top topol.atom.top tf/

# prepare index file
cd tf/
gmxdump -p topol.top > tmp.top
../tools/gen.conf/adress.ndx -p tmp.top --ex-name INSERT_EX_NAME --cg-name INSERT_CG_NAME -o index.ndx
# prepare conf
gmxdump -p topol.atom.top > tmp.top
../tools/gen.conf/add.com -f conf.gro -o out.gro -p tmp.top --cg-name INSERT_CG_NAME
mv -f out.gro conf.gro
rm -f tmp.top
cd ..

# calculate tf
echo "# calculate tf"
cd tf
sync
csg_inverse --options settings.xml
cd ..

# rm trajs
echo "# rm trajs"
rm -f tf/step_*/traj.xtc


