function [envelope,peaks,valleys] = WNRateEstimate(audio,fs,op_fs,usepitch,peakthr)
% function [envelope,peaks,valleys] = WNRateEstimate(audio,fs,op_fs,usepitch,peakthr)
%
% Performs sonority curve computation and syllable-rate estimation using
% the approach of Wang & Narayanan (2007).
%
% Full citation: D. Wang & S. Narayanan (2007). Robust speech rate estimation
% for spontaneous speech. IEEE Trans. Audio, Speech, and Language
% Processing, vol. 15, no. 8, Nov. 2007.
%
% Default parameter values are taken from the original paper except for the
% peak detection threshold due to different filterbank implementation 
% 
% Uses Gammatone filterbank by Ning Ma taken from
% http://staffwww.dcs.shef.ac.uk/people/N.Ma/resources/gammatone/
% 
% Uses YAAPT pitch tracker by Zahorian & Hu (2008) to do pitch-based
% pruning.
%
% Current implementation uses YAAPT-pitch tracker to perform pitch
% estimation.
%
% Note: Pitch estimation slows down processing notably.
% 
% Inputs
%       audio       : audio wave-file
%       fs          : audio sampling rate (Hz)
%       op_fs       : sampling rate of the rate-estimator (default 100 Hz)
%       usepitch    : do pitch-based pruning of peaks? 0/1 (default 0)
%       peakthr     : relative increase in sonority from the last minima  
%                     required for a peak to be considered as a nucleus 
%                     (default = 0.1; overall utterance-level scale is 0-1)
%                     
%
% Outputs
%       envelope    : sonority envelope of the input
%       peaks       : syllable nuclei locations (in samples)
%       valleys     : syllable boundary locations (in samples). Note that
%                     valleys are automatically added to the beginning and 
%                     end of the signal.  
% 
% Implementation by Okko Rasanen (okko.rasanen@aalto.fi), 3.9.2015
% 
% v1.1 (2.3.2018): switched the ordering of sub-band selection to precede
% temporal correlation for slightly improved speed and to follow Wang & Narayanan
% (2007) in detail (neglible impact on performance). Also corrected
% variance of temporal smoothing Gaussian kernels to match MATLAB normpdf()
% input syntax.

if nargin <5
    peakthr = 0.12;
end

if nargin <4
    usepitch = 0; % Use pitch-based pruning of peaks?
end

if nargin <3
    op_fs = 100;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1) Filter to 19 sub-band energies using a Gammatone filterbank

minfreq = 100;
maxfreq = 7500;
bands = 19;

cfs = [];
const = (maxfreq/minfreq)^(1/(bands-1));

cfs(1) = 100;
for k = 1:bands-1
    cfs(k+1) = cfs(k).*const;
end

env = zeros(length(audio),length(cfs));
for cf = 1:length(cfs)
    [~,env(:,cf), ~, ~] = gammatone_c(audio, fs,cfs(cf));
end


env = resample(env,op_fs,fs);

env = real(env);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2) Sub-band selection

M = 12;     % How many sub-bands to include?
E = zeros(size(env,2),1);
for cf = 1:size(env,2)
    E(cf) = env(:,cf)'*env(:,cf);       
end

[~,i] = sort(E,'descend');
env = env(:,i(1:M));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3) Temporal processing

K = 11*op_fs/100;
% Define weighting window
wvar = 1.2*op_fs/100;
w = normpdf(1:K-1,(K-1)/2,sqrt(wvar));
normalizer = 1/(2*K*(K-1));

z_out = zeros(size(env));

% Go through all select sub-bands
for cf = 1:size(env,2)
    
    y = env(:,cf);
 
    x = filter(w,1,y);
    %x = [x((K-1)/2:end);zeros((K-1)/2,1)];
    
    % Temporal correlation within the sub-band 
    
    z = zeros(size(y));
    for t = 1:length(x)-K+1
        for j = 0:K-2
            for p = j+1:K-1
                z(t) = x(t+j)*x(t+p);
            end
        end
    end
    z = sqrt(z./normalizer);
    
    z_out(:,cf) = z;    
end
z_out = real(z_out);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4) Spectral sub-band correlation

y = zeros(length(z_out),1);
for n = 1:size(z_out,1)
    for i = 1:M-1
        for j = i+1:M
            y(n) = y(n)+z_out(n,i)*z_out(n,j);
        end
    end
end

y = y./M;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4) Temporal smoothing

wlen = 15*op_fs/100;
smooth_var = 1.3*op_fs/100;

wsmooth = normpdf(1:wlen,wlen/2,sqrt(smooth_var));

envelope = filter(wsmooth,1,y);

%lenfix = round(wlen/2);
%envelope = [envelope(lenfix:end);zeros(lenfix-1,1)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5) Pitch extraction
if(usepitch)
    %yaapt(Data, Fs, VU, ExtrPrm, fig, speed)
    [Pitch, numfrms, frmrate] = yaapt(audio, fs,1,[],0,2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6) Peak detection

envelope = envelope./max(envelope); % Normalize to 0-1

peakdist = 13*op_fs/100;


[maxtab,mintab] = peakdet(envelope,peakthr);

% Peak locations
if(~isempty(maxtab))
    locs = maxtab(:,1);
    tmp = diff(locs);
    tmp2 = find(tmp < peakdist)+1;
    maxtab(tmp2,:) = [];
    
    % Is voiced?
    if(usepitch)
        a = Pitch(maxtab(:,1) == 0);
        maxtab(a,:) = [];
    end
    
    peaks = maxtab(:,1);
else
    peaks = [];
end

% Valley locations

if(~isempty(mintab))
    
    locs = mintab(:,1);
    tmp = diff(locs);
    tmp2 = find(tmp < peakdist)+1;
    mintab(tmp2,:) = [];
    
    
    % Is voiced?
    if(usepitch)
        a = Pitch(mintab(:,1) == 0);
        mintab(a,:) = [];
    end
    
    valleys = mintab(:,1);    
else
    valleys = [];
end

% Add onset if onset not already detected
 
addstart = 0;
if(~isempty(valleys))    
        if(valleys(1) > 0.05*op_fs)
            addstart = 1;
        end
else
    addstart = 1;
end
if(addstart)
    valleys = [1;valleys];
end

% Add offset if offset not already detected
addend = 0;
if(~isempty(valleys))
    if(valleys(end)+0.05*op_fs < length(envelope))
        addend = 1;
    end
else
    addend  = 1;
end
if(addend)
    valleys = [valleys;length(envelope)];
end
