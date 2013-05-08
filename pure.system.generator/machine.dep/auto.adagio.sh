#!/bin/bash

cwd=`pwd`
jobname=${cwd##*/}

rm -f adagio.out adagio.err

echo "#!/bin/bash"				>  submit.sh
echo "#PBS -N $jobname"				>> submit.sh
echo "#PBS -d $cwd"				>> submit.sh
echo "#PBS -o adagio.out"			>> submit.sh
echo "#PBS -e adagio.err"			>> submit.sh
echo "#PBS -M han.wang@fu-berlin.de"		>> submit.sh
echo "#PBS -l walltime=24:00:00"		>> submit.sh
echo "#PBS -l nodes=1:ppn=8"			>> submit.sh
echo "#PBS -l mem=1000mb"			>> submit.sh

echo "hostname"					>> submit.sh
echo "date"					>> submit.sh
echo "pwd"					>> submit.sh
echo "./init.tf.sh"				>> submit.sh

qsub submit.sh &> jobid

