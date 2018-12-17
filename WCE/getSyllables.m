function syl_envelope = getSyllables(algo,filenames,conf)
% function syl_envelope = getSyllables(algo,filenames,conf)

if nargin <3
    error('config not provided')
end

syl_envelope = cell(length(filenames),1);

if(strcmpi(algo,'thetaSeg'))    
    [~,~,syl_envelope] = thetaseg(filenames,0.005,conf.spectral_subtraction);    
    for k = 1:length(syl_envelope)        
       syl_envelope{k} = resample(syl_envelope{k},1,10);       
    end
elseif(strcmpi(algo,'WN'))
    for k = 1:length(filenames)
        
        [audio,fs] = audioread(filenames{k});
        if(fs ~= 16000)
            audio = resample(audio,16000,fs);
            fs = 16000;
        end
        
        
        if(conf.spectral_subtraction == 1)
            audio = specsub(audio,fs);
        end
        
       [syl_envelope{k}] = WNRateEstimate(audio,fs,100,0,0.1); 
       procbar(k,length(filenames));
    end
    
elseif(strcmpi(algo,'LSTMseg'))
    % Use a specific LSTM model if specified
    if(~isfield(conf,'syl_modelname'))
        modelname = [];
    else
        modelname = conf.syl_modelname;
    end
    
    % limit size of the LSTM segmentation call on VM to avoid out-of-memory
    % issues
    
    maxlen = 1000;        
    
    %[syl_envelope] = LSTMseg(filenames,modelname,conf.store_features,conf.spectral_subtraction);
        
    syl_envelope = cell(length(filenames),1);
    
    n_chunks = ceil(length(filenames)/maxlen);
    wloc = 1;
    
    for chunk = 1:n_chunks
        
        inds = wloc:min(wloc+maxlen-1,length(filenames));
        
        syl_envelope(inds) = LSTMseg(filenames(inds),modelname,conf.store_features,conf.spectral_subtraction);
                
        wloc = wloc+maxlen;
    end
    
elseif(strcmpi(algo,'duration-bl'))
    for k = 1:length(filenames)
        [x,fs] = audioread(filenames{k});        
        len = round(length(x)/fs.*100);
        tmp = zeros(len,1);
        tmp(1:10:end) = 1;
        syl_envelope{k} = tmp;
    end
    
else    
    error('Unknown syllable envelope estimation algorithm: %s.',algo{1})
end