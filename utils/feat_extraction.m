function feat_extraction( featList, micList, poolSize )
% featList = {mfcc_2,...} : list of features 
% micList = {K2L, L1C, ...} : list of microphone 
% poolSize = int : number of parallel Workers

    if isempty(featList)
        error('Feature list is empty.');
    end
    if ( nargin < 2 )
        poolSize = 1;
    end

    format long
    run('path_and_defs.m')

    % parallel computing
    if (poolSize ~= 1)
        p = gcp('nocreate');
        if isempty(p)
            poolsize_opened = 0;
        else
            poolsize_opened = p.NumWorkers;
        end
        if (poolsize_opened == 0)
            parpool(poolSize);
        elseif (poolsize_opened ~= poolSize)
            delete(gcp('nocreate'))
            parpool(poolSize);
        end
    end
    
    % create list dep on micList
    fixedPath = '/media/a3lab/Data/Projects/mVAD/DIRHA_DATASET/info/';
    list = cell(numel(micList),1);
    for i=1:numel(micList)
        if strncmp(micList{i},'K',1)
            %list{i} = [fixedPath,'Simulations_wavfiles_Kitchen_',micList{i},'.txt'];
            list{i} = [fixedPath,'Real_wavfiles_Kitchen_',micList{i},'.txt'];
        elseif strncmp(micList{i},'L',1)
            %list{i} = [fixedPath,'Simulations_wavfiles_Livingroom_',micList{i},'.txt'];
            list{i} = [fixedPath,'Real_wavfiles_Livingroom_',micList{i},'.txt'];
        end
    end


    numFeats = numel(featList);
    for g=1:numel(list)
        % read 
        fid = fopen(list{g},'r');
        waveFiles = textscan(fid,'%s');
        waveFiles = waveFiles{1,1};
        N = numel(waveFiles);
        
        for f=1:numFeats
            base_feat_folder = '/media/a3lab/Data/Projects/mVAD/DIRHA_DATASET/FEATURES/';
            switch featList{f}
                case 'mfcc'
                    disp('mfcc');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%% MFCC12_0_D_A %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    disp('computing MFCC12_0_D_A');
                    smile_conf = '/media/a3lab/Data/Projects/mVAD/feat_extr_code/mfcc/MFCC12_0_D_A.conf';
                    
                    if ~exist(base_feat_folder,'dir')
                        system(['mkdir -p ',base_feat_folder]);
                        addpath(genpath(base_feat_folder));
                    end
                    parfor i=1:N
                        fn_audio = waveFiles{i};
                        [~,name,~] = fileparts(fn_audio);
                        tmp = strsplit(fn_audio,'/');
                        sc_path = strjoin([tmp(9:10),tmp(13)],'/');
                        feat_path = [base_feat_folder,sc_path];
                        if ~exist(feat_path,'dir')
                            system(['mkdir -p ',feat_path]);
                            addpath(genpath(feat_path));
                        end
                        fn_feat = [feat_path,'/',name];
                        [ ~ ] = mfcc_opensmile(smile_conf, fn_audio, fn_feat, 'MFCC12_0_D_A', true);
                    end
                    disp('MFCC12_0_D_A computed.');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                case 'mfcc_2'
                    disp('mfcc_2');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%% MFCC12_0_D_Z %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    disp('computing MFCC12_0_D_Z');
                    smile_conf = '/media/a3lab/Data/Projects/mVAD/feat_extr_code/mfcc/MFCC12_0_D_Z.conf';
                    if ~exist(base_feat_folder,'dir')
                        system(['mkdir -p ',base_feat_folder]);
                        addpath(genpath(base_feat_folder));
                    end
                    parfor i=1:N
                        fn_audio = waveFiles{i};
                        [~,name,~] = fileparts(fn_audio);
                        tmp = strsplit(fn_audio,'/');
                        sc_path = strjoin([tmp(9:10),tmp(13)],'/');
                        feat_path = [base_feat_folder,sc_path];
                        if ~exist(feat_path,'dir')
                            system(['mkdir -p ',feat_path]);
                            addpath(genpath(feat_path));
                        end
                        fn_feat = [feat_path,'/',name];
                        [ ~ ] = mfcc_opensmile(smile_conf, fn_audio, fn_feat, 'MFCC12_0_D_Z', true);
                    end
                    disp('MFCC12_0_D_Z computed.');
                    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                case 'rasta-plp'
                    disp('rasta-plp');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%% RASTAPLP_0_D_A %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    disp('computing RASTAPLP_0_D_A');
                    smile_conf = '/media/a3lab/Data/Projects/mVAD/feat_extr_code/rasta-plp/RASTAPLP_0_D_A.conf';
                    if ~exist(base_feat_folder,'dir')
                        system(['mkdir -p ',base_feat_folder]);
                        addpath(genpath(base_feat_folder));
                    end
                    parfor i=1:N
                        fn_audio = waveFiles{i};
                        [~,name,~] = fileparts(fn_audio);
                        tmp = strsplit(fn_audio,'/');
                        sc_path = strjoin([tmp(9:10),tmp(13)],'/');
                        feat_path = [base_feat_folder,sc_path];
                        if ~exist(feat_path,'dir')
                            system(['mkdir -p ',feat_path]);
                            addpath(genpath(feat_path));
                        end
                        fn_feat = [feat_path,'/',name];
                        [ ~ ] = rastaplp_opensmile(smile_conf, fn_audio, fn_feat, 'RASTAPLP_0_D_A', true);
                    end
                    disp('RASTAPLP_0_D_A computed.');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
                case 'rasta-plp_2'
                    disp('rasta-plp_2');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%% RASTAPLP_0_D_Z %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    disp('computing RASTAPLP_0_D_Z');
                    smile_conf = '/media/a3lab/Data/Projects/mVAD/feat_extr_code/rasta-plp/RASTAPLP_0_D_Z.conf';
                    if ~exist(base_feat_folder,'dir')
                        system(['mkdir -p ',base_feat_folder]);
                        addpath(genpath(base_feat_folder));
                    end
                    parfor i=1:N
                        fn_audio = waveFiles{i};
                        [~,name,~] = fileparts(fn_audio);
                        tmp = strsplit(fn_audio,'/');
                        sc_path = strjoin([tmp(9:10),tmp(13)],'/');
                        feat_path = [base_feat_folder,sc_path];
                        if ~exist(feat_path,'dir')
                            system(['mkdir -p ',feat_path]);
                            addpath(genpath(feat_path));
                        end
                        fn_feat = [feat_path,'/',name];
                        [ ~ ] = rastaplp_opensmile(smile_conf, fn_audio, fn_feat, 'RASTAPLP_0_D_Z', true);
                    end
                    disp('RASTAPLP_0_D_Z computed.');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                case 'pitch'
                    disp('pitch');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Pitch ACF %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    disp('computing Pitch_ACF');
                    smile_conf = '/media/a3lab/Data/Projects/mVAD/feat_extr_code/pitch/prosodyShs.conf';
                    if ~exist(base_feat_folder,'dir')
                        system(['mkdir -p ',base_feat_folder]);
                        addpath(genpath(base_feat_folder));
                    end
                    parfor i=1:N
                        fn_audio = waveFiles{i};
                        [~,name,~] = fileparts(fn_audio);
                        tmp = strsplit(fn_audio,'/');
                        sc_path = strjoin([tmp(9:10),tmp(13)],'/');
                        feat_path = [base_feat_folder,sc_path];
                        if ~exist(feat_path,'dir')
                            system(['mkdir -p ',feat_path]);
                            addpath(genpath(feat_path));
                        end
                        fn_feat = [feat_path,'/',name];
                        [ ~ ] = pitch_opensmile(smile_conf, fn_audio, fn_feat, 'pitch', true);
                    end
                    disp('Pitch_ACF computed.');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                case 'wclpe'
                    disp('wclpe');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%% WC_LPE %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    disp('computing WCLPE');
                    if ~exist(base_feat_folder,'dir')
                        system(['mkdir -p ',base_feat_folder]);
                        addpath(genpath(base_feat_folder));
                    end
                    parfor i=1:N
                        fn_audio = waveFiles{i};
                        [~,name,~] = fileparts(fn_audio);
                        tmp = strsplit(fn_audio,'/');
                        sc_path = strjoin([tmp(9:10),tmp(13)],'/');
                        feat_path = [base_feat_folder,sc_path];
                        if ~exist(feat_path,'dir')
                            system(['mkdir -p ',feat_path]);
                            addpath(genpath(feat_path));
                        end
                        fn_feat = [feat_path,'/',name];
                        [ ~ ] = WC_LPE( fn_audio, fn_feat, 'WCLPE', true);
                    end
                    disp('WCLPE computed.');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                case 'ltsd'
                    disp('ltsd');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%% LTSE-LTSD %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    disp('computing LTSE-LTSD');
                    if ~exist(base_feat_folder,'dir')
                        system(['mkdir -p ',base_feat_folder]);
                        addpath(genpath(base_feat_folder));
                    end
                    parfor i=1:N
                        fn_audio = waveFiles{i};
                        [~,name,~] = fileparts(fn_audio);
                        tmp = strsplit(fn_audio,'/');
                        sc_path = strjoin([tmp(9:10),tmp(13)],'/');
                        feat_path = [base_feat_folder,sc_path];
                        if ~exist(feat_path,'dir')
                            system(['mkdir -p ',feat_path]);
                            addpath(genpath(feat_path));
                        end
                        fn_feat = [feat_path,'/',name];
                        [ ~, ~ ] = LTSD_extract( fn_audio, fn_feat );
                    end
                    disp('LTSE-LTSD computed.');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                case 'ams'
                    disp('ams');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%% AMS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    disp('computing AMS');
                    if ~exist(base_feat_folder,'dir')
                        system(['mkdir -p ',base_feat_folder]);
                        addpath(genpath(base_feat_folder));
                    end
                    parfor i=1:N
                        fn_audio = waveFiles{i};
                        [~,name,~] = fileparts(fn_audio);
                        tmp = strsplit(fn_audio,'/');
                        sc_path = strjoin([tmp(9:10),tmp(13)],'/');
                        feat_path = [base_feat_folder,sc_path];
                        if ~exist(feat_path,'dir')
                            system(['mkdir -p ',feat_path]);
                            addpath(genpath(feat_path));
                        end
                        fn_feat = [feat_path,'/',name];
                        [s,fs] = audioread(fn_audio);
                        nChnl = 9;
                        [ ~ ] = extract_AMS( s, fs, nChnl, fn_feat);
                    end
                    disp('AMS computed.');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                case {'evm','evm_wh'}
                    disp('evm');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%% EVM %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    disp('computing EVM');
                    if ~exist(base_feat_folder,'dir')
                        system(['mkdir -p ',base_feat_folder]);
                        addpath(genpath(base_feat_folder));
                    end
                    parfor i=1:N
                        fn_audio = waveFiles{i};
                        [~,name,~] = fileparts(fn_audio);
                        tmp = strsplit(fn_audio,'/');
                        sc_path = strjoin([tmp(9:10),tmp(13)],'/');
                        feat_path = [base_feat_folder,sc_path];
                        if ~exist(feat_path,'dir')
                            system(['mkdir -p ',feat_path]);
                            addpath(genpath(feat_path));
                        end
                        fn_feat = [feat_path,'/',name];
                        win = 40;
                        bands = 40;
                        [~] = EVM_extract( fn_audio, fn_feat, 'EVM', bands, win );
                    end
                    %     EVM_norm = zeros(size(tmp2{1},1),2);
                    %     
                    %     for f=1:size(tmp2{1},1)
                    %         cross_band = [];
                    %         for ch=1:2
                    %             cross_band = [cross_band, tmp2{ch}(f,:)'];
                    %         end
                    %         maximums = max(cross_band,[],2);
                    %         tmp_norm = cross_band ./ repmat(maximums, 1, ch);
                    %         
                    %         for ch=1:2
                    %             tmp2{2,ch}(f,:) = tmp_norm(:,ch)';
                    %         end
                    %         for ch=1:2
                    %             EVM_norm(f,ch) = sum(tmp_norm(:,ch));
                    %         end
                    %         %[~,C(f)] = max( tmp2 ); 
                    %     end
                    disp('EVM computed.');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                case 'pncc'
                    disp('pncc');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%% PNCC12_0_D_Z %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    disp('computing PNCC12_0_D_Z');
                    if ~exist(base_feat_folder,'dir')
                        system(['mkdir -p ',base_feat_folder]);
                        addpath(genpath(base_feat_folder));
                    end
                    parfor i=1:N
                        fn_audio = waveFiles{i};
                        [~,name,~] = fileparts(fn_audio);
                        tmp = strsplit(fn_audio,'/');
                        sc_path = strjoin([tmp(9:10),tmp(13)],'/');
                        feat_path = [base_feat_folder,sc_path];
                        if ~exist(feat_path,'dir')
                            system(['mkdir -p ',feat_path]);
                            addpath(genpath(feat_path));
                        end
                        fn_feat = [feat_path,'/',name];
                        [ ~ ] = PNCC_extract( fn_audio, fn_feat, 'PNCC12_0_D_Z' );
                    end
                    disp('PNCC12_0_D_Z computed.');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		case 'logmel'
                    disp('logmel');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%% LOGMEL40 %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    disp('computing LOGMEL40');
		    smile_conf = '/media/a3lab/Data/Projects/mVAD/feat_extr_code/logmel/40logmel.conf';


                    if ~exist(base_feat_folder,'dir')
                        system(['mkdir -p ',base_feat_folder]);
                        addpath(genpath(base_feat_folder));
                    end
                    parfor i=1:N
                        fn_audio = waveFiles{i};
                        [~,name,~] = fileparts(fn_audio);
                        tmp = strsplit(fn_audio,'/');
                        sc_path = strjoin([tmp(9:10),tmp(13)],'/');
                        feat_path = [base_feat_folder,sc_path];
                        if ~exist(feat_path,'dir')
                            system(['mkdir -p ',feat_path]);
                            addpath(genpath(feat_path));
                        end
                        fn_feat = [feat_path,'/',name];
                        [ ~ ] = logmel_opensmile( fn_audio, fn_feat, 'PNCC12_0_D_Z' );
                    end
                    disp('LOGMEL40 computed.');
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end % end switch
            
        end % end for each feat
           
    end % end for each mic
    delete(gcp('nocreate'))
end
