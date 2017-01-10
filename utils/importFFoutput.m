function [ preds ] = importFFoutput( csv )

    f = fopen(csv,'r');
    
    if f < 0
        disp('ERROR: reading file');
    end
    
    line = fgetl(f);
    
    preds = [];
    
    i=0;
    
    while ischar(line)
        i = i+1;
        
        tmp = [];
        str_ = strsplit(line,';');
        str_(1) = []; % remove seqTag
        tmp = str2double(str_);
        
        % preds = [preds, tmp'];
        preds{i} = tmp';
        
        % next line
        line = fgetl(f);
    end
    
    
    fclose(f);


end

