#!/bin/bash
# Setup qsub options
#$ -S /bin/bash -V
#$ -l arch=linux-x64
#$ -q stark.q,shared.q
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

id=$2


mkdir -p ${der_path}/mrtrix/DWI_B0/sub-${id}_ses-${ses}

# Next, get a b0 image from the DWI data
if [ ! -e ${der_path}/mrtrix/DWI_B0/sub-${id}_ses-${ses}/sub-${id}_ses-${ses}_dwi_b0.nii.gz ]; then 
echo Extracting b0 image
dwiextract -bzero ${bids_path}/derivatives/mrtrix/preprocessed/sub-${id}_ses-${ses}/sub-${id}_ses-${ses}_dwi.mif ${der_path}/mrtrix/DWI_B0/sub-${id}_ses-{ses}/sub-${id}_ses-{ses}_dwi_b0_all.nii.gz
mrmath -axis 3 ${der_path}/mrtrix/DWI_B0/sub-${id}_ses-{ses}/sub-${id}_ses-{ses}_dwi_b0_all.nii.gz mean ${der_path}/mrtrix/DWI_B0/sub-${id}_ses-{ses}/sub-${id}_ses-{ses}_dwi_b0.nii.gz
rm ${der_path}/mrtrix/for_T1/sub-${id}_ses-${ses}_dwi_b0_all.nii.gz #not needed anymore
else
echo b0 already exists - skipping
fi

mkdir -p ${der_path}/ANTS/sub-${id}_ses-${ses}


raw_struct=${bids_path}/sub-${id}/ses-${ses}/anat/sub-${id}_ses-${ses}_T1w.nii.gz
struct=${der_path}/ANTS/sub-${id}_ses-${ses}/sub-${id}_ses-${ses}_T1w_DWIspace.nii.gz
# Next, align the T1 and b0 using the non-skull-stripped T1
if [ ! -e ${struct} ]; then 
mkdir -p ${der_path}/ANTS/sub-${id}
echo Determining warp between T1 and b0
antsRegistrationSyNQuick.sh -d 3 -n 4 -m ${raw_struct} -f ${der_path}/mrtrix/DWI_B0/sub-${id}_ses-${ses}/sub-${id}_ses-${ses}_dwi_b0.nii.gz -o ${der_path}/ANTS/sub-${id}_ses-${ses}/sub-${id}_ses-${ses}_t1b0_ -t s
# Make a nicely gridded version of this

antsApplyTransforms -d 3 -i ${raw_struct} -r ${raw_struct} \
  -t ${der_path}/ANTS/sub-${id}_ses-${ses}/sub-${id}_ses-${ses}_t1b0_1Warp.nii.gz -t ${der_path}/ANTS/sub-${id}_ses-${ses}/sub-${id}_ses-${ses}_t1b0_0GenericAffine.mat \
  -o ${struct}

else
echo T1 to b0 already exists - skipping
fi




