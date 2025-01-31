#! /usr/bin/env bash

#User inputs:
subj=$1
NTHREADS=6
MEM_MB=12000 #mb

WORK_DIR=$HOME/proj/SSH/tmp/fmriprep_workflow_${subj}/work
BIDS_ROOT_DIR=$HOME/proj/SSH/BIDS_dataset
OUT_DIR=${BIDS_ROOT_DIR}/derivatives/fmriprep-fmap
FS_LICENSE_PATH=$HOME/proj/SSH/fslicense.txt

## Make working dir, output dir:
if [ ! -d ${WORK_DIR} ]; then
  mkdir -p ${WORK_DIR}
fi

if [ ! -d ${OUT_DIR} ]; then
  mkdir -p ${OUT_DIR}
fi

#export TEMPLATEFLOW_HOME=$HOME/.cache/templateflow
export FS_LICENSE=${FS_LICENSE_PATH}

#Run fmriprep
fmriprep-docker ${BIDS_ROOT_DIR} ${OUT_DIR} \
  participant \
  --participant-label ${subj} \
  --md-only-boilerplate \
  --fs-license-file ${FS_LICENSE_PATH} \
  --fs-no-reconall \
  --output-spaces MNI152NLin2009cAsym:res-2 \
  --nthreads ${NTHREADS} \
  --omp-nthreads ${NTHREADS} \
  --mem-mb ${MEM_MB} \
  -w ${WORK_DIR} \
  -v \
  --notrack

