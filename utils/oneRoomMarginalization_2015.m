function oneRoomMarginalization_2015(csv, tags, tool)
    
    data = importFFoutput( csv );
    classes = 4;
    if strcmp(tool,'Keras')
    	seq = 1;
    	i=1;
	dim = numel(data)/classes;
	kit_sp = cell(1,dim);
        liv_sp = cell(1,dim);
    	while seq < numel(data)
        	kit_sp{i} = data{seq+2} + data{seq+3};
        	liv_sp{i} = data{seq+1} + data{seq+3};
        	seq=seq+4;
        	i=i+1;
    	end

    else	
    	kit_sp = cell(1,numel(data));
    	liv_sp = cell(1,numel(data));
    	for seq = 1:numel(data)
        	data{seq} = reshape(data{1,seq},classes,size(data{1,seq},1)/classes)';
        	kit_sp{seq} = data{seq}(:,3) + data{seq}(:,4);
        	liv_sp{seq} = data{seq}(:,2) + data{seq}(:,4);
    	end
    end

    % write csv file
    my_cell2csv([csv(1:end-5),'K.csv'], tags, kit_sp,';');
    my_cell2csv([csv(1:end-5),'L.csv'], tags, liv_sp,';');
end
