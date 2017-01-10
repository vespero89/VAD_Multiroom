%VAD EVALUATION SCRIPT -- 2015 VERSION
clear;
close all;
clc;

format long
run('./path_and_defs.m')

% read and parse conf files;
conf_files = strsplit(ls('../conf_files/TEST_FABIO2.conf'));
conf_files = sort(conf_files(1:end-1))'

for cf = 1:numel(conf_files)
    %% Parse Conf File
    conf_file = conf_files{cf}
    verbose = true;
    args = parseConfFile( conf_file, verbose );
    
    %% feat loading -> supports multiple mics
    if strcmp(args.dataset,'Real')
        N = 22; % tot scenes
        filename = 'real';
    elseif strcmp(args.dataset,'Simulations')
        N = 80;
        filename = 'sim';
    end
    %% file handling: supported: Leave-One-Out, k-fold crossvalidaiton, fixed percentage
    rand = false;
    
    [ train_idxs, val_idxs, test_idxs ] = IndexGen_2015( args, N, rand);
    
    nmics = numel(args.mics);
    feat_struct = cell(N,2);
    feat_dir = getenv('DATASET_DEV');
    for i = 1:N
        pre_path = [feat_dir,filesep,args.dataset,filesep,filename,num2str(i),filesep];
        if ~exist(pre_path,'dir')
            error([pre_path, '  --- not exist!!!']);
        end
        matr = [];
        for j=1:nmics
            name = args.mics{j};
            if strncmp(name,'K',1)
                mic_room = 'Kitchen';
            elseif strncmp(name,'L',1)
                mic_room = 'Livingroom';
            end
            if isfield(args,'normBefore')
                normBefore = args.normBefore;
            else
                normBefore = false;
            end
            format_ = 'htk'; %% format = 'mat';
            [tmp_matr, acronym] = feat_loading( args.features_list, [pre_path,mic_room,filesep,name], format_, normBefore );
            matr = [matr, tmp_matr];
            clear tmp_matr
        end
        tmp.scene = [filename,num2str(i)];
        tmp.mics = args.mics;
        if (strcmp(args.room,'1net2rooms'))
            tmp.room = 'A';
        else
            tmp.room = args.room(1);
        end
        tmp.acronym = acronym;
        feat_struct{i,1} = tmp;
        feat_struct{i,2} = matr;
    end
    clear tmp pre_path name matr mic_room nmics i j
    %% label loading
    ref_Liv = 'Livingroom.ref';
    ref_Kit = 'Kitchen.ref';
    if (~strcmp(args.room,'1net2rooms'))
        
        for i = 1:N
            path = [getenv('EVALITA_DEV'),filesep,args.dataset,filesep,filename,num2str(i),filesep];
            if strcmp(args.room,'Livingroom')
                ref_filename = [path,'Additional_info',filesep,ref_Liv];
            elseif strcmp(args.room,'Kitchen')
                ref_filename = [path,'Additional_info',filesep,ref_Kit];
            end
            L = size(feat_struct{i,2},1);
            tmp.ref_filename = ref_filename;
            tmp.size = L;
            label_struct{i,1} = tmp;
            label_struct{i,2} = labelLoad( ref_filename, L );
        end
        clear N L i nPools rand ref_Kit ref_Liv ureParallel tmp ref_filename
        
    else
        %             label_struct =
        %                             [1x1 struct]    [5994x2 double]
        %                               |
        %                               |_  ref_filename_K: [1x104 char] ==> KIT
        %                                   ref_filename_L: [1x107 char] ==> LIV
        %                                             size: 5994
        for i = 1:N
            path = [getenv('EVALITA_DEV'),filesep,args.dataset,filesep,filename,num2str(i),filesep];
            ref_filename_K = [path,'Additional_info',filesep,ref_Kit];
            ref_filename_L = [path,'Additional_info',filesep,ref_Liv];
            L = size(feat_struct{i,2},1);
            tmp.ref_filename_K = ref_filename_K;
            tmp.ref_filename_L = ref_filename_L;
            tmp.size = L;
            label_struct{i,1} = tmp;
            label_K = logical(labelLoad( ref_filename_K, L ));
            label_L = logical(labelLoad( ref_filename_L, L ));
            class0 = and(not(label_K),not(label_L));
            class1 = and(not(label_K),label_L);
            class2 = and(label_K,not(label_L));
            class3 = and(label_K,label_L);
            if strcmp(args.arch,'BLSTM')
                class_label = zeros(L,1);
                for j=1:L
                    if     class0(j) == 1
                        class_label(j) = 0;
                    elseif class1(j) == 1
                        class_label(j) = 1;
                    elseif class2(j) == 1
                        class_label(j) = 2;
                    elseif class3(j) == 1
                        class_label(j) = 3;
                    end
                end
                label_struct{i,2} = class_label;
            else
                class_label=[class0,class1,class2,class3];
                label_struct{i,2} = class_label;
            end
            
        end
        clear N L i nPools rand ref_Kit ref_Liv useParallel tmp ref_filename
        
    end
    %% Create NC-FILE
    fold = size(train_idxs,2);
    input_size = size(feat_struct{1,2},2);
    output_size = 4;
    featset = feat_struct{1,1}.acronym;
    room = feat_struct{1,1}.room;
    arch = args.arch;
    
    for i = 1:fold  % foreach test
        TrainData = [];
        TrainLabels = [];
        len = [];
        tags = [];
        M = numel(train_idxs(:,i));
        for n = 1:M   % foreach file in the test
            TrainData = [TrainData; feat_struct{train_idxs(n,i),2}];
            TrainLabels = [TrainLabels; label_struct{train_idxs(n,i),2}];
            len = [len; size(feat_struct{train_idxs(n,i),2},1)];
            if train_idxs(n,i) < 10
                tags = [tags; [feat_struct{train_idxs(n,i),1}.scene,'_',feat_struct{train_idxs(n,i),1}.room,' ']];
            else
                tags = [tags; [feat_struct{train_idxs(n,i),1}.scene,'_',feat_struct{train_idxs(n,i),1}.room]];
            end
            
        end
        Train_namefile = create_NCfiles_2015(TrainData, TrainLabels, tags, len, featset, i, room, 'TRAIN', arch);
        clear TrainData TrainLabels tags len M
        
        ValData = [];
        ValLabels = [];
        len = [];
        tags = [];
        M = numel(val_idxs(:,i));
        for n = 1:M   % foreach file in the test
            ValData = [ValData; feat_struct{val_idxs(n,i),2}];
            ValLabels = [ValLabels; label_struct{val_idxs(n,i),2}];
            len = [len; size(feat_struct{val_idxs(n,i),2},1)];
            if val_idxs(n,i) < 10
                tags = [tags; [feat_struct{val_idxs(n,i),1}.scene,'_',feat_struct{val_idxs(n,i),1}.room,' ']];
            else
                tags = [tags; [feat_struct{val_idxs(n,i),1}.scene,'_',feat_struct{val_idxs(n,i),1}.room]];
            end
            
        end
        Val_namefile = create_NCfiles_2015(ValData, ValLabels, tags, len, featset, i, room, 'VAL', arch);
        clear ValData ValLabels tags len M
        
        TestData = [];
        TestLabels = [];
        len = [];
        tags = [];
        M = numel(test_idxs(:,i));
        for n = 1:M   % foreach file in the test
            TestData = [TestData; feat_struct{test_idxs(n,i),2}];
            TestLabels = [TestLabels; label_struct{test_idxs(n,i),2}];
            len = [len; size(feat_struct{test_idxs(n,i),2},1)];
            if test_idxs(n,i) < 10
                tags = [tags; [feat_struct{test_idxs(n,i),1}.scene,'_',feat_struct{test_idxs(n,i),1}.room,' ']];
            else
                tags = [tags; [feat_struct{test_idxs(n,i),1}.scene,'_',feat_struct{test_idxs(n,i),1}.room]];
            end
            
        end
        doSplit = false;
        Test_namefile = create_NCfiles_2015(TestData, TestLabels, tags, len, featset, i, room, 'TEST', arch);
        clear TestData TestLabels tags len M
    end
    %% TRAINING and TESTING
    
    for q=1:length(args.nets)
        layers = [input_size args.nets{q} output_size];
        net_str = [];
        for k = 1:length(args.nets{q})
            net_str = [net_str, num2str(args.nets{q}(k)), ','];
        end
        net_str = net_str(1:end-1);
        for i=1:fold  % foreach test
            % TRAIN
            Train_namefile = ['../experiments', filesep, featset, filesep, 'data', filesep, num2str(i), '_', room, '_TRAIN.nc' ];
            Val_namefile = ['../experiments', filesep, featset, filesep, 'data', filesep, num2str(i), '_', room, '_VAL.nc' ];
            Test_namefile = ['../experiments', filesep, featset, filesep, 'data', filesep, num2str(i), '_', room, '_TEST.nc' ];
            csv_file = ['../experiments', filesep, featset, filesep, net_str,'-',arch, filesep, 'ff_output', filesep, num2str(i), '_ff_', room, '.csv'];
            if (exist(csv_file, 'file') == 0)
                tmp_path = ['../experiments', filesep, featset, filesep, net_str,'-',arch, filesep, 'ff_output'];
                if ~exist(tmp_path,'dir')
                    system(['mkdir -p ',tmp_path]);
                end
            end
            trained_net_name = [num2str(i), '_trained_network_', room];
            tmp = ['../experiments', filesep, featset, filesep, net_str,'-',arch, filesep, 'trained_networks'];
            if ~exist(tmp,'dir')
                system(['mkdir -p ',tmp]);
            end
            if (exist([tmp, filesep, trained_net_name,'.mlp'], 'file') == 0)
                COND = 0;
            else
                COND = 1;
                disp('WARNING: Network already exists. Its training will be skipped.');
            end
            %            tic;
            system_call = ['THEANO_FLAGS=floatX=float32,device=gpu python MLP_Keras.py', ' --COND ', num2str(COND), ...
                ' --nrLayers ', num2str(length(layers)), ...
                ' --layerSizes ', (strjoin(strsplit(num2str(layers),' '),',')), ...
                ' --learn_rate ', num2str(args.StepRatio{2}), ...
                ' --maxEpochs ', num2str(args.MaxIter{2}), ...
                ' --ES_epochs 20' ...
                ' --MomentumMax 0.9' ...
                ' --NumberminiBatch 512' ...
                ' --VisibleDropout 0.99' ...
                ' --HiddenDropout 0.5' ...
                ' --train_file ', Train_namefile, ...
                ' --test_file ', Test_namefile, ...
                ' --val_file ', Val_namefile, ...
                ' --out_file ', csv_file, ...
                ' --trained_network ', [tmp,filesep,trained_net_name,'.mlp'], ...
                ' --fold ', num2str(i)
                ]
            path_logFile = ['log'];
            [pathstr,name,ext] = fileparts(conf_file);
            if ~exist(path_logFile,'dir')
                system(['mkdir -p ',path_logFile]);
            end
            system([system_call,' &>> ',path_logFile,filesep,'log_',name,'.txt']);
        end
        
        %% EVALUATION RESULTS
        
        th_vec = 0.0:0.1:1.0;
        fs = 100; % 100Hz , 10ms
        
        base_dir = ['../experiments', filesep, featset, filesep, net_str,'-',arch, filesep, 'results', filesep];
        structtmp = feat_struct(:,1);
        for th_idx=1:length(th_vec)
            th = th_vec(th_idx);
            
            for i=1:fold  % foreach test
                M = numel(test_idxs(:,i));
                tags = cell(1,M);
                for n = 1:M   % foreach file in the test
                    tags{n} = [feat_struct{test_idxs(n,i),1}.scene];
                end
                
                csv_file = ['../experiments', filesep, featset, filesep, net_str,'-',arch, filesep, 'ff_output', filesep, num2str(i), '_ff_', room, '.csv'];
                %%% processBLSTMout(csv_file, th, base_dir, args.dataset, args.room, tags, fs);
                if (exist([csv_file(1:end-5),'K.csv'],'file') == 0)
                    oneRoomMarginalization(csv_file, tags);
                end
                %Kit
                csv_file = ['../experiments', filesep, featset, filesep, net_str,'-',arch, filesep, 'ff_output', filesep, num2str(i), '_ff_K.csv'];
                processBLSTMout(csv_file, th, base_dir, args.dataset, 'Kitchen', tags, fs, false);
                %Liv
                csv_file = ['../experiments', filesep, featset, filesep, net_str,'-',arch, filesep, 'ff_output', filesep, num2str(i), '_ff_L.csv'];
                processBLSTMout(csv_file, th, base_dir, args.dataset, 'Livingroom', tags, fs, false);
            end
            system_call = [getenv('EVALITA_EVAL'), filesep, 'SLOC_SAD_Eval_new -list ', base_dir, 'fileList_',num2str(th),'.txt -totalSummary ', base_dir, 'avgEval_',num2str(th),'.txt'];
            system(system_call);
        end
        % doscore
        system(['perl scripts/doscore.pl ',base_dir,' ',base_dir,'A_score_',room,'.csv']);
    end % foreach net
end % foreach conf
disp('done');

