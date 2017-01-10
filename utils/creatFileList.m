function creatFileList( out_filename, hyp_file, ref_file, out_file, sum_file, append_ )
    
    if nargin < 6
        append_ = true;
    end
    
    % template
    % .hyp file   .ref file   .out file   .sum file
    if append_
        fout = fopen(out_filename,'a'); % fileList.txt
    else
        fout = fopen(out_filename,'w'); % fileList.txt
    end
    
    fprintf(fout,[hyp_file,' ',ref_file,' ',out_file,' ',sum_file,'\n']);
    

    fclose(fout);
end

