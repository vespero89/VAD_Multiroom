function oneRoomMarginalization(csv, tags)
    
    data = importFFoutput( csv );
    classes = 4;
    kit_sp = cell(1,numel(data));
    liv_sp = cell(1,numel(data));
    for seq = 1:numel(data)
        data{seq} = reshape(data{1,seq},classes,size(data{1,seq},1)/classes)';
        kit_sp{seq} = data{seq}(:,3) + data{seq}(:,4);
        liv_sp{seq} = data{seq}(:,2) + data{seq}(:,4);
    end

    % write csv file
    my_cell2csv([csv(1:end-5),'K.csv'], tags, kit_sp,';');
    my_cell2csv([csv(1:end-5),'L.csv'], tags, liv_sp,';');
end