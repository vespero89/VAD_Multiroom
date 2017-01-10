function CMAT=confusionMatrix(csv,label,th)

data = importFFoutput( csv );
classes = 4;
for seq = 1:numel(data)
    data{seq} = reshape(data{1,seq},classes,size(data{1,seq},1)/classes)';
end

CMAT=cell(numel(data),1);

for s=1:numel(data)
    OutN=data{s};
    Lab=label{s};
    P=[];
    for r=1:size(OutN,2)
        Pred=zeros(size(OutN,1),1);
        for f=1:length(OutN)
            if OutN(f,r) > th
                Pred(f)= 1;
            end
        end
        P=[P,Pred];
    end
    P=logical(P);
    
    CMAT_seq=cell(4,1);
    for c=1:size(OutN,2)
        CM=confusionmat(Lab(:,c),P(:,c));
        if numel(CM)==1
            if sum(Lab(:,c))==0
                CM=[CM,0;0,0];
            else
                CM=[0,0;0,CM];
            end
        end
        CMAT_seq{c}=CM;
    end
    
    CMAT{s}=CMAT_seq;
    
end
