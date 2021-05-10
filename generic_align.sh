#!/bin/bash
# Setup qsub options
#$ -S /bin/bash -V
#$ -l arch=linux-x64
#$ -pe openmp 4
#$ -cwd

FSLDIR=/usr/local/fsl

if [ ! -n "$NSLOTS" ]; then
	NSLOTS=4
fi

# Log some useful stuff into that log file 
echo Started at `date` 
echo Running on $subject in `pwd` 
echo Running on $HOSTNAME 
echo FSL is in `which FSL`
echo $FSLDIR
echo topup is `which fsl5.0-topup`


export OMP_NUM_THREADS=$NSLOTS
config=$1
. ${config}


moving=$2
fixed=$3
warp_out=$4


if [ ! -e a${warp_out}0GenericAffine.mat ]; then 
echo Determining warp between ${moving} and ${fixed}
antsRegistrationSyNQuick.sh -d 3 -n 4 -m ${moving} -f ${fixed} -o ${warp_out} 
else
echo ${warp_out}0GenericAffine.mat already exists - skipping
fi