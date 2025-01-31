function [contrast_names, contrast_vectors] = add_contrast(contrast_name, vec_run_template, contrast_names, contrast_vectors, empty_column_adjuster)
% Calculate contrast vector add it to the matrix.
%   First, create the 1x20 vector from template.
%   Then, multiple by empty_column adjuster to set emtpy columns to zero.
%   Then, count positive 1s and negative 1s. Divide each 1 or -1 by the total
%   number.

    vec_unadjusted = repmat(vec_run_template, 1, 4);
    vec_adjusted = adjust_vec(vec_unadjusted, empty_column_adjuster);
    
    contrast_names = cat(1, contrast_names, contrast_name);
    contrast_vectors = cat(1, contrast_vectors, vec_adjusted);

end