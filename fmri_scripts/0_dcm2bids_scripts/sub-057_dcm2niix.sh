#!/bin/sh

#### Config - Edit these variables for each participant
subject=sub-057
dicom_dir_name=HUMANDC057

fmap_nochmani_dir=(SER00003 SER00004)
fmap_tap_dir=(SER00013 SER00014)
mprage_dir=SER00002
nochmani_dir=(SER00005 SER00006 SER00007 SER00008)
tap_dir=SER00015
rs_dir=SER00018

# Specify which conversions to run
do_all=y # must be y/n

if [ $do_all = y ]
then
	do_fmap_nochmani_a=y
	do_fmap_nochmani_b=y
	do_fmap_tap_a=y
	do_fmap_tap_b=y
	do_mprage=y
	do_nochmani_run1=y
	do_nochmani_run2=y
	do_nochmani_run3=y
	do_nochmani_run4=y
	do_tap=y
	do_rs=n
	do_additional=y # Additional subject-specific conversions?
elif [ $do_all = n ]
then
echo HERE
	do_fmap_nochmani_a=y
	do_fmap_nochmani_b=y
	do_fmap_tap_a=y
	do_fmap_tap_b=y
	do_mprage=n
	do_nochmani_run1=n
	do_nochmani_run2=n
	do_nochmani_run3=n
	do_nochmani_run4=n
	do_tap=n
	do_rs=n
	do_additional=n # Additional subject-specific conversions?
fi


# Run main script
. run_dcm2niix.sh