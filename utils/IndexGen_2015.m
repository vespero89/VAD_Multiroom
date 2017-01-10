function [ train_idxs, val_idxs, test_idxs ] = IndexGen( c, N , rand)

    if nargin < 3 
        rand = false;
    end
    
    %%%%% TODO
    %%%%% implement rand!!!!!

    if strcmp(c.dataset,'Real') || strcmp(c.dataset,'Simulations') || (strcmp(c.dataset,'Mixed')) % Real or Simulations DB
        switch c.mode        

            case 'LOO' % Leave One Out
                ntrain = N - 1;
                v = 1:N;
                train_idxs = nchoosek(v,ntrain)';    % list of idxes column-wise
                test_idxs = fliplr(v);
            case 'CV'
                train_idxs = [];
                val_idxs = [];
                test_idxs = [];
                % Stratified Crossfold validation
                if strcmp(c.dataset,'Real') % Real DB
                    k = 8;
                    ntest = ceil(N/k);    % file in each folder
                    nval = ceil(N/k);
                    ntrain = N - ntest - nval;   % all the other folder files
                    v = 1:k-1;
                    selector = nchoosek(v,length(v)-1);
                    z = 0;
                    for i=1:size(selector,1)
                        scenes = [1:N];
                        E=randsample(N,1);
                        scenes(E)=[];
                        fold_file_idx = reshape(scenes,ntest,k-1);
                        tmp = [E];

                        for j=1:size(selector,2)
                            if j ~= size(selector,2)-z
                                tmp = [tmp; fold_file_idx(:,selector(i,j))];
                            else
                                val_idxs = [val_idxs, fold_file_idx(:,selector(i,j))];
                            end
                        end
                        z = z+1;
                        if z == size(selector,2)
                            z = 0;
                        end
                        train_idxs = [train_idxs, tmp];
                        v1 = fliplr(v);
                        test_idxs = [test_idxs, fold_file_idx(:,v1(i))];
                    end


              elseif (strcmp(c.dataset,'Simulations') || (strcmp(c.dataset,'Mixed')))% Sim DB
                    k = 10;
                    ntest = ceil(N/k);    % file in each folder
                    nval = ceil(N/k);
                    ntrain = N - ntest - nval;   % all the other folder files
                    fold_file_idx = reshape([1:N],ntest,k);
                    v = 1:k;
                    selector = nchoosek(v,length(v)-1);
                    z = 0;
                    for i=1:size(selector,1)
                        tmp = [];

                        for j=1:size(selector,2)
                            if j ~= size(selector,2)-z
                                tmp = [tmp; fold_file_idx(:,selector(i,j))];
                            else
                                val_idxs = [val_idxs, fold_file_idx(:,selector(i,j))];
                            end
                        end
                        z = z+1;
                        if z == size(selector,2)
                            z = 0;
                        end
                        train_idxs = [train_idxs, tmp];
                    end           
                    v = fliplr(v);
                    tmp = [];
                    for i=1:length(v)
                        test_idxs = [test_idxs, fold_file_idx(:,v(i))];
                    end
                end
        end       
    else
        error('Dataset does not exist! [Real | Simulations]')
    end
end

