function my_cell2csv(fileName, tags, cellArray, separator)
% Writes cell array content into a *.csv file.


%% Write file
fid = fopen(fileName, 'w');

for col=1:numel(cellArray)

    var = eval(['cellArray{col}']);

    if isnumeric(var)
        var = num2str(var);
    end

    % TAG value
    fprintf(fid, '%s', tags{col});
    fprintf(fid, separator);

    for idx = 1:size(var,1)
        % OUTPUT value
        fprintf(fid, '%s', var(idx,:));

        % OUTPUT separator
        if idx ~= size(var,1)
            fprintf(fid, separator);
        else
            if col ~= numel(cellArray) % prevent a empty line at EOF
                % OUTPUT newline
                fprintf(fid, '\n');
            end
        end
    end

end
    

% Closing file
fclose(fid);
% END