function [ out_pred ] = hangover( in_pred, th )
    
    L = length(in_pred);
    out_pred = zeros(L,1);

    hangOver = 0;
    MIN_SPEECH_FRAME = 2;
    HANGOVER = 8;
    count = 0;
    
    for i=1:L
        if in_pred(i) > th
            out_pred(i) = 1;
            count = count + 1;
            if count > MIN_SPEECH_FRAME
                hangOver = HANGOVER;
            end
        else
            if (hangOver == 0)
                out_pred(i) = 0;
            else
                out_pred(i) = 1;
                hangOver = hangOver - 1;
            end
        end
    end


end

