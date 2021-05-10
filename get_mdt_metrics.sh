#!/bin/bash
# Setup qsub options
#$ -S /bin/bash -V
#$ -l arch=linux-x64
#$ -pe openmp 4
#$ -cwd



if [ -e ${JOB_${subject}}.o${JOB_ID} ]; then 
  chmod a+rw ${JOB_${subject}}.o${JOB_ID} 
fi 

MCRPATH=/tmp/mribin/MCR/v94
COMP_SCRIPT=/tmp/mribin/NODDI_101/compiled_cmdline/run_NODDI_pipeline_grid.sh
export PATH=/tmp/mribin/anaconda/bin:$PATH

echo MCRPATH is $MCRPATH

config=$1
sub=$2
ses=$3

. $config

id=${sub}_ses-${ses}


# Log some useful stuff into that log file 
echo Started at `date` 
echo Running on $subject in `pwd` 
echo Running on $HOSTNAME 

# SET UP NODDI DIRECTORY
mdt_path=${der_path}/mdt
mkdir -p ${mdt_path}/sub-${id}

if [ ! -e ${mdt_path}/sub-${id}/sub-${id}_dwi.nii ]; then
mrconvert ${der_path}/mrtrix/preprocessed/sub-${id}/sub-${id}_dwi.mif ${mdt_path}/sub-${id}/sub-${id}_dwi.nii -force #because noddi doesn't like compressed files. Notice preprocessed. 
mrconvert ${der_path}/mrtrix/masks/sub-${id}/sub-${id}_dwi_mask.mif ${mdt_path}/sub-${id}/sub-${id}_mask.nii 
fi 

cd  ${mdt_path}/sub-${id}
if [ ! -e sub-${id}_dwi.prtcl ]; then
echo Creating Protocol File
#Renaming BVECS and BVALS to make running MDT easier:
bvec=${mdt_path}/sub-${id}/sub-${id}_dwi.bvecs
bval=${mdt_path}/sub-${id}/sub-${id}_dwi.bvals
if [ ! -e $bvec ]; then
	cp ${der_path}/mrtrix/preprocessed/sub-${id}/sub-${id}_dwi.bvec $bvec #Don't want to mess things up haha
fi
if [ ! -e $bval ]; then
	cp ${der_path}/mrtrix/preprocessed/sub-${id}/sub-${id}_dwi.bval $bval #Don't want to mess things up haha
fi
echo Creating Protocol File
echo bvec is $bvec
echo bval is $bval
echo Protocol file saved as sub-${id}_dwi.prtcl
mdt-create-protocol ${bvec} ${bval}
fi


echo Running NODDI pipeline-MDT on ${id} from ${bids_path} in ${mdt_path}

if [ ! -e ${mdt_path}/sub-${id}/output/NODDI/NDI.nii.gz]
	mdt-model-fit NODDI sub-${id}_dwi.nii sub-${id}_dwi.prtcl sub-${id}_mask.nii
fi

# Copy to common metrics folder for ease:
diff=${der_path}/diffusion_metrics/sub-${sub}_ses-${ses}/subject_space
mkdir -p ${diff}
if [ ! -e ${diff}/sub-${sub}_ses-${ses}_NDI.nii.gz ]; then
	cp ${mdt_path}/sub-${id}/output/NODDI/NDI.nii.gz ${diff}/sub-${sub}_ses-${ses}_NDI.nii.gz
	cp ${mdt_path}/sub-${id}/output/NODDI/ODI.nii.gz ${diff}/sub-${sub}_ses-${ses}_ODI.nii.gz
	cp ${mdt_path}/sub-${id}/output/NODDI/w_csf.w.nii.gz ${diff}/sub-${sub}_ses-${ses}_FISO.nii.gz
fi