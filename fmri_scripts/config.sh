# This is the main config.sh file for the project



#!/bin/sh

# Automatically find the project root (Given that the proj directory is on the desktop)


PROJ_DIR=$(dirname "$(find "$HOME/Desktop/proj" -maxdepth 2 -type d \( -name "BIDS*" -o -name "anat_with*" \) | head -n 1)")

# Ensure the project root was found
if [ -z "$PROJ_DIR" ]; then
  echo "Error: Could not determine PROJ_DIR. Ensure 'BIDS*' or 'anat_with_face*' exist."
  exit 1
fi


# Find the BIDS and anat directories
BIDS_DIR=$(find "$PROJ_DIR" -maxdepth 1 -type d -name "BIDS_dataset*" | head -n 1)

ANAT_DIR=$(find "$PROJ_DIR" -maxdepth 1 -type d -name "anat_with_face*" | head -n 1)

FSLICENSE_DIR=${PROJ_DIR}

if [ -z "$BIDS_DIR" ] || [ -z "$ANAT_DIR" ]; then
  echo "Error: Could not determine BIDS_DIR or ANAT_DIR."
  exit 1
fi

# Export the detected directories
export PROJ_DIR
export BIDS_DIR
export ANAT_DIR

echo "Loaded config: PROJ_DIR=$PROJ_DIR"
echo "BIDS_DIR: $BIDS_DIR"
echo "ANAT_DIR: $ANAT_DIR"
