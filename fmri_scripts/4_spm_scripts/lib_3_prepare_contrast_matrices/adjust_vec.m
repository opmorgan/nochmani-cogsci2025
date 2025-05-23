%% Build contrast vector with empty column adjustment, scaling positive and negative values to sum to one
% First, create the 1x20 vector from template.
% Then, multiple by empty_column adjuster to set emtpy columns to zero.
% Then, count positive 1s and negative 1s. Divide each 1 or -1 by the total
% number.

function vec_adjusted = adjust_vec(vec_unadjusted, empty_column_adjuster)
    % Given an unadjusted contrast vector and an empty column adjustment
    % vector,
    % Create adjusted contrast vector.
    % (Set empty columns to zero, scale positive and negative numbers to
    % sum to one)
    % 
    % Input: vec_run_unadjusted, empty_column_adjuster
    % Output: vec_run_adjusted

    vec_adjusted = vec_unadjusted .* empty_column_adjuster;

    % Count positive and negative weights.
    n_pos = nnz(vec_adjusted == 1);
    n_neg = nnz(vec_adjusted == -1);
    % Divide each "1" by n_pos; each "-1" by n_neg
    for i = 1:length(vec_adjusted)
        if vec_adjusted(i) == 1
            vec_adjusted(i) = double(vec_adjusted(i)) / double(n_pos);
        elseif vec_adjusted(i) == -1
            vec_adjusted(i) = double(vec_adjusted(i)) / double(n_neg);
        end
    end
      
    % Round to match output from SPM GUI
    vec_adjusted = round(vec_adjusted, 15);

end