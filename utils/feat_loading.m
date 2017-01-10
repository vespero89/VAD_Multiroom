function [ matr, acronym ] = feat_loading( features_list, filename, format_, norm_before )
% Function creates a matrix of features already extracted!
%
% Inputs:
%   features_list: cell{'mfcc', 'rasta-plp', 'pitch', ...}
%   filename: complete path to file .mat
%
% Output:
%   matr: matrix of features list

if nargin < 4
    norm_before = false;
end

% features loading
M = numel(features_list);
L = 0;
s = struct;

for i = 1:M
    feat_type = features_list{i};
    if strcmp(feat_type, 'mfcc')
        %%% var name: MFCC12_0_D_A
        [ s, L ] = loadFeat( s, filename, 'MFCC12_0_D_A', L, format_ );
    elseif strcmp(feat_type, 'mfcc_2')
        %%% var name: MFCC12_0_D_Z
        [ s, L ] = loadFeat( s, filename, 'MFCC12_0_D_Z', L, format_ );
    elseif strcmp(feat_type, 'rasta-plp')
        %%% var name: RASTAPLP_0_D_A
        [ s, L ] = loadFeat( s, filename, 'RASTAPLP_0_D_A', L, format_ );
    elseif strcmp(feat_type, 'rasta-plp_2')
        %%% var name: RASTAPLP_0_D_Z
        [ s, L ] = loadFeat( s, filename, 'RASTAPLP_0_D_Z', L, format_ );
    elseif strcmp(feat_type, 'pitch')
        %%% var name: pitch
        [ s, L ] = loadFeat( s, filename, 'pitch', L, format_ );
    elseif strcmp(feat_type, 'wclpe')
        if strcmp(format_,'htk')
            tmp = [filename,'_WCLPE.htk'];
            D = readhtk(tmp);
            s.WCLPE = D(2:end-1,:);
            L = max(L,size(s.WCLPE,1));
        else
            %%% var name: WCLPE
            tmp = [filename,'_WCLPE.mat'];
            load(tmp);
            s.WCLPE = WCLPE(2:end-1,:);
            L = max(L,size(s.WCLPE,1));
        end
    elseif strcmp(feat_type, 'ams')
        %%% var name: AMS
        [ s, L ] = loadFeat( s, filename, 'AMS', L, format_ );
    elseif strcmp(feat_type, 'ltsd')
        %%% var name: LTSD
        [ s, L ] = loadFeat( s, filename, 'LTSD', L, format_ );
    elseif strcmp(feat_type, 'ltse')
        %%% var name: LTSE
        [ s, L ] = loadFeat( s, filename, 'LTSE', L, format_ );
    elseif strcmp(feat_type, 'pncc')
        %%% var name: PNCC12_0_D_Z
        [ s, L ] = loadFeat( s, filename, 'PNCC12_0_D_Z', L, format_ );
    elseif strcmp(feat_type, 'evm')
        %%% var name: EVM
        [ s, L ] = loadFeat( s, filename, 'EVM', L, format_ );
    elseif strcmp(feat_type, 'evm_wh')
        %%% var name: EVM_wH ---- Hard wieghted version of EVM (1
        %%% feature)
        [ s, L ] = loadFeat( s, filename, 'EVM_wH', L, format_ );
    elseif strcmp(feat_type, 'logmel')
        [ s, L ] = loadFeat( s, filename, 'LOGMEL40', L, format_ );
    end
end

matr = [];
acronym = [];

if isfield(s,'pitch')
    matr = checkAndConcat( s, 'pitch', L, matr, norm_before );
    acronym = [acronym, 'Pi'];
end
if isfield(s,'MFCC12_0_D_A')
    matr = checkAndConcat( s, 'MFCC12_0_D_A', L, matr, norm_before );
    acronym = [acronym, 'Mf1'];
end
if isfield(s,'MFCC12_0_D_Z')
    matr = checkAndConcat( s, 'MFCC12_0_D_Z', L, matr, norm_before );
    acronym = [acronym, 'Mf2'];
end
if isfield(s,'RASTAPLP_0_D_A')
    matr = checkAndConcat( s, 'RASTAPLP_0_D_A', L, matr, norm_before );
    acronym = [acronym, 'Ra1'];
end
if isfield(s,'RASTAPLP_0_D_Z')
    matr = checkAndConcat( s, 'RASTAPLP_0_D_Z', L, matr, norm_before );
    acronym = [acronym, 'Ra2'];
end
if isfield(s,'WCLPE')
    matr = checkAndConcat( s, 'WCLPE', L, matr, norm_before );
    acronym = [acronym, 'Wc'];
end
if isfield(s,'AMS')
    matr = checkAndConcat( s, 'AMS', L, matr, norm_before );
    acronym = [acronym, 'Am'];
end
if isfield(s,'LTSD')
    matr = checkAndConcat( s, 'LTSD', L, matr, norm_before );
    acronym = [acronym, 'Lt'];
end
%     if isfield(s,'LTSE')
%         matr = checkAndConcat( s, 'LTSE', L, matr, norm_before );
%         acronym = [acronym, ];
%     end
if isfield(s,'PNCC12_0_D_Z')
    append = false; % PNCC hanno 2 frame (definito sulla config di estrazione delle features PNCC) mancanti all'inizio, i restanti mancanti sono alla fine
    matr = checkAndConcat( s, 'PNCC12_0_D_Z', L, matr, norm_before, append );
    acronym = [acronym, 'Pn'];
end
if isfield(s,'EVM')
    append = true;
    matr = checkAndConcat( s, 'EVM', L, matr, norm_before, append );
    acronym = [acronym, 'Ev1'];
end
if isfield(s,'EVM_wH')
    matr = checkAndConcat( s, 'EVM_wH', L, matr, norm_before );
    acronym = [acronym, 'Ev2'];
end
if isfield(s,'LOGMEL40')
    matr = checkAndConcat( s, 'LOGMEL40', L, matr, norm_before );
    acronym = [acronym, 'Lm'];
end

% normalize
if ~norm_before
    type = 'min-max';
    [ matr ] = myNorms( matr, type );
end

end

function [ s_new, L_new ] = loadFeat( s_new, filename, featname, L, format_ )

if strcmp(format_, 'htk')
    D = readhtk([filename,'_',featname,'.htk']);
    s_new.(featname) = D;
    L_new = max(L,size(D,1));
else
    s = load([filename,'_',featname,'.mat']);
    s_new.(featname) = s.(featname);
    L_new = max(L,size(s.(featname),1));
end
end

function [ m ] = checkAndConcat( s, featname, L, matr, norm_before, append )

if nargin < 6
    append = true;
end

if size(s.(featname),1) < L
    tmp = zeros(L - size(s.(featname),1),size(s.(featname),2));
    if append
        s.(featname) = [s.(featname);tmp];
    else
        s.(featname) = [tmp;s.(featname)];
    end
end

if norm_before
    type = 'min-max';
    s.(featname) = myNorms( s.(featname), type );
end
% concatenate
m = [matr,s.(featname)];
end

function [ m_norm ] = myNorms( d, type )

switch type
    case 'min-max'
        minimums = min(d,[],1);
        ranges = max(d,[],1) - minimums;
        m_norm = (d - repmat(minimums, size(d, 1), 1)) ./ repmat(ranges, size(d, 1), 1);
    otherwise
        
end

end

