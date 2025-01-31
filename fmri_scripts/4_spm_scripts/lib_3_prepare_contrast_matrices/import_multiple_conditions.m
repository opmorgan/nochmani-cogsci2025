function import_multiple_conditions(multiple_conditions_file)
%IMPORTFILE(FILETOREAD1)
%  Imports data from the specified file
%  FILETOREAD1:  file to read

    % Import the file
    newData1 = load('-mat', multiple_conditions_file);
    
    % Create new variables in the base workspace from those fields.
    vars = fieldnames(newData1);
    for i = 1:length(vars)
        assignin('base', vars{i}, newData1.(vars{i}));
    end
end