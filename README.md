# README

>This was the code used to generate the results in the paper: Tacrolimus protects against age-associated microstructural changes in the beagle brain published in the Journal of Neuroscience, May 2021. [(DOI)](https://doi.org/10.1523/JNEUROSCI.0361-21.2021)
>
The external atlases used in this project can be found at:
Czeibert Atlas: https://figshare.com/s/628cbf7d4210271ffe70
Nitzsche Atlas: http://brainmapping.matrikel2001.de/dog/ 

***Please cite if using any part of this repository:***
Radhakrishnan, H., Ubele, M., Krumholz, S., Boaz, K., Mefford, J., & Jones, E. et al. (2021). Tacrolimus protects against age-associated microstructural changes in the beagle brain. _The Journal Of Neuroscience_, JN-RM-0361-21. doi: 10.1523/jneurosci.0361-21.2021

*Contact us at hradhakr@uci.edu for help.*

Make sure anat and dwi files are in BIDs format before proceeding. (https://github.com/NILAB-UvA/bidsify)
This script assumes each subject has multiple sessions. It can be easily modified for single session analysis.

#### Setting up config file:
Instructions on __config.sh__

#### Example Pipeline:
1. Preprocess diffusion image.
2. Generate tensor metrics.
3. Generate NODDI metrics.
4. Align T1w to diffusion space.
5. Skull strip and segment T1w image.
6. Warp individual subject spaces to atlas spaces.
7. Get averaged metrics (diffusion, volume) for each subject in a specified ROI (into an excel sheet).
8. Get AFNI whole brain results.
***
***
### Preprocessing diffusion image:
#### preprocess_DWI.sh
Uses MRtrix3 to:
1. Denoise diffusion data
2. Correct Gibbs Ringing Artifacts
3. Make brain masks.
4. Generate averaged B0 images 

*Results in derivatives/mrtrix/preprocessed*
##### Usage:
	./preprocess_dwi.sh <config_file> <subject_ID> <session_ID>
***
### Get tensor metrics:
#### get_tensor_metrics.sh
Uses MRtrix3 to estimate tensor metrics and generate ADC maps.
*Results in derivatives/mrtrix/tensors and derivatives/diffusion_metrics*
##### Usage:
	./get_tensor_metrics.sh <config_file> <subject_ID> <session_ID>
***

### Get NODDI metrics:
#### get_mdt_metrics.sh
Uses the MDT python toolbox to generate NODDI parametric maps after creating a protocol file from the diffusion gradient table.
*Results in derivatives/mdt and derivatives/diffusion_metrics*
##### Usage:
	./get_mdt_metrics.sh <config_file> <subject_ID> <session_ID>
***

### Align structural image to diffusion space:
#### align_t1b0.sh
Extracts the B0 volumes from the diffusion image, averages across them and aligns the T1w image to that space.
*Results in derivatives/ANTS
##### Usage:
	./align_t1b0.sh <config_file> <subject_ID> <session_ID>
***

### Skull strip and segment T1w image:
#### antsBrainExtraction_k9.sh
Modified ANTS' Brain Extraction pipeline to be compatible with canine orientation.
##### Usage:
	./antsBrainExtraction_k9.sh #for detailed list of parameters.
***

##### generic_align.sh for warping between subject spaces and various atlas spaces.
##### Use 3dmaskave to average over ROIs (https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dmaskave.html)

