function CMAT=confusionMatrix2(csv,label,room,th,flag)

data = importFFoutput( csv );
% classes = 2;
% for seq = 1:numel(data)
%     data{seq} = reshape(data{1,seq},classes,size(data{1,seq},1)/classes)';
% end

CMAT=cell(numel(data),1);

for s=1:numel(data)
    OutN=data{s};
    Lab=label{s};
    if strcmp(room,'Kitchen')
        Lab=Lab(:,1);
    elseif strcmp(room,'Livingroom')
        Lab=Lab(:,2);
    end
    P=[];
    for r=1:size(OutN,2)
        Pred=hangover(OutN(:,r),th);
        %         Pred=zeros(size(OutN,1),1);
        %         for f=1:length(OutN)
        %             if OutN(f,r) > th
        %                 Pred(f)= 1;
        %             end
        %         end
        P=[P,Pred];
    end
    P=logical(P);
    %LAB=Lab.*2;
    PRED=P.*1.5;
    if flag
        figure;
        plot(PRED,'r');axis ([1 5998 -0.5 2]);
        hold;
        plot(Lab,'b');axis ([1 5998 -0.5 2]);
        title(room);
    end
    
    CM=confusionmat(Lab,P);
    if numel(CM)==1
        if sum(Lab)==0
            CM=[CM,0;0,0];
        else
            CM=[0,0;0,CM];
        end
    end
    
    CMAT{s}=CM;
    
end
