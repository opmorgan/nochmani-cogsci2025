#!/bin/bash

## User inputs:
bids_root_dir=$HOME/proj/SSH/BIDS_dataset
nthreads=4
mem=6 #gb

#S pecify mriqc directory (and participant directories) in derivatives folder
mriqc_dir=$bids_root_dir/derivatives/mriqc
if [ ! -d $mriqc_dir ]; then
mkdir $mriqc_dir
fi

#Run MRIQC
echo ""
echo "Running MRIQC group summary..."
echo ""

docker run -it --rm -v $bids_root_dir:/data:ro -v $mriqc_dir:/out \
nipreps/mriqc:24.0.2 /data /out \
group \
--no-sub \
--n_proc $nthreads \
--mem_gb $mem \
--float32 \
--ants-nthreads $nthreads \
-v \
-w $mriqc_dir
