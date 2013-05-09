#!/bin/bash

cwd=`pwd`
jobname=${cwd##*/}

echo "#!/bin/bash"				>  submit.sh
echo "#PBS -N $jobname"				>> submit.sh
echo "#PBS -d $cwd"				>> submit.sh
echo "#PBS -j oe"				>> submit.sh
echo "#PBS -o hlrn.out"				>> submit.sh
echo "#PBS -e hlrn.err"				>> submit.sh
echo "#PBS -M han.wang@fu-berlin.de"		>> submit.sh
echo "#PBS -l walltime=1:00:00"			>> submit.sh
echo "#PBS -l nodes=2:ppn=8"			>> submit.sh
echo "#PBS -l feature=xe"			>> submit.sh
echo "#PBS -q smallq"				>> submit.sh

echo 'eval `/sw/swdist/bin/modulesinit`'	>> submit.sh
echo 'module load mpt'				>> submit.sh
echo 'cd $PBS_O_WORKDIR'			>> submit.sh
echo "hostname"					>> submit.sh
echo "date"					>> submit.sh
echo "pwd"					>> submit.sh
echo "./gen.tf.sh"				>> submit.sh

msub submit.sh &> jobid

