function [ namefile ] = create_NCfiles_2015( datas, labels, tags, len, featset, index, room, dataset, arch)


namefile = ['../experiments', filesep, featset, filesep, 'data', filesep, num2str(index), '_', room, '_', dataset, '.nc' ];
if (exist(namefile) == 0)
     tmp_path = ['../experiments', filesep, featset, filesep, 'data'];
        if ~exist(tmp_path,'dir')
            system(['mkdir -p ',tmp_path]);
        end
                   

    if strcmp(arch,'BLSTM')
            classes = ['SilSil';'SilSp ';'SpSil ';'SpSp  '];  % 0;1;2;3
            numTimesteps = size(datas,1);
            inputPattSize = size(datas,2);
            nccreate(namefile,'inputs','Dimensions',{'inputPattSize',inputPattSize,'numTimesteps',numTimesteps},'Datatype','single','Format','netcdf4');
            ncwrite(namefile, 'inputs', datas');

            numTimesteps = size(labels,1);
            nccreate(namefile,'targetClasses','Dimensions',{'numTimesteps',numTimesteps},'Datatype','int32','Format','netcdf4');
            ncwrite(namefile, 'targetClasses', labels);

            numSeqs = size(tags,1);
            maxSeqTagLength = size(tags,2);
            nccreate(namefile,'seqTags','Dimensions',{'maxSeqTagLength',maxSeqTagLength,'numSeqs',numSeqs},'Datatype','char','Format','netcdf4');
            ncwrite(namefile, 'seqTags', tags');

            numSeqs = size(len,1);
            nccreate(namefile,'seqLengths','Dimensions',{'numSeqs',numSeqs},'Datatype','int32','Format','netcdf4');
            ncwrite(namefile, 'seqLengths', len);

            numTargetClasses = size(classes,1);
            nccreate(namefile,'numTargetClasses','Datatype','int32','Format','netcdf4');
            ncwrite(namefile, 'numTargetClasses', numTargetClasses);

            numLabels = size(classes,1);
            maxLabelLength = size(classes,2);
            nccreate(namefile,'labels','Dimensions',{'maxLabelLength',maxLabelLength,'numLabels',numLabels},'Datatype','char','Format','netcdf4');
            ncwrite(namefile, 'labels', classes');
    else
        numTimesteps = size(datas,1);
        inputPattSize = size(datas,2);
       % disp('prima della chiamata....')
        nccreate(namefile,'inputs','Dimensions',{'inputPattSize',inputPattSize,'numTimesteps',numTimesteps},'Datatype','single','Format','netcdf4');
       % disp('intermedia')
        ncwrite(namefile, 'inputs', datas');

       % disp('dopo la chiamata....')

        numTimesteps = size(labels,1);
        targetPattSize = size(labels,2);
        nccreate(namefile,'targetPatterns','Dimensions',{'targetPattSize',targetPattSize,'numTimesteps',numTimesteps},'Datatype','single','Format','netcdf4');
        ncwrite(namefile, 'targetPatterns', labels');



        numSeqs = size(tags,1);
        maxSeqTagLength = size(tags,2);
        nccreate(namefile,'seqTags','Dimensions',{'maxSeqTagLength',maxSeqTagLength,'numSeqs',numSeqs},'Datatype','char','Format','netcdf4');
        ncwrite(namefile, 'seqTags', tags');

        numSeqs = size(len,1);
        nccreate(namefile,'seqLengths','Dimensions',{'numSeqs',numSeqs},'Datatype','int32','Format','netcdf4');
        ncwrite(namefile, 'seqLengths', len);    
    end
    
end

end
    
 


           