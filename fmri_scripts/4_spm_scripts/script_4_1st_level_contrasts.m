%% CONFIG
BIDS_DIR = '/Users/fmri/proj/SSH/BIDS_dataset';
FIRST_LEVEL_DIR = fullfile(BIDS_DIR, 'derivatives', 'spm-1st-level');

% The order of the conditions matters.
CONDITIONS = {
    'approach_pos', 'approach_neg', 'avoid_pos', 'avoid_neg', 'baseline'};

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

%% APPLY CONTRASTS TO SPM.mat RESULTS
for i = 1:numel(SUBJECTS)
    subject = SUBJECTS{i};
    sub_dir = append(FIRST_LEVEL_DIR, '/', subject);
    contrasts_filename = append(sub_dir, '/contrasts.csv');
    spm_results_filename = append(sub_dir, '/SPM.mat');

    % Tell the user what is going on:
    disp(append('Applying contrast matrix for subject ', subject, '...'))


    %% Load contrast matrix
    T = readtable(contrasts_filename);

    % Set batch parameters
    matlabbatch{1}.spm.stats.con.spmmat = {spm_results_filename};
    matlabbatch{1}.spm.stats.con.delete = 1;

    %% Loop through each contrast condition

    for j = 1:size(T, 1)
        % select one row of the table
        T_sub = T(j,:);

        contrast_name = T_sub{:,"Contrast"}{1};
        contrast_vector = T_sub{1,2:21};

        disp(append('Applying contrast matrix for subject ', subject, ', contrast: '))
        disp('')
        disp(append('    ', contrast_name))

        matlabbatch{1}.spm.stats.con.consess{j}.tcon.name = contrast_name;
        matlabbatch{1}.spm.stats.con.consess{j}.tcon.weights = contrast_vector;
        matlabbatch{1}.spm.stats.con.consess{j}.tcon.sessrep = 'none';

    end

    % Run the batch!
    spm_jobman('run', matlabbatch)
    clear matlabbatch % clear matlabbatch

    disp(append('Done: Applied contrast matrix for subject ', subject, '.'))

end