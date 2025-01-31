%% CONFIG
BIDS_DIR = '/Users/fmri/proj/SSH/BIDS_dataset';
SCAN_DIR = fullfile(BIDS_DIR, 'derivatives', 'fmriprep-fmap');
FIRST_LEVEL_DIR = fullfile(BIDS_DIR, 'derivatives', 'spm-1st-level');

% Specify the list of subjects you want to process
SUBJECTS = {
    'sub-SD',...
    'sub-KP',...
    'sub-003',...
    'sub-020',...
    'sub-035',...
    'sub-039',...
    'sub-040',...
    'sub-043',...
    'sub-048',...
    'sub-053',...
    'sub-055',...
    'sub-057',...
    'sub-058',...
    'sub-059',...
    'sub-081',...
    'sub-096',...
    'sub-098',...
    'sub-103',...
    'sub-108',...
    'sub-110',...
    'sub-111',...
    'sub-122',...
    'sub-155',...
};
TASK_VAR = 'nochmani';
RUNS = {'1', '2', '3', '4'};



%% Set up and run batch
for i = 1:numel(SUBJECTS)
    disp(['Specifying and estimating 1st-level model for ', SUBJECTS{i}, '...']); 
    
    % Specify directory with functional data
    func_dir = fullfile(SCAN_DIR, SUBJECTS{i}, 'func'); 

    % Find subject's first-level analysis folder
    first_level_dir_sub = fullfile(FIRST_LEVEL_DIR, SUBJECTS{i});
    
    % Set up batch (same for every run)
    matlabbatch{1}.spm.stats.fmri_spec.dir = {first_level_dir_sub};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

    % For each run:

    for j = 1:numel(RUNS)
        % Find path to multiple conditions event file
        multi_fname = strcat(SUBJECTS{i}, '_task-', TASK_VAR, '_run-0', RUNS{j}, '_multiple-conditions.mat' );
        multi_path = fullfile(first_level_dir_sub, multi_fname);

        % Find and select the functional data
        func_run = spm_select('ExtFPList', func_dir, ...
            strcat('smoothed_', SUBJECTS{i}, '*.*', 'task-', TASK_VAR, '_run-0', RUNS{j}, ...
            '_space-MNI152NLin2009cAsym_res-2_desc-preproc_bold.nii') ...
            );
     
        scan_data = cellstr(func_run);
        matlabbatch{1}.spm.stats.fmri_spec.sess(j).scans = scan_data;
        matlabbatch{1}.spm.stats.fmri_spec.sess(j).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(j).multi = {multi_path};
        matlabbatch{1}.spm.stats.fmri_spec.sess(j).regress = struct('name', {}, 'val', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(j).multi_reg = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(j).hpf = 128;

        %disp(func_run)
    end
    % Set other batch parameters
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;

    % SPM: This should be the MNI template brain itself, not the individual's warped
    % brain.
   mask_path = fullfile(BIDS_DIR, 'derivatives', 'templateflow', 'tpl-MNI152NLin2009cAsym_res-02_desc-brain_mask.nii');
    matlabbatch{1}.spm.stats.fmri_spec.mask = {mask_path};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

    % Set up Estimate and Write batch
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    % Run the batch!
    spm_jobman('run', matlabbatch) 
    clear matlabbatch % clear matlabbatch

end