%% CONFIGURATION
% Define paths
BIDS_DIR = '/Users/fmri/proj/SSH/BIDS_dataset'; % Base BIDS directory
FIRST_LEVEL_DIR = fullfile(BIDS_DIR, 'derivatives', 'spm-1st-level', 'righties');

% Define subject list
SUBJECTS = {'sub-SD', 'sub-KP', 'sub-003', 'sub-020', 'sub-039', 'sub-035', 'sub-040', ...
            'sub-043', 'sub-048', 'sub-053', 'sub-055', 'sub-057', 'sub-058', 'sub-059', ...
            'sub-081', 'sub-096', 'sub-098', 'sub-103', 'sub-108', 'sub-110', 'sub-111', ...
            'sub-122', 'sub-155'};

% Define ROI files and metadata
ROI_FILES = { ...
    '../1_resample_mask/1b_binarized_resampled_Dorsolateral_L_Z2.nii', ...
    '../1_resample_mask/1b_binarized_resampled_Dorsolateral_R_Z2.nii', ...
    '../1_resample_mask/1b_binarized_resampled_Orbital_Frontal_L_Z0.nii', ...
    '../1_resample_mask/1b_binarized_resampled_Orbital_Frontal_R_Z0.nii', ...
    
}; % List of ROI masks
roi_info = { ...
    'Dorsolateral', 'Left'; ...
    'Dorsolateral', 'Right'; ...
    'Orbital Frontal', 'Left'; ...
    'Orbital Frontal', 'Right'; ...
};

% Predefine the table
output_table = table('Size', [0, 7], ...
    'VariableTypes', {'string', 'string', 'string', 'string', 'string', 'double', 'double'}, ...
    'VariableNames', {'Subject', 'ROI', 'Region', 'Side', 'Contrast', 'Mean_Value', 'Asymmetry_Score'});

%% PROCESS SUBJECTS
for subj_idx = 1:numel(SUBJECTS)
    subject = SUBJECTS{subj_idx};
    subj_dir = fullfile(FIRST_LEVEL_DIR, subject);
    contrasts_file = fullfile(subj_dir, 'contrasts.csv');
    spm_results_file = fullfile(subj_dir, 'SPM.mat');

    % Check if necessary files exist
    if ~exist(contrasts_file, 'file') || ~exist(spm_results_file, 'file')
        warning(['Missing files for subject ', subject, '. Skipping...']);
        continue;
    end

    % Read contrasts
    try
        T = readtable(contrasts_file);
    catch
        warning(['Failed to read contrasts file for subject ', subject]);
        continue;
    end

    % Process each contrast
    for contrast_idx = 1:height(T)
        contrast_path = fullfile(subj_dir, sprintf('spmT_%04d.nii', contrast_idx));
        if ~exist(contrast_path, 'file')
            warning(['Missing contrast file: ', contrast_path]);
            continue;
        end

        % Process each ROI
        for roi_idx = 1:numel(ROI_FILES)
            roi_path = ROI_FILES{roi_idx};
            if ~exist(roi_path, 'file')
                warning(['ROI file does not exist: ', roi_path]);
                continue;
            end

            % Load ROI and extract data
            try
                Y = spm_read_vols(spm_vol(roi_path));
            catch ME
                warning(['Failed to load ROI file: ', roi_path]);
                disp(getReport(ME)); % Log detailed error
                continue;
            end

            % Extract voxels from the ROI
            indx = find(Y > 0);
            if isempty(indx)
                warning(['No voxels found in ROI: ', roi_path]);
                continue;
            end
            [x, y, z] = ind2sub(size(Y), indx);
            XYZ = [x y z]';

            % Extract data from contrast file
            try
                contrast_data = spm_get_data(spm_vol(contrast_path), XYZ);
            catch ME
                warning(['Failed to load contrast file: ', contrast_path]);
                disp(getReport(ME)); % Log detailed error
                continue;
            end

            % Calculate mean activation
            mean_value = mean(contrast_data, 'omitnan');

            % Add data to table
            new_row = table( ...
                string(subject), ...
                string(roi_path), ...
                string(roi_info{roi_idx, 1}), ...
                string(roi_info{roi_idx, 2}), ...
                string(T.Contrast{contrast_idx}), ...
                mean_value, ...
                NaN, ...
                'VariableNames', output_table.Properties.VariableNames);
            output_table = [output_table; new_row]; % Append row
        end
    end
end

%% CALCULATE ASYMMETRY SCORES
subjects = unique(output_table.Subject);
contrasts = unique(output_table.Contrast);

% Add asymmetry scores for each region
for i = 1:numel(subjects)
    for j = 1:numel(contrasts)
        for region = unique(output_table.Region)'
            region_var = region{1};
            rows = strcmp(output_table.Subject, subjects{i}) & ...
                   strcmp(output_table.Contrast, contrasts{j}) & ...
                   strcmp(output_table.Region, region_var);

            left_value = output_table.Mean_Value(rows & strcmp(output_table.Side, 'Left'));
            right_value = output_table.Mean_Value(rows & strcmp(output_table.Side, 'Right'));

            if ~isempty(left_value) && ~isempty(right_value)
                asymmetry_score = (left_value - right_value) / (left_value + right_value);
                output_table.Asymmetry_Score(rows & strcmp(output_table.Side, 'Left')) = asymmetry_score;
                output_table.Asymmetry_Score(rows & strcmp(output_table.Side, 'Right')) = asymmetry_score;
            end
        end
    end
end

%% REMOVE INVALID ROWS
% Identify rows with missing or invalid values
valid_rows = ~isnan(output_table.Mean_Value) & ~isnan(output_table.Asymmetry_Score);
output_table = output_table(valid_rows, :);

%% SAVE RESULTS
output_file = fullfile('roi_scores_t.csv');
writetable(output_table, output_file);
disp(['Asymmetry scores saved to ', output_file]);
