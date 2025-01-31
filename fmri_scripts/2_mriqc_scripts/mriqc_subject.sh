#!/bin/bash

## User inputs:
bids_root_dir=$HOME/proj/SSH/BIDS_dataset
subj=$1
nthreads=4
mem=6 #gb

#Make mriqc directory and participant directory in derivatives folder
if [ ! -d $bids_root_dir/derivatives/mriqc ]; then
mkdir $bids_root_dir/derivatives/mriqc
fi

if [ ! -d $bids_root_dir/derivatives/mriqc/sub-${subj} ]; then
mkdir $bids_root_dir/derivatives/mriqc/sub-${subj}
fi

#Run MRIQC
echo ""
echo "Running MRIQC on participant ${subj}..."
echo ""

docker run -it --rm -v $bids_root_dir:/data:ro -v $bids_root_dir/derivatives/mriqc:/out \
nipreps/mriqc:24.0.2 /data /out \
participant --participant-label ${subj} \
--no-sub \
--n_proc $nthreads \
--mem_gb $mem \
--float32 \
--ants-nthreads $nthreads \
-v \
-w $bids_root_dir/derivatives/mriqc
