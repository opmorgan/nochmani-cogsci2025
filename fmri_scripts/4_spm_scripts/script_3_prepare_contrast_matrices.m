%% Prepare contrast matrices for each subject
% These will then be used to calculate contrasts from 1st level models in
% script_4_contrasts.m

% Depends on functions:
% lib_3_contrasts/import_multiple_conditions.m
% lib_3_contrasts/adjust_vec.m


%% SET CONTRASTS PROGRAMMATICALLY
% Goal: specify contrast vectors, accounting for empty columns
%       (e.g.,sub-003 has no approach-pos blocks in run-03).
%       - positive weights should sum to one; negative weights to negative one.
%       - empty columns should have weight zero.

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
    'sub-155',
};

for n = 1:length(SUBJECTS)
    subject = SUBJECTS{n};
    sub_dir = append(FIRST_LEVEL_DIR, '/', subject);
    contrasts_filename = append(sub_dir, '/contrasts.csv');

    % Tell the user what is going on:
    disp(append('Creating contrast matrix for subject ', subject, '...'))

    %% First, find the number of onsets of each condition, across runs
    % Goal: Given a subject's multiple_condisions.mat files,
    % Create a structure with 1x4 vectors showing the number of onsets in each
    % condition, in each run, like the following (for sub-003):
    % n_onsets.('approach_pos') =     [1, 3, 0, 4]; % [run-01, run-02, ...04]
    % n_onsets.('approach_neg') =     [1, 2, 4, 1];
    % n_onsets.('avoid_pos') =        [3, 2, 2, 1];
    % n_onsets.('avoid_neg') =        [3, 1, 2, 2];
    % n_onsets.('baseline') =         [8, 8, 8, 8];

    % Load condition names and onsets for each run
    % Depends on function: lib_3_contrasts/import_multiple_conditions.m
    filename = cell(1,4);
    multiple_conditions = cell(1, 4);
    for run_number = 1:4
        filename{run_number} = append(sub_dir, '/', subject, ...
            '_task-nochmani_run-0', string(run_number), '_multiple-conditions.mat');
        names = cell(1, 5); % Pre-allocate
        onsets = cell(1,5);
        import_multiple_conditions(filename{run_number})

        % Replace 999 with empty vector
        for nameIdx = 1:size(onsets,2)
            if isequal(onsets{nameIdx}, 999)
                disp(append('--Editing condition with no onsets: ', ...
                    subject, ', run-', string(run_number), ', ', names{nameIdx}))
                onsets{nameIdx} = [];
                disp(append('--Replaced 999 with an empty vector.'))
            end
        end

        multiple_conditions{run_number} = {names, onsets};
    end

    % Pre-allocate onset count vectors
    for i = 1:length(CONDITIONS)
        n_onsets.(CONDITIONS{i}) = zeros(1,4);
    end

    % Count onsets of each condition, in each run
    for run_number = 1:4
        for f = 1:length(CONDITIONS)
            cond_onsets = multiple_conditions{run_number}{2}{f}; % onsets (2), e.g: approach-pos (1)
            n_onsets.(CONDITIONS{f})(run_number) = length(cond_onsets);
        end
    end

    %% For each condition, calculate the total number of columns with at least one (non-empty) onset
    n_cols = struct;
    for i = 1:length(CONDITIONS)
        n_cols.(CONDITIONS{i}) = length(nonzeros(n_onsets.(CONDITIONS{i})));
    end

    %% Create vector that will adjust empty columns to zero
    % For each condition, make an index of which columns should be set to zero:
    runs_with_zero = struct;
    for i = 1:length(CONDITIONS)
        zero_idx = find(~n_onsets.(CONDITIONS{i}));
        % Replace empty doubles with []
        if isempty(zero_idx)
            zero_idx = [];
        end
        runs_with_zero.(CONDITIONS{i}) = zero_idx;
    end

    cols_to_zero = struct;
    for i = 1:length(CONDITIONS)

        cols_to_zero.(CONDITIONS{i}) = zeros(1,length(runs_with_zero.(CONDITIONS{i})));
        if isempty(cols_to_zero.(CONDITIONS{i}))
            cols_to_zero.(CONDITIONS{i}) = [];
        end

        % loop through runs_with_zero, in case multiple runs share an empty
        % condition
        for j = 1:length(runs_with_zero.(CONDITIONS{i}))
            cols_to_zero.(CONDITIONS{i}) = (runs_with_zero.(CONDITIONS{i}) - 1)  * length(CONDITIONS) + i;
        end
    end

    % Prepare vector multiplier to set values in missing columns to zero:
    % (1) Concatenate all of the vectors in cols_to_zero (the index of which
    % columns should be zero'd in each run).
    % (2) Make a vector of length 20, of 1's
    % (3) Replace 1's with zeros at the indices in the concatenated vector
    % This vector will be multiplied with the raw contrast vector to adjust it.
    idx_to_zero = [];
    for i = 1:length(CONDITIONS)
        idx_to_zero = cat(2, idx_to_zero, cols_to_zero.(CONDITIONS{i}));
    end

    idx_to_zero = sort(idx_to_zero);
    ones_vec = ones(1, 20);
    empty_column_adjuster = ones_vec;
    empty_column_adjuster(idx_to_zero) = 0;

    %% Initialize a table (or cell array?) to store contrast info.
    contrast_names = [];
    TABLE_LABELS = [
        "Contrast"
        append("R1_", CONDITIONS{1})
        append("R1_", CONDITIONS{2})
        append("R1_", CONDITIONS{3})
        append("R1_", CONDITIONS{4})
        append("R1_", CONDITIONS{5})
        append("R2_", CONDITIONS{1})
        append("R2_", CONDITIONS{2})
        append("R2_", CONDITIONS{3})
        append("R2_", CONDITIONS{4})
        append("R2_", CONDITIONS{5})
        append("R3_", CONDITIONS{1})
        append("R3_", CONDITIONS{2})
        append("R3_", CONDITIONS{3})
        append("R3_", CONDITIONS{4})
        append("R3_", CONDITIONS{5})
        append("R4_", CONDITIONS{1})
        append("R4_", CONDITIONS{2})
        append("R4_", CONDITIONS{3})
        append("R4_", CONDITIONS{4})
        append("R4_", CONDITIONS{5})
        ]';

    contrast_vectors = [];

    % Create contrast vectors:
    %
    % Build each contrast vector with empty column adjustment,
    % scaling positive and negative values to sum to one.
    %
    % Order:
    % [approach-pos, approach-neg, avoid-pos, avoid-neg, baseline]
    %

    %
    [contrast_names, contrast_vectors] = add_contrast( ...
        "approach > baseline", [1 1 0 0 -1], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "approach < baseline", [-1 -1 0 0 1], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "avoid > baseline", [0 0 1 1 -1], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "avoid < baseline", [0 0 -1 -1 1], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "approach > avoid", [1 1 -1 -1 0], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "approach < avoid", [-1 -1 1 1 0], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    %
    [contrast_names, contrast_vectors] = add_contrast( ...
        "approach-pos > avoid-neg", [1 0 0 -1 0], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "approach-pos < avoid-neg", [-1 0 0 1 0], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "approach-neg > avoid-pos", [-1 1 0 0 0], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "approach-neg < avoid-pos", [1 -1 0 0 0], ...
        contrast_names, contrast_vectors, empty_column_adjuster);


    %
    [contrast_names, contrast_vectors] = add_contrast( ...
        "pos > baseline", [1 0 1 0 -1], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "pos < baseline", [-1 0 -1 0 1], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "neg > baseline", [0 1 0 1 -1], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "neg < baseline", [0 -1 0 -1 0], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "pos > neg", [1 -1 1 -1 0], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "pos < neg", [-1 1 -1 1 0], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    %
    [contrast_names, contrast_vectors] = add_contrast( ...
        "approach-pos > baseline", [1 0 0 0 -1], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "approach-pos < baseline", [-1 0 0 0 1], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "approach-neg > baseline", [0 1 0 0 -1], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "approach-neg < baseline", [0 -1 0 0 1], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "avoid-pos > baseline", [0 0 1 0 -1], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "avoid-pos < baseline", [0 0 -1 0 1], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "avoid-neg > baseline", [0 0 0 1 -1], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    [contrast_names, contrast_vectors] = add_contrast( ...
        "avoid-neg < baseline", [0 0 0 -1 1], ...
        contrast_names, contrast_vectors, empty_column_adjuster);

    %% Write a table recording the contrast matrix

    T = array2table(contrast_vectors);
    T.Properties.VariableNames(1:20) = TABLE_LABELS(2:21);
    T.Properties.RowNames(1:24) = contrast_names;
    T.Properties.DimensionNames(1) = "Contrast";

    disp(append('Saved contrast matrix as: ', contrasts_filename))
    writetable(T, contrasts_filename, 'WriteRowNames',true)

end

