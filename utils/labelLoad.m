function [ labels ] = labelLoad( filename, L )
% This function reads the .ref file passed and creates a vector which
% contains the ones only if the corresponding frame contains speech.
% Furthermore it use the desired length passed L to return the label vector
% sampled at desired samplerate.
%   input:
%       filename: path to reference file (Fs = 20Hz: one line every 50ms)
%       L: number of frames (our approach Fs = 100Hz: one line every 10ms)
%   output:
%       labels: vector containing 1 for each speech frame (Fs=100Hz)
% 
% Depending on the dataset used (Real or Simulated) the keyword to recognise
% speech frame differs. For Real it is "spk" while for Simulated it is "sp_*".
%   Real typical ref file:
%       3.45 0 0 0 - 0 0 0 #
%       3.50 0 0 0 - 0 0 0 #
%       3.55 1 0 0 spk 2255 1862 1634 #
%       3.60 1 0 0 spk 2257 1857 1633 #
%       3.65 1 0 0 spk 2261 1848 1633 #
%
%   Simulated typical ref file:
%       20.25 0 0 0 - 0 0 0 #
%       20.30 0 0 0 - 0 0 0 #
%       20.35 0 0 0 - 0 0 0 #
%       20.40 1 0 0 sp_comm_spont 1830 1880 1500 #
%       20.45 1 0 0 sp_comm_spont 1830 1880 1500 #
%       20.50 1 0 0 sp_comm_spont 1830 1880 1500 #
%       25.40 2 0 0 Coffee_tool+sp_conv 1830 1880 1500 #
%       25.45 2 0 0 Coffee_tool+sp_conv 1830 1880 1500 #
%       25.50 2 0 0 Coffee_tool+sp_conv 1830 1880 1500 #

    
    fid = fopen(filename);
    content = textscan(fid, '%f %d %d %d %s %d %d %d %s');
    fclose(fid);
    frames = length(content{1});
    labels = zeros(frames,1);
    
    speech = 0;
    
    for i=1:frames
        if content{2}(i) ~= 0 % speech or noise
            events_desc = strsplit(content{5}{i},'+');
            num_events = numel(events_desc);
            
            for e=1:num_events
                speech = speech + strncmp(events_desc{e},'sp_',3);
            end
  
            if (strcmp(content{5}{i},'spk') || speech > 0 )
                labels(i) = 1;
                speech = 0;
            end
        end
    end
    
    labels = repmat(labels,1,5);
    labels = reshape(labels', size(labels,1)*size(labels,2),1);
    
    % shift back to center labels
    labels = labels(4:end);
    
    if length(labels) > L
        labels = labels(1:L);
    else
        z = zeros(L - length(labels));
        labels = [labels;z];
    end

end

