%% Conbine marsbar results into a table
% Marsbar results are created with the marsbar GUI:
% (0) Prepare roi.mat files rom nifti ROI files, using "ROI definition"
% (1) Design > Set design from file (select SPM.mat file from a second level contrast) 
% (2) Data > Extract ROI data (default)
% (Select the four roi.mat ROI files -- remember their order)
% (3) Results > Estimate Results
% (4) Results > Save results to file


% Init results table
output_table = table('Size', [0, 8], ...
    'VariableTypes', {'string', 'string', 'string', 'string', 'string', 'string', 'double', 'double'}, ...
    'VariableNames', {'Subject', 'ROI', 'Region', 'Side', 'Contrast', 'Con_Short', 'Mean_Value', 'Asymmetry_Score'});

% Specify subjects (in the order they appear in the SPM.mat design)
SUBJECTS = {'sub-SD', 'sub-KP', 'sub-003', 'sub-020', 'sub-039', 'sub-035', 'sub-040', ...
            'sub-043', 'sub-048', 'sub-053', 'sub-055', 'sub-057', 'sub-058', 'sub-059', ...
            'sub-081', 'sub-096', 'sub-098', 'sub-103', 'sub-108', 'sub-110', 'sub-111', ...
            'sub-122', 'sub-155'}; 

% Order of regions as selected in marsbar:
% '1b_binarized_resampled_Dorsolateral_L_Z2_marsbar_1_roi.mat'
% '1b_binarized_resampled_Dorsolateral_R_Z2_marsbar_1_roi.mat'
% '1b_binarized_resampled_Orbital_Frontal_L_Z0_marsbar_1_roi.mat'
% '1b_binarized_resampled_Orbital_Frontal_R_Z0_marsbar_1_roi.mat'
ROI_INFO = { ...
    'Dorsolateral', 'Left'; ...
    'Dorsolateral', 'Right'; ...
    'Orbital Frontal', 'Left'; ...
    'Orbital Frontal', 'Right'; ...
};


% Define contrast labels (copied from
% script_5_2nd_level_contrasts_righties.m)
CON_SHORT = {
    'con-01'; 'con-02';
    'con-03'; 'con-04';
    'con-05'; 'con-06';
    'con-07'; 'con-08';
    'con-09'; 'con-10';
    'con-11'; 'con-12';
    'con-13'; 'con-14';
    'con-15'; 'con-16';
    'con-17'; 'con-18';
    'con-19'; 'con-20';
    'con-21'; 'con-22';
    'con-23'; 'con-24';
    };
CON_LABEL = {'approach > baseline'; 'approach < baseline';
    'avoid > baseline'; 'avoid < baseline';
    'approach > avoid'; 'approach < avoid';
    'approach-pos > avoid-neg'; 'approach-pos < avoid-neg';
    'approach-neg > avoid-pos'; 'approach-neg < avoid-pos';
    'pos > baseline'; 'pos < baseline';
    'neg > baseline'; 'neg < baseline';
    'pos > neg'; 'pos < neg';
    'approach-pos > baseline'; 'approach-pos < baseline';
    'approach-neg > baseline'; 'approach-neg < baseline';
    'avoid-pos > baseline'; 'avoid-pos < baseline';
    'avoid-neg > baseline'; 'avoid-neg < baseline';
    };



RESULTS_DIR = 'results';
% TODO: loop through contrasts

for con_idx = 1:numel(CON_LABEL)

    %load('results_scaled/con-01_mres.mat')
    load(strcat(RESULTS_DIR, '/', CON_SHORT{con_idx}, '_mres.mat'));
    
    regions = SPM.marsY.regions;
    results = SPM.marsY.Y;
    
    for subject_idx = 1:numel(SUBJECTS)
        for roi_idx = 1:numel(regions)
      
            % Add data to table
            new_row = table( ...
                string(SUBJECTS{subject_idx}), ... % Subject
                string(regions{roi_idx}.name), ... % ROI
                string(ROI_INFO{roi_idx,1}), ... % Region
                string(ROI_INFO{roi_idx,2}), ... % Side
                string(CON_LABEL{con_idx}), ... % Contrast
                string(CON_SHORT{con_idx}), ... % Contrast (short)
                results(subject_idx, roi_idx), ... % VSummary value
                NaN, ... % Asymmetry_Score
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


%% SAVE RESULTS
output_file = fullfile(strcat('roi_scores_marsbar.csv'));
writetable(output_table, output_file);
disp(['Asymmetry scores saved to ', output_file]);
