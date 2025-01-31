#!/bin/sh

# Dependencies: dcm2niix

#### Config
# Optional flags for dcm2niix
phillips=y
verbose=n
progress=y
compress=n

#### Edit the below with caution
PROJ_DIR=$HOME/proj/SSH
BIDS_DIR=${PROJ_DIR}/BIDS_dataset
#dicom_dir_name is passed from sub-XXX_dcm2nixx.sh (as well as mprage_dir, nochnami_dir, tap_dir)
dicom_dir=${BIDS_DIR}/sourcedata/${subject}/${dicom_dir_name}
anat_dir=${PROJ_DIR}/anat_with_face/${subject}
func_dir=${BIDS_DIR}/${subject}/func
fmap_dir=${BIDS_DIR}/${subject}/fmap


if [ ! -d ${anat_dir} ]; then
  mkdir -p ${anat_dir}
fi

if [ ! -d ${func_dir} ]; then
  mkdir -p ${func_dir}
fi

if [ ! -d ${fmap_dir} ]; then
  mkdir -p ${fmap_dir}
fi


# Convert fieldmaps
if [ ${do_fmap_nochmani_a} = y ]
then
	echo Converting fieldmap: Nochmani, pepolar 0...
	dcm2niix -f "${subject}_acq-nochmani_dir-PA_epi" -p ${phillips} -v ${verbose} -z ${compress} --progress ${progress} -o "${fmap_dir}" "${dicom_dir}/${fmap_nochmani_dir[0]}"
	echo Converted fieldmap: Nochmani, pepolar 0.
fi

if [ ${do_fmap_nochmani_a} = y ]
then
	echo Converting fieldmap: Nochmani, pepolar 1...
	dcm2niix -f "${subject}_acq-nochmani_dir-AP_epi" -p ${phillips} -v ${verbose} -z ${compress} --progress ${progress} -o "${fmap_dir}" "${dicom_dir}/${fmap_nochmani_dir[1]}"
	echo Converted fieldmap: Nochmani, pepolar 1.
fi

if [ ${do_fmap_nochmani_a} = y ]
then
	echo Converting fieldmap: Tap, pepolar 0...
	dcm2niix -f "${subject}_acq-tap_dir-PA_epi" -p ${phillips} -v ${verbose} -z ${compress} --progress ${progress} -o "${fmap_dir}" "${dicom_dir}/${fmap_tap_dir[0]}"
	echo Converted fieldmap: Tap, pepolar 0.
fi

if [ ${do_fmap_nochmani_a} = y ]
then
	echo Converting fieldmap: Tap, pepolar 1...
	dcm2niix -f "${subject}_acq-tap_dir-AP_epi" -p ${phillips} -v ${verbose} -z ${compress} --progress ${progress} -o "${fmap_dir}" "${dicom_dir}/${fmap_tap_dir[1]}"
	echo Converted fieldmap: Tap, pepolar 1.
fi

if [ ${do_mprage} = y ]
then
	echo Converting MPRAGE...
	dcm2niix -f "${subject}_T1w" -p ${phillips} -v ${verbose} -z ${compress} --progress ${progress} -o "${anat_dir}" "${dicom_dir}/${mprage_dir}"
	echo Converted MPRAGE.
fi

# Convert functional scans (Nochmani task)
if [ ${do_nochmani_run1} = y ]
then
	echo Converting tapping task scan: Run 1...
	dcm2niix -f "${subject}_task-nochmani_run-01_bold" -p ${phillips} -v ${verbose} -z ${compress} --progress ${progress} -o "${func_dir}" "${dicom_dir}/${nochmani_dir[0]}"
	echo Converted tapping task scan: Run 1.
fi

if [ ${do_nochmani_run2} = y ]
then
	echo Converting tapping task scan: Run 2...
	dcm2niix -f "${subject}_task-nochmani_run-02_bold" -p ${phillips} -v ${verbose} -z ${compress} --progress ${progress} -o "${func_dir}" "${dicom_dir}/${nochmani_dir[1]}"
	echo Converted tapping task scan: Run 2.
fi

if [ ${do_nochmani_run3} = y ]
then
	echo Converting tapping task scan: Run 3...
	dcm2niix -f "${subject}_task-nochmani_run-03_bold" -p ${phillips} -v ${verbose} -z ${compress} --progress ${progress} -o "${func_dir}" "${dicom_dir}/${nochmani_dir[2]}"
	echo Converted tapping task scan: Run 3.
fi

if [ ${do_nochmani_run4} = y ]
then
	echo Converting tapping task scan: Run 4...
	dcm2niix -f "${subject}_task-nochmani_run-04_bold" -p ${phillips} -v ${verbose} -z ${compress} --progress ${progress} -o "${func_dir}" "${dicom_dir}/${nochmani_dir[3]}"
	echo Converted tapping task scan: Run 4.
fi

# Convert functional scans (Tapping task)
if [ ${do_tap} = y ]
then
	echo Converting tapping task scan...
	dcm2niix -f "${subject}_task-tap_bold" -p ${phillips} -v ${verbose} -z ${compress} --progress ${progress} -o "${func_dir}" "${dicom_dir}/${tap_dir}"
	echo Converted tapping task scan.
fi

# Convert resting state scans
if [ ${do_rs} = y ]
then
	echo Converting resting state scan...
	dcm2niix -f "${subject}_task-rest_bold" -p ${phillips} -v ${verbose} -z ${compress} --progress ${progress} -o "${func_dir}" "${dicom_dir}/${rs_dir}"
	echo Converted resting state scan.
fi



