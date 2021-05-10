#!/bin/bash
# Setup qsub options
#$ -S /bin/bash -V
#$ -l arch=linux-x64
#$ -pe openmp 4


if [ ! -n "$NSLOTS" ]; then
	NSLOTS=4
fi

# Log some useful stuff into that log file 
echo Started at `date` 
echo Running on $subject in `pwd` 
echo Running on $HOSTNAME 

export OMP_NUM_THREADS=$NSLOTS

config=$1
sub=$2
ses=$3
. $config


raw_dwi=${bids_path}/sub-${sub}/ses-${ses}/dwi/sub-${sub}_ses-${ses}_dwi
preproc_path=${der_path}/mrtrix/preprocessed/sub-${sub}_ses-${ses}
mkdir -p ${preproc_path}
dwi=${preproc_path}/sub-${sub}_ses-${ses}_dwi #preprocessed image

#Setting up .mif file for ease of translation (MRtrix processed .mif files faster than compressed nifti files. .mif files also allow for the diffusion gradient tables to be embedded in them):
if [ ! -e ${dwi}_raw.mif ]; then
	mrconvert ${raw_dwi}.nii.gz ${dwi}_raw.mif -fslgrad ${raw_dwi}.bvec ${raw_dwi}.bval
else
	echo Initial set up for DWI already done. Continue to preprocessing. 
fi

if [ ! -e ${dwi}.nii.gz ]; then
	#Removing thermal noise:
	dwidenoise  ${dwi}_raw.mif ${dwi}_dn.mif

	#Remove Gibbs Ringing Artifacts:
	mrdegibbs ${dwi}_dn.mif ${dwi}.mif 
	rm ${dwi}_dn.mif #clean up
	mrconvert ${dwi}.mif ${dwi}.nii.gz #for use with other programs
else
	echo Image has already been denoised and unringed! Skipping...
fi


#Make brain mask
mask_path=${der_path}/mrtrix/masks/sub-${sub}_ses-${ses}
mkdir -p ${mask_path}
if [ ! -e ${mask_path}/sub-${sub}_ses-${ses}_dwi_mask.mif ]; then
	dwi2mask ${dwi}.mif ${mask_path}/sub-${sub}_ses-${ses}_dwi_mask.mif
	mrconvert ${mask_path}/sub-${sub}_ses-${ses}_dwi_mask.mif ${mask_path}/sub-${sub}_ses-${ses}_dwi_mask.nii.gz
else
	echo Brain mask already exists- skipping...
fi

#Extract B0 (to align anat):
b0_path=${der_path}/mrtrix/DWI_B0/sub-${sub}_ses-${ses}
mkdir -p ${b0_path}
if [ ! -e ${b0_path}/sub-${sub}_ses-${ses}_dwi_b0.nii.gz ]; then 
	echo Extracting b0 image
	dwiextract -bzero ${dwi}.mif ${b0_path}/sub-${sub}_ses-${ses}_dwi_b0_all.nii.gz
	mrmath -axis 3 ${b0_path}/sub-${sub}_ses-${ses}_dwi_b0_all.nii.gz mean ${b0_path}/sub-${sub}_ses-${ses}/sub-${sub}_ses-${ses}_dwi_b0.nii.gz
	rm ${b0_path}/sub-${sub}_ses-${ses}/sub-${sub}_ses-${ses}_dwi_b0_all.nii.gz #not needed anymore
else
	echo b0 averaged image already exists - skipping
fi