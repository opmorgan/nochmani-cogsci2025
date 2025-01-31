#! /usr/bin/env bash

flirt -in Dorsolateral_L_Z2.nii -ref con_0001.nii -out 1a_resampled_Dorsolateral_L_Z2.nii -applyxfm -usesqform
flirt -in Dorsolateral_R_Z2.nii -ref con_0001.nii -out 1a_resampled_Dorsolateral_R_Z2.nii -applyxfm -usesqform
flirt -in Orbital_Frontal_L_Z0.nii -ref con_0001.nii -out 1a_resampled_Orbital_Frontal_L_Z0.nii -applyxfm -usesqform
flirt -in Orbital_Frontal_R_Z0.nii -ref con_0001.nii -out 1a_resampled_Orbital_Frontal_R_Z0.nii -applyxfm -usesqform

