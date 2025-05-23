This repo contains data and analysis code for the 47th Annual Conference of the Cognitive Science Society submission, "Replication of Prefrontal Asymmetry in Approach-Avoidance Motivation in fMRI"

Preregistration: https://aspredicted.org/khc9-m5my.pdf


# Experiment script and stimuli

The folder `experiment_scripts/` contains experiment scripts and stimuli (see README: `experiment_scripts/README.md`).

# Data
Behavioral, survey, and summary fMRI data are in `beh_scripts/data`.
- Raw behavioral data: `beh_scripts/data/raw/sub-ID/beh/`
- Processed behavioral data: `beh_scripts/data/proc/beh_long.csv; beh_scripts/data/proc/sub-ID/beh/`
- Survey data: `beh_scripts/data/proc/redcap.csv`
- fMRI event specifications: `beh_scripts/data/proc/sub-ID/func/`

# Analysis code
All R scripts are in the folder `beh_scripts/`, which is an Rproject with its package environment recorded in renv.lock. The folder beh_scripts/lib contrains helper functions use by R analysis scripts. fMRI processing and analysis scripts (`fmri_scripts/[0..., 1..., ...]`) depend on python libraries; the package environment for each script is recorded in requirements.txt in each analysis folder (for example, `fmri_scripts/3_fmriprep_scripts/requirements.txt`). 1st level and ROI extraction scripts depend on SPM12, and have been tested in MATLAB version 24.2.0.

Scripts can be run in the following order:

(1) Process behavioral data and extract event specifications
- `beh_scripts/analysis_beh/1_clean_beh.R`: load and clean behavioral data.
- `beh_scripts/analysis_beh/2_create_events_tsv.R`: create fMRI event specifications using processed behavioral data. (These event specification files are used by fmri_scripts/4_spm_scripts/script_1_create_multiple_conditions).
  
(2) Preprocess fMRI data
- `fmri_scripts/0_dcm_to_nii/`: convert raw dicom files to BIDS-compliant .nii files
- `fmri_scripts/1_pydeface_scripts/`: remove faces from structural scans
- `fmri_scripts/2_mriqc_scripts/`: create MRIQC quality metrics and reports
- `fmri_scripts/3_fmriprep_scripts/`: preprocess data with fMRIprep
  
(3) Run 1st and 2nd level analyses with SPM
- `fmri_scripts/4_spm_scripts/`: create 1st level contrast maps
  - `script_0_smooth.m`: smooth pre-processed data
  - `script_1_create_multiple_conditions.m`: create matlab objects specifying event onset for each subject, using the `.tsv` files created by `beh_scripts/analysis_beh/2_create_events_tsv.R`. These matlab objects can be used in SPM's 1st level specification.
  - `script_2_1st_level_spec.m`: Specify the 1st level model design for each subject
  - `script_3_prepare_contrast_matrices.m`: Prepare contrast matrices for each subject
  - `script_4_1st_level_contrasts.m` Estimate 1st level contrasts (those specified by `script_3`)
  - `script_5_2nd_level_contrasts.m` Specify and estimate 2nd level, whole-brain contrasts

(4) Run ROI analyses
- `fmri_scripts/5_roi_scripts/`: extract summary values from ROIs
  - See `fmri_scripts/5_roi_scripts/README.txt` 

(5) Analyze ROI and survey data
- `beh_scripts/analysis_roi/1a_analyze_roi_score.qmd`: Run ROI laterality analyses
- `beh_scripts/analysis_beh/1b_analyze_roi_scores_cor.qmd`: Run analyses correlating ROI summary values with survey scores

## (1) Process behavioral data and extract event specifications

### Environment and dependencies
R scripts have been tested with R version 4.4.1.
R dependencies can be installed with [renv](https://rstudio.github.io/renv/articles/renv.html):
1. Open the RProject, `nochmani_scripts.Rproj`, in Rstudio.
1. Install renv: `install.packages("renv")`
1. Install packages listed in lockfile to project environment: `renv::activate()`

### Scripts
- `beh_scripts/analysis_beh/1_clean_beh.R`: load and clean behavioral data.
- `beh_scripts/analysis_beh/2_create_events_tsv.R`: create fMRI event specifications using processed behavioral data. (These event specification files are used by fmri_scripts/4_spm_scripts/script_1_create_multiple_conditions). This scripts creates events files and places them in the directories: `beh_scripts/data/proc/sub-{xxx}/func`. To use these events files in analysis, they must be moved to the BIDS-compliant locations: `{BIDS_DIR}/sub-{xxx}/func/`.

## (2) Preprocess fMRI data

### Environment and dependencies
System dependencies: `bash`, `python 3.10`, `MATLAB 24.2.0`, `SPM12`, `docker`, `mriqc 24.0.2`, `dcm2niix`, `fsl`, `quarto` or `Rstudio`

Python dependencies are specified in `fmri_scripts/requirements.txt`. These scripts have been tested in MacOS 15 (Sequoia).

To set up the virtual environment with python dependencies, we recommend that you use [venv](https://docs.python.org/3/library/venv.html), and install python dependencies to the virtual environment:
1. In a terminal, navigate to the directory `fmri_scripts/`
2. Create a virtual environment with venv: `python3 -m venv env` (Or replace `python3` with whatever your python executable is called)
3. Activate the virtual enviroment: `source env/bin/activate` (See [venv docs](https://docs.python.org/3/library/venv.html) for OS-specific instructions)]
4. Install dependencies with pip, within the virtual environment: `pip install -r requirements.txt`

The docker daemon must be running order to run MRIQC and fMRIprep. On MacOS, run it by opening the desktop application `Docker Desktop`.

Additionally, a freesurfer license is needed to run fMRIprep. (See guidance in the [fMRIprep documentation](https://fmriprep.org/en/1.2.2/installation.html)) To obtain a license, register at https://surfer.nmr.mgh.harvard.edu/registration.html. Then, place the license file (`fslicense.txt`) in the parent folder of your BIDS root directory.

### Config
fMRI processing scripts are designed prepare and analyze BIDS-compliant data. Specify the BIDS root directory that contains the BIDS-formatted fMRI data in the config file, `fmri_scripts/config.sh.` Preprocessing scripts will source this file. 

### Scripts

#### 2.0 Convert dicom files to .nii
- `fmri_scripts/0_dcm_to_nii/`: convert raw dicom files to BIDS-compliant .nii files
  - To run dicom conversion for all subjects, execute `do_dcm2niix.sh` with bash. (In a terminal with a bash shell, navigate to the directory `fmri_scripts/0_dcm2niix.sh/`, and run the command `./do_dcm2niix.sh`).
  - To run conversion on a specific scans (for example, only anatomical), edit the configuration options in the subject-specific scripts, such as `sub-003_dcm2niix.sh`, which can be executed with bash. Each  subject-specific script contains a manual mapping from the filenames generated by the scanner to BIDS-compliant filenames.

#### 2.1 Remove faces from structural scans
- `fmri_scripts/1_pydeface_scripts/`: remove faces from structural scans
  - After installing python dependencies from `requirements.txt`, run `do_pydeface.sh` with bash.

#### 2.2 Check image quality with mriqc
- `fmri_scripts/2_mriqc_scripts/`: create MRIQC quality metrics and reports
  - First, ensure that the docker daemon is runner (on Mac OS, launch `Docker Desktop`)
  - To run mriqc reports on all subjects, execute `do_mriqc.sh` with bash
  - To run mriqc on a specific subject, run `mriqc_subject.sh {sub-id}`
  - To edit parameters such as RAM and threads allocated to mriqc, edit `mriqc_subject.sh`

#### 2.3 preprocess data with fMRIprep
- `fmri_scripts/3_fmriprep_scripts/`: preprocess data with fMRIprep
  - First, ensure that the docker daemon is runner (on Mac OS, launch `Docker Desktop`)
  - Install python dependencies from `requirements.txt`
  - To run fmriprep reports on all subjects, execute `do_fmriprep.sh` with bash
  - To run mriqc on a specific subject, run `fmriprep_subject.sh {sub-id}`
  - To edit parameters such as RAM and threads allocated to mriqc, edit `fmriprep_subject.sh`
  
## (3) Run 1st and 2nd level analyses with SPM

### Dependencies
SPM analysis scripts depend on the matlab toolbox `SPM12`, and have been tested with `MATLAB version 24.2.0`.

### Scripts

#### 3.1 Create 1st level contrast maps
- `fmri_scripts/4_spm_scripts/`:
  - `script_0_smooth.m`: smooth pre-processed data
  - `script_1_create_multiple_conditions.m`: create matlab objects specifying event onset for each subject, using the `.tsv` files created by `beh_scripts/analysis_beh/2_create_events_tsv.R`. These matlab objects can be used in SPM's 1st level specification.

#### 3.2 Estimate 1st level (individual subject) contrasts
  - `script_2_1st_level_spec.m`: Specify the 1st level model design for each subject
  - `script_3_prepare_contrast_matrices.m`: Prepare contrast matrices for each subject
  - `script_4_1st_level_contrasts.m` Estimate 1st level contrasts (those specified by `script_3`)

#### 3.3. Estimate 2nd level (group) contrasts
  - `script_5_2nd_level_contrasts.m` Specify and estimate 2nd level, whole-brain contrasts

## (4) Extract ROI summaries

- `fmri_scripts/5_roi_scripts/`: extract summary values from ROIs
  - See `fmri_scripts/5_roi_scripts/README.txt`

## (5) Analyze ROI and survey data

### Environment and dependencies
R scripts have been tested with R version 4.4.1.
R dependencies can be installed with [renv](https://rstudio.github.io/renv/articles/renv.html):
1. Open the RProject, `nochmani_scripts.Rproj`, in Rstudio.
1. Install renv: `install.packages("renv")`
1. Install packages listed in lockfile to project environment: `renv::activate()`

### Scripts
- `beh_scripts/analysis_roi/1a_analyze_roi_score.qmd`: Run ROI laterality analyses
- `beh_scripts/analysis_beh/1b_analyze_roi_scores_cor.qmd`: Run analyses correlating ROI summary values with survey scores
