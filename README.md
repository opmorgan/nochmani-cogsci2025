This repo contains data and analysis code for the 47th Annual Conference of the Cognitive Science Society submission, "Replication of Prefrontal Asymmetry in Approach-Avoidance Motivation in fMRI"

Preregistration: https://aspredicted.org/khc9-m5my.pdf


# Experiment script and stimuli

The folder "experiment_scripts" contains experiment scripts and stimuli (see README: experiment_scripts/README.md).

# Data
Behavioral, survey, and summary fMRI data are in beh_scripts/data.
- Raw behavioral data: beh_scripts/data/raw/sub-ID/beh/
- Processed behavioral data: beh_scripts/data/proc/beh_long.csv; beh_scripts/data/proc/sub-ID/beh/
- Survey data: beh_scripts/data/proc/redcap.csv
- fMRI event specifications: beh_scripts/data/proc/sub-ID/func/

# Analysis code
All R scripts are in the folder beh_scripts/, which is an Rproject with its package environment recorded in renv.lock. The folder beh_scripts/lib contrains helper functions use by R analysis scripts. fMRI processing and analysis scripts (fmri_scripts/0, 1, 2, and 3) depend on python libraries; the package environment for each script is recorded in requirements.txt in each analysis folder (for example, fmri_scripts/3_fmriprep_scripts/requirements.txt). 1st level and ROI extraction scripts depend on SPM12, and have been tested in MATLAB version 24.2.0.

## Process behavioral data and extract event specifications:
- beh_scripts/analysis_beh/1_clean_beh: load and clean behavioral data.
- beh_scripts/analysis_beh/2_create_events.tsv: create fMRI event specifications using processed behavioral data.

## Preprocess and analyze fMRI data
- fmri_scripts/0_dcm_to_nii/: convert raw dicom files to BIDS-compliant .nii files
- fmri_scripts/1_pydeface_scripts/: remove faces from structural scans
- fmri_scripts/2_mriqc_scripts/: create MRIQC quality metrics and reports
- fmri_scripts/3_fmriprep_scripts/: preprocess data with fMRIprep
- fmri_scripts/4_spm_scripts/: create 1st level contrast maps
- fmri_scripts/5_roi_scripts/: extract summary values from ROIs

## Analyze ROI and survey data
- beh_scripts/analysis_roi/1a_analyze_roi_score.qmd: Run ROI laterality analyses
- beh_scripts/analysis_beh/1b_analyze_roi_scores_cor.qmd: Run analyses correlating ROI summary values with survey scores