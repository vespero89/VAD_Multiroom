function [ acronym ] = acronym_loading( features_list, filename, format_, norm_before )    

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
            s.MFCC12_0_D_A = 0;
        elseif strcmp(feat_type, 'mfcc_2')
            %%% var name: MFCC12_0_D_Z
            s.MFCC12_0_D_Z = 0;
        elseif strcmp(feat_type, 'rasta-plp')
            %%% var name: RASTAPLP_0_D_A
            s.RASTAPLP_0_D_A = 0;
        elseif strcmp(feat_type, 'rasta-plp_2')
            %%% var name: RASTAPLP_0_D_Z
            s.RASTAPLP_0_D_Z = 0;
        elseif strcmp(feat_type, 'pitch')
            %%% var name: pitch
            s.pitch = 0;
        elseif strcmp(feat_type, 'wclpe')    
            s.WCLPE = 0;
        elseif strcmp(feat_type, 'ams')
            %%% var name: AMS
            s.AMS = 0;
        elseif strcmp(feat_type, 'ltsd')
            %%% var name: LTSD
            s.LTSD = 0;
        elseif strcmp(feat_type, 'ltse')
            %%% var name: LTSE
            s.LTSE = 0;
        elseif strcmp(feat_type, 'pncc')
            %%% var name: PNCC12_0_D_Z
            s.PNCC12_0_D_Z = 0;
        elseif strcmp(feat_type, 'evm')
            %%% var name: EVM
            s.EVM = 0;
        elseif strcmp(feat_type, 'evm_wh')
            s.EVM_wH = 0;
        end
    end
    
    
    matr = [];
    acronym = [];

    
    if isfield(s,'pitch')
        acronym = [acronym, 'Pi'];
    end
    if isfield(s,'MFCC12_0_D_A')
        acronym = [acronym, 'Mf1'];
    end
    if isfield(s,'MFCC12_0_D_Z')
        acronym = [acronym, 'Mf2'];
    end
    if isfield(s,'RASTAPLP_0_D_A')
        acronym = [acronym, 'Ra1'];
    end
    if isfield(s,'RASTAPLP_0_D_Z')
        acronym = [acronym, 'Ra2'];
    end
    if isfield(s,'WCLPE')
        acronym = [acronym, 'Wc'];
    end
    if isfield(s,'AMS')
        acronym = [acronym, 'Am'];
    end
    if isfield(s,'LTSD')
       acronym = [acronym, 'Lt'];
    end
    if isfield(s,'PNCC12_0_D_Z')
        acronym = [acronym, 'Pn'];
    end
    if isfield(s,'EVM')
        acronym = [acronym, 'Ev1'];
    end
    if isfield(s,'EVM_wH')
        acronym = [acronym, 'Ev2'];
    end 
end

