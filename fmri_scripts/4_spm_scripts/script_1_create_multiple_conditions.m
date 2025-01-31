%% Create .mat file specifying "multiple conditions" for SPM12 first-level analyses
BIDS_DIR = '/Users/fmri/proj/SSH/BIDS_dataset';
FIRST_LEVEL_DIR = fullfile(BIDS_DIR, "derivatives", "spm-1st-level");

% Loop through subjects, runs
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
task_var = 'nochmani';

for sub_idx = 1:length(SUBJECTS)
    sub_var = SUBJECTS{sub_idx};
    
    disp(append('Creating multiple conditions event specification file for subject ', sub_var, '...'));

    % Define input and output directories
    bids_func_dir = fullfile(BIDS_DIR, sub_var, 'func');
    output_dir = fullfile(FIRST_LEVEL_DIR, sub_var);

    % Make input and output directories, if they don't exist already
    if ~exist(bids_func_dir, 'dir') 
            mkdir(bids_func_dir); 
    end
    if ~exist(output_dir, 'dir') 
            mkdir(output_dir);
    end


    RUN_LABELS = {'01', '02', '03', '04'};
    %%
    for run_idx = 1:length(RUN_LABELS)
        % DEBUG: check run_idx 01 (all conditions) and 03 (Missing
        % approach-pos)
        run_var = RUN_LABELS{run_idx};

        % Define output filename
        output_filename = append(sub_var, '_task-', task_var, ...
            '_run-', run_var, '_multiple-conditions');
        output_path = append(output_dir, "/", output_filename);

        % Load events file
        events_tsv_filename = append(sub_var, "_task-", task_var, ...
            "_run-", run_var, "_events.tsv");
        events_tsv_path = append(bids_func_dir, "/", events_tsv_filename);

        % Load events.tsv as an array with three cells:
        fileID = fopen(events_tsv_path);
        events_array = textscan(fileID, '%s %f %f', 'HeaderLines', 1);

        % TODO: handle the case where one condition is missing.
        % Use a hard-coded conditions list, instead of getting it from
        % events_array.

        NAMES = {'approach-pos', 'approach-neg', 'avoid-pos', 'avoid-neg', 'baseline'};

        T = events_array;

        names = NAMES;
        onsets = cell(1, size(NAMES,2));
        durations = cell(1, size(NAMES,2));

        sizeOnsets = size(T{2}, 1);
        for nameIdx = 1:size(NAMES,2)
            for idx = 1:sizeOnsets
                if isequal(T{1}{idx}, NAMES{nameIdx})
                    onsets{nameIdx} = double([onsets{nameIdx} T{2}(idx)]);
                    durations{nameIdx} = double([durations{nameIdx} T{3}(idx)]);
                end
            end
        end

        % Workaround to get 1st level spec to handle conditions with no onsets:
        % Set onset equal to 999 (after run), duration equal to 0 (greater than total
        % duration)
        % Be sure to model this condition as "0" in first level spec,
        % adjusting other weights accordingly (so they sum to 1)

        % (E.g., for sub-003, run-03, "approach-pos" has no onsets).
        for nameIdx = 1:size(NAMES,2)
            if isequal(onsets{nameIdx}, [])
                disp(append('    Editing condition with no onsets: ', ...
                    sub_var, ', run-', run_var, ', ', NAMES{nameIdx}))
                %disp(append('    Workaround for first level spec: set onset to 999, duration to 0'))
                onsets{nameIdx} = 999;
                durations{nameIdx} = 0;
            end

        end
        
        save(output_path,'names', 'onsets', 'durations')
    end
    disp(append('Done. (', sub_var, ')'));
    disp('');
end
