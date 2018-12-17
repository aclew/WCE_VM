function procbar(k,N)
% function procbar(k,N)
% Draws processing bar for k:th iteration of a total of N iterations

  %----------------------------------------
    % Draw the processing bar
    %----------------------------------------
    percent_done = k/N;
    bar = [];
    if(percent_done*40 > 1)
        for x = 1:percent_done*40;
            bar = [bar '|'];
        end
    else
        x = 0;
    end
    %
    for y = 1:40-x
       bar = [bar ' ']; 
    end    
    if(k == 1)
        fprintf('[%s]',bar)
        fprintf('(%0.6d)',k);
    else
        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b[%s](%0.6d)',bar,k);
    end
                                              
    %----------------------------------------
    
end