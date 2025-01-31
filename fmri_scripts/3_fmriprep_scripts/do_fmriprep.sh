#!/bin/bash

declare -a subjects=(
    "KP"
    "SD"
    "003"
    "020"
    "035"
    "039"
    "040"
    "043"
    "048"
    "053"
    "055"
    "057"
    "058"
    "059"
    "081"
    "096"
    "098"
    "103"
    "108"
    "110"
    "111"
    "122"
    "155"
)

for i in "${!subjects[@]}";
do  
    subject=${subjects[$i]} 
    echo "Running fmriprep for:"
    echo sub-${subject}

    ./fmriprep_subject.sh ${subject}
done

