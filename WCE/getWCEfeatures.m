function X = getWCEfeatures(files,conf,syl_envelope)
% function X = getWCEfeatures(files,conf,syl_envelope)
%
% This function computes features from sonority envelopes and audio signals
% to be used for word count estimation, as specified in configuration file
% "conf". 

X = [];

if(cellfind(conf.features,'duration'))
    durs = (cellfun(@length,syl_envelope)./100);
    X = [X durs];
end
if(cellfind(conf.features,'sonority_total_energy'))
    en_sonor_total = cellfun(@sum,syl_envelope);
    X = [X en_sonor_total];
end

if(cellfind(conf.features,'sonority_mean_energy'))
    en_sonor_mean = cellfun(@mean,syl_envelope);
    X = [X en_sonor_mean];
end

if(cellfind(conf.features,'sonority_SD_energy'))
    en_sonor_sd = cellfun(@std,syl_envelope);
    X = [X en_sonor_sd];
end

if(~isempty(cellfind(conf.features,'signal_mean_energy')) || ~isempty(cellfind(conf.features,'signal_total_energy')))
    % add all signal based features inside the same loop to avoid multiple
    % reading of the files
    
    en = zeros(length(files),1);
    entot = zeros(length(files),1);
    
    for k = 1:length(files)
        [x,fs] = audioread(files{k});
        if(fs ~= 16000)
            x = resample(x,16000,fs);
            fs = 16000;
        end
        
        en(k) = 20*log10((x'*x)/length(x));
        entot(k) = 20*log10(x'*x);        
    end
    
    if(cellfind(conf.features,'signal_mean_energy'))
        X = [X en];
    end
    if(cellfind(conf.features,'signal_total_energy'))
        X = [X entot];
    end
end



