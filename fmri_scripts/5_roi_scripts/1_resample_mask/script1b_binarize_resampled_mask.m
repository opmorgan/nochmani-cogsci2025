% List of open inputs
% nrun = X; % enter the number of runs here
% jobfile = {'/Users/fmri/proj/SSH/BIDS_dataset/code/nochmani-scripts-git/fmri_scripts/5_roi_scripts/1_resample_mask/1b_binarize_resampled_mask_job.m'};
% jobs = repmat(jobfile, 1, nrun);
% inputs = cell(0, nrun);
% for crun = 1:nrun
% end
% spm('defaults', 'FMRI');
% spm_jobman('run', jobs, inputs{:});

% Input files must be in the same folder as this script - otherwise, create
% the full path in ...imcalc.input = ...

%% Binarize at .5 (This threshold looks most similar to the original masks)
matlabbatch{1}.spm.util.imcalc.input = {'1a_resampled_Dorsolateral_L_Z2.nii,1'};
matlabbatch{1}.spm.util.imcalc.output = '1b_binarized_resampled_Dorsolateral_L_Z2';
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = 'i1>.5';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run', matlabbatch) 
clear matlabbatch % clear matlabbatch

matlabbatch{1}.spm.util.imcalc.input = {'1a_resampled_Dorsolateral_R_Z2.nii,1'};
matlabbatch{1}.spm.util.imcalc.output = '1b_binarized_resampled_Dorsolateral_R_Z2';
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = 'i1>.5';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run', matlabbatch) 
clear matlabbatch % clear matlabbatch

matlabbatch{1}.spm.util.imcalc.input = {'1a_resampled_Orbital_Frontal_L_Z0.nii,1'};
matlabbatch{1}.spm.util.imcalc.output = '1b_binarized_resampled_Orbital_Frontal_L_Z0';
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = 'i1>.5';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run', matlabbatch) 
clear matlabbatch % clear matlabbatch

matlabbatch{1}.spm.util.imcalc.input = {'1a_resampled_Orbital_Frontal_R_Z0.nii,1'};
matlabbatch{1}.spm.util.imcalc.output = '1b_binarized_resampled_Orbital_Frontal_R_Z0';
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = 'i1>.5';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run', matlabbatch) 
clear matlabbatch % clear matlabbatch