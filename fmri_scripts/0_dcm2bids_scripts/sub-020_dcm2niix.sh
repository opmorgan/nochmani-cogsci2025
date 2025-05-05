#!/bin/sh

#### Config - Edit these variables for each participant
subject=sub-020
dicom_dir_name=HUMANDC020

fmap_nochmani_dir=(SER00004 SER00005)
fmap_tap_dir=(SER00010 SER00011)
mprage_dir=SER00002
nochmani_dir=(SER00006 SER00007 SER00008 SER00009)
tap_dir=SER00012
rs_dir=SER00015

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
elif [ $do_all = n ]
then
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
fi


# Run main script
. run_dcm2niix.sh
