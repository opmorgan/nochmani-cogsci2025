Scripts to extract ROI values from Berkman & Leiberman's frontal ROIs.

1_resample_mask/
Resample the masks to the same space as the functional scans


2_extract_roi_summaries/
The scripts "script_extract_roi_for_csv_con.m" and "script_extract_roi_for_csv_beta.m" extract mean ROI values using spm_get_data(), based on each participant's con...nii and beta...nii files, respectively.
The folder marsbar/ contains analogous analyses, using marsbar to extract mean values. These should yield a similar pattern of results. 