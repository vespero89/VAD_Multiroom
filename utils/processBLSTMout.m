function processBLSTMout( csv, th, base_dir, dataset, room, tags, fs, is1net2rooms )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
        
    if (nargin < 8)
        is1net2rooms = false;
    end
    
    data = importFFoutput( csv );
    
    if (is1net2rooms)
        classes = 4;
        kit_sp = cell(1,size(data,2));
        liv_sp = cell(1,size(data,2));
        for seq=1:size(data,2)
            tmp = reshape(data(:,seq),classes,size(data(:,seq),1)/classes)';
            kit_sp{seq} = data{seq}(:,3) + data{seq}(:,4);
            liv_sp{seq} = data{seq}(:,2) + data{seq}(:,4);
        end
        
        % write csv file
        my_cell2csv([csv(1,end-5),'K.csv'], tags, kit_sp,';');
        my_cell2csv([csv(1,end-5),'L.csv'], tags, liv_sp,';')
         
        
    end
    
    for i=1:length(tags)
        
        % load label
        % label = ['..' filesep 'dataset_features' filesep dataset filesep scene num2str(k) filesep room filesep 'label.htk'];
        
        
        % post-proc
        %th = 0.5;
        predictions = hangover( data {i}, th );
        
        
        % plot
        %subplot(size(data,2),1,i)
        %plot(data(:,i),'b'); hold all; plot(sim_K_label(:,i),'k-'); plot(predictions(:,i),'g');
        
        
        % SAD
        savedir = ['out_',num2str(th), filesep, room, filesep, tags{i}, filesep];
        hyp_filename = create_hyp( predictions, fs, savedir, base_dir );
        [path,name,~] = fileparts(hyp_filename);
        out_filename = [path, filesep, name, '.out'];
        sum_filename = [path, filesep, name, '.sum'];
        
        ref_filename = [getenv('EVALITA_DEV'), filesep, dataset, filesep, tags{i}, filesep, 'Additional_info', filesep, room, '.ref'];
        
        creatFileList( [base_dir,'fileList_',num2str(th),'.txt'], hyp_filename, ref_filename, out_filename, sum_filename );
    end


end

