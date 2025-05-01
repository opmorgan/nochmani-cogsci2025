#!/bin/sh
# Depends on:
# python 3.12.0
# pydeface 2.0.2
# (Use virtual environment: .../code/nochmani-scripts-git/fmri_scripts/pydeface_scripts/python3-env)

source ../config.sh

subject=$1

BIDS_DIR=${BIDS_DIR}
IN_DIR=${ANAT_DIR}
OUT_DIR=${BIDS_DIR}/${subject}/ana

if [ ! -d ${OUT_DIR} ]; then
  mkdir -p ${OUT_DIR}
fi


echo Defacing ${subject}...

pydeface ${IN_DIR}/${subject}/${subject}_T1w.nii --outfile ${OUT_DIR}/${subject}_T1w.nii --verbose

# Copy json file to new location as well
cp ${IN_DIR}/${subject}/${subject}_T1w.json ${OUT_DIR}/${subject}_T1w.json

echo Defaced ${subject}.
