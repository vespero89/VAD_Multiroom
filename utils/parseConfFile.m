%function [ features_list, wavfiles_list, nets, dataset, ...
%           room, mode, autosave ] = parseConfFile( conf_file, verbose )
function [ p ] = parseConfFile( conf_file, verbose )
% Function parses the configuration file to create the list of features
% to use and the wav file list. Lines start with # will be skipped.
%
% Inputs:
%   conf_file: path to file of config
%   verbose:   if true shows args passed. [ false ]
%
% Output:
%   p: struct containg data

    if nargin < 2
        verbose = false;
    end
        
    f = fopen(conf_file,'r');
    line = fgetl(f);
    
    nets = {};
    while ischar(line) 
        % skip line if #
        if ( strncmp(line,'#',1) || isempty(line) )
            line = fgetl(f);
            continue
        end
%%%%%%%%% feature list %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if regexp(line,':features')
             tmp = strsplit(line);
             p.features_list = strsplit(tmp{2},',');
             if verbose 
                 disp(['(MSG) Features: ',strjoin(p.features_list,',')]); 
             end
%%%%%%%%% net sizes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif regexp(line,':nets')
            tmp = strsplit(line);
            tmp = strsplit(tmp{1,2},';');
            for i=1:numel(tmp)
                p.nets{i} = sscanf(tmp{i},'%f,')';
                if verbose 
                    disp(['(MSG) Net_',num2str(i),' size: ',num2str(p.nets{i})]); 
                end
            end
%%%%%%%%% room %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        elseif regexp(line,':room')
            tmp = strsplit(line);
            p.room = tmp{2};
            if verbose 
                disp(['(MSG) Room: ',p.room]); 
            end
%%%%%%%%% datset %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif regexp(line,':dataset')
            tmp = strsplit(line);
            p.dataset = tmp{2};
            if verbose 
                disp(['(MSG) Dataset: ',p.dataset]); 
            end
%%%%%%%%% mode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif regexp(line,':mode')
            tmp = strsplit(line);
            p.mode = tmp{2};
            if verbose 
                disp(['(MSG) Mode: ',p.mode]); 
            end
%%%%%%%%% autosave %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif regexp(line,':autosave')
            p.autosave = true;
            tmp = strsplit(line);
            if numel(tmp) > 1
                p.base_dir = tmp{2};
            end
            if verbose 
                if isfield(p,'base_dir')
                    disp(['(MSG) Autosave in: ',p.base_dir]); 
                else
                    disp('(MSG) Autosave: True'); 
                end
            end
%%%%%%%%% net parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif regexp(line,':MaxIter')  % support different MaxIter for pre-training and fine-tuning
            tmp = strsplit(line);
            tmp = strsplit(tmp{1,2},';');
            if numel(tmp) > 1   % different # of iter in pre-training and fine-tuning
                p.diffIter = true;
                for i=1:numel(tmp)
                    p.MaxIter{i} = sscanf(tmp{i},'%i,')';
                end
            else
                p.diffIter = false;
                p.MaxIter = str2double(tmp);
            end
            if (verbose && p.diffIter == 0) 
                disp(['(MSG) MaxIter: ',num2str(p.MaxIter)]); 
            elseif (verbose && p.diffIter == 1)
                disp(['(MSG) Pre-training MaxIter: ',num2str(p.MaxIter{1})]);
                disp(['      Fine-tuning MaxIter: ',num2str(p.MaxIter{2})]);
            end
        elseif regexp(line,':StepRatio')
            tmp = strsplit(line);
            tmp = strsplit(tmp{1,2},';');
            if numel(tmp) > 1   % different # of iter in pre-training and fine-tuning
                p.diffStepRatio = true;
                for i=1:numel(tmp)
                    p.StepRatio{i} = sscanf(tmp{i},'%f,')';
                end
            else
                p.diffStepRatio = false;
                p.StepRatio = str2double(tmp);
            end
            if (verbose && p.diffStepRatio == 0) 
                disp(['(MSG) StepRatio: ',num2str(p.StepRatio)]); 
            elseif (verbose && p.diffStepRatio == 1)
                disp(['(MSG) Pre-training StepRatio: ',num2str(p.StepRatio{1})]);
                disp(['      Fine-tuning StepRatio: ',num2str(p.StepRatio{2})]);
            end
        elseif regexp(line,':BatchSize')
            tmp = strsplit(line);
            p.BatchSize = str2double(tmp{end});
            if verbose 
                disp(['(MSG) BatchSize: ',num2str(p.BatchSize)]); 
            end
        elseif regexp(line,':DropOutRate')
            tmp = strsplit(line);
            p.DropOutRate = str2double(tmp{end});
            if verbose 
                disp(['(MSG) DropOutRate: ',num2str(p.DropOutRate)]); 
            end
%%%%%%%%% mic %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif regexp(line,':mic')
            tmp = strsplit(line);
            tmp = strsplit(tmp{2},',');
            for i=1:numel(tmp)
                tmp{i} = [tmp{i},'_16k'];
            end
            p.mics = tmp;
            if verbose 
                disp(['(MSG) mics: ', strjoin(p.mics,'  ')]); 
            end
%%%%%%%%% GCC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif regexp(line,':gcc')
            tmp = strsplit(line);
            tmp = strsplit(tmp{2},';');
            p.gcc = tmp;
            if verbose 
                disp(['(MSG) gcc: ', strjoin(p.gcc,'  ')]); 
            end    
%%%%%%%%% useParallel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif regexp(line,':useParallel')
            tmp = strsplit(line);
            p.useParallel = str2double(tmp{end});
            if verbose 
                disp(['(MSG) useParallel: ',num2str(p.useParallel)]); 
            end    
%%%%%%%%% normBefore %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif regexp(line,':normBefore')
            p.normBefore = true;
            if verbose 
                disp('(MSG) normBefore: True'); 
            end
%%%%%%%%% current conf %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif regexp(line,':max_epochs_no_best')
            tmp = strsplit(line);
            p.max_epochs_no_best = str2double(tmp{end});
            if verbose 
                disp(['(MSG) max_epochs_no_best: ',num2str(p.max_epochs_no_best)]); 
            end 
        elseif regexp(line,':max_epochs')
            tmp = strsplit(line);
            p.max_epochs = str2double(tmp{end});
            if verbose 
                disp(['(MSG) max_epochs: ',num2str(p.max_epochs)]); 
            end
        elseif regexp(line,':learning_rate')
            tmp = strsplit(line);
            p.learning_rate = str2double(tmp{end});
            if verbose 
                disp(['(MSG) learning_rate: ',num2str(p.learning_rate)]); 
            end
        elseif regexp(line,':weights_dist')
            tmp = strsplit(line);
            p.weights_dist = tmp{end};
            if verbose 
                disp(['(MSG) weights_dist: ',num2str(p.weights_dist)]); 
            end
        elseif regexp(line,':weights_normal_sigma')
            tmp = strsplit(line);
            p.weights_normal_sigma = str2double(tmp{end});
            if verbose 
                disp(['(MSG) weights_normal_sigma: ',num2str(p.weights_normal_sigma)]); 
            end
        elseif regexp(line,':weights_normal_mean')
            tmp = strsplit(line);
            p.weights_normal_mean = str2double(tmp{end});
            if verbose 
                disp(['(MSG) weights_normal_mean: ',num2str(p.weights_normal_mean)]); 
            end
        elseif regexp(line,':hybrid_online_batch')
            tmp = strsplit(line);
            p.hybrid_online_batch = tmp{end};
            if verbose 
                disp(['(MSG) hybrid_online_batch: ',num2str(p.hybrid_online_batch)]); 
            end
        elseif regexp(line,':validate_every')
            tmp = strsplit(line);
            p.validate_every = str2double(tmp{end});
            if verbose 
                disp(['(MSG) validate_every: ',num2str(p.validate_every)]); 
            end
        elseif regexp(line,':parallel_sequences')
            tmp = strsplit(line);
            p.parallel_sequences = str2double(tmp{end});
            if verbose 
                disp(['(MSG) parallel_sequences: ',num2str(p.parallel_sequences)]); 
            end
        elseif regexp(line,':input_noise_sigma')
            tmp = strsplit(line);
            p.input_noise_sigma = str2double(tmp{end});
            if verbose 
                disp(['(MSG) input_noise_sigma: ',num2str(p.input_noise_sigma)]); 
            end
        elseif regexp(line,':shuffle_fractions')
            tmp = strsplit(line);
            p.shuffle_fractions = tmp{end};
            if verbose 
                disp(['(MSG) shuffle_fractions: ',num2str(p.shuffle_fractions)]); 
            end
        elseif regexp(line,':shuffle_sequences')
            tmp = strsplit(line);
            p.shuffle_sequences = tmp{end};
            if verbose 
                disp(['(MSG) shuffle_sequences: ',num2str(p.shuffle_sequences)]); 
            end
        elseif regexp(line,':cuda')
            tmp = strsplit(line);
            p.cuda = tmp{end};
            if verbose 
                disp(['(MSG) cuda: ',num2str(p.cuda)]); 
            end
%%%%%%%%NetworkArchitecture%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif regexp(line,':arch')
            tmp = strsplit(line);
            p.arch = tmp{2};
            if verbose 
                disp(['(MSG) Architecture: ',p.arch]); 
            end
%%%%%%%%%%%%%%%BATCH Size %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  %aggiunta
       elseif regexp(line,':BatchSize')
           tmp = strsplit(line);
           p.BatchSize = tmp{end};
           if verbose
               disp(['(MSG) BatchSize: ',num2str(p.BatchSize)]);
           end
%%%%%%%%%%%%%%%% net sizes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif regexp(line,':nrConvPoolLayers')
            tmp = strsplit(line);
                p.nrConvPoolLayers = sscanf(tmp{i},'%f,')';
                if verbose 
                    disp(['(MSG) nrConvPoolKern ',num2str(p.nrConvPoolLayers)]); 
                end
         elseif regexp(line,':InputSizeHN')
            tmp = strsplit(line);
                p.InputSizeHN = sscanf(tmp{i},'%f,')';
                if verbose 
                    disp(['(MSG) InputSizeHN ',num2str(p.InputSizeHN)]); 
                end
                
         elseif regexp(line,':ConvKernSize')
            tmp = strsplit(line);
                p.ConvKernSizes = sscanf(tmp{i},'%f,')';
                if verbose 
                    disp(['(MSG) ConvKernSize ',num2str(p.ConvKernSizes)]); 
                end
                
         elseif regexp(line,':PoolKernSizes')
            tmp = strsplit(line);
                p.PoolKernSizes = sscanf(tmp{i},'%f,')';
                if verbose 
                    disp(['(MSG) NPoolKernSizes ',num2str(p.PoolKernSizes)]); 
                end
         elseif regexp(line,':nrHiddenNodesLayers')
            tmp = strsplit(line);
                p.nrHiddenNodesLayers = sscanf(tmp{i},'%f,')';
                if verbose 
                    disp(['(MSG) nrHiddenNodesLayers ',num2str(p.nrHiddenNodesLayers)]); 
                end
         elseif regexp(line,':HiddenNodesSizes')
            tmp = strsplit(line);
                p.HiddenNodesSizes = sscanf(tmp{i},'%f,')';
                if verbose 
                    disp(['(MSG) HiddenNodesSizes ',num2str(p.HiddenNodesSizes)]); 
                end
%%%%%%%%%%%%%%%FRAME CONTEXT Size %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  %aggiunta
         elseif regexp(line,':frameContext')
           tmp = strsplit(line);
           p.framecxt = str2double(tmp{end});
           if verbose
               disp(['(MSG) Frame Context: ',num2str(p.framecxt)]);
           end
	elseif regexp(line,':Strides')
           tmp = strsplit(line);
           p.strides = str2double(tmp{end});
           if verbose
               disp(['(MSG) Strides: ',num2str(p.framecxt)]);
           end 
        % next line    
   end
    line = fgetl(f);
  end
    fclose(f);
  


end

