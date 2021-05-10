#! /bin/bash
#$ -S /bin/bash -V
#$ -pe openmp 4
#$ -l arch=linux-x64
#$ -j y 

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

preproc=${der_path}/mrtrix/preprocessed/sub-${sub}_ses-${ses}/sub-${sub}_ses-${ses}_dwi
mask=${der_path}/mrtrix/masks/sub-${sub}_ses-${ses}/sub-${sub}_ses-${ses}_dwi_mask.nii.gz
tensor_data=${der_path}/mrtrix/tensors/sub-${sub}_ses-${ses}

mkdir -p ${tensor_data}


# Making ADC maps
if [ ! -e ${tensor_data}/sub-${sub}_ses-${ses}_fa.nii.gz ]; then
dwi2adc ${preproc}.mif ${tensor_data}/sub-${sub}_ses-${ses}_mean_ADC_map.nii.gz

# Estimating tensors
dwi2tensor -mask ${mask}.mif ${preproc}.mif ${tensor_data}/sub-${sub}_ses-${ses}_mean_tensor.nii.gz

# Generating maps of tensor-derived parameters- ADC, FA, AD, RD, :
tensor2metric ${tensor_data}/sub-${sub}_ses-${ses}_mean_tensor.nii.gz -mask ${mask} -adc ${tensor_data}/sub-${sub}_ses-${ses}_adc.nii.gz -fa ${tensor_data}/sub-${sub}_ses-${ses}_fa.nii.gz -ad ${tensor_data}/sub-${sub}_ses-${ses}_ad.nii.gz -rd ${tensor_data}/sub-${sub}_ses-${ses}_rd.nii.gz
fi

## FSL command:
# tensor_data=${der_path}/fsl/tensors/sub-${sub}_ses-${ses}
# mkdir -p ${tensor_data}
# if [ ! -e ${tensor_data}/sub-${sub}_ses-${ses}_FA.nii.gz ]; then
# dtifit -k ${preproc}.nii.gz \
# -o ${tensor_data}/sub-${sub}_ses-${ses} \
# -m ${mask} \
# -r ${preproc}.bvec \
# -b ${preproc}.bval \
# -V
# fi


# Copy to common metrics folder for ease:
diff=${der_path}/diffusion_metrics/sub-${sub}_ses-${ses}/subject_space
mkdir -p ${diff}
if [ ! -e ${diff}/sub-${sub}_ses-${ses}_fa.nii.gz ]; then
	cp ${tensor_data}/* ${diff}
fi