function [ hyp_file ] = create_hyp( predictions, fs, savedir, hypFolder, outfn )

    if nargin < 4
        hypFolder = './hyp/';
    end
    if nargin < 5
        outfn = 'output';
    end
    
    % folder
    folder = [hypFolder,savedir];
    if ~exist(folder,'dir')
        system(['mkdir -p ',folder]);
    end
    
    hyp_file = [folder,outfn,'.hyp'];
    
    if ~exist(hyp_file,'file')
        f = fopen(hyp_file,'w');

        N = length(predictions);
        for i = 1:N
            if (predictions(i) == 1)
                fprintf(f,'%4.6f 0 0 0\n',i/fs);
            end
        end

        fclose(f);
    end
end

