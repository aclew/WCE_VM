function counts_estimated = WCEestimate(files_test,modelfile,outputfile)
% function counts_estimated = WCEestimate(files_test,modelfile,outputfile)
%
% Returns the estimated number number of words in audio utterances using 
% a pre-trained model.
%
% Inputs:
% 
%       files_test          = list of signal files to evaluate (a cell
%                             array or path to a .csv/.txt file with one
%                             utterance .wav per row)
%       modelfile           = model to use
%       outputfile          = file where output word counts are stored (can
%                             be .csv or .mat).
%
% Usage:
%
%   WCEestimate(files_test) estimates the number of words in each utterance
%       listed in files_test using the default model at
%       (models/model_default.mat) and stores the results as a .csv file at
%       outputs/output_default.csv, each row corresponding to the word
%       count estimate for the corresponding signal listed in files_test.
%
%   WCEestimate(files_test,modelfile) estimates the number of words in each 
%       utterance listed in files_test using a user specified model 
%       and stores the results as a .csv file at the default location
%       outputs/output_default.csv.
%
%   WCEestimate(files_test,modelfile,outputfile) estimates the number of 
%       words in each utterance listed in files_test using a user specified
%       model and stores the results either as a .csv or .mat file to the
%       user specified file.
%
% (c) Okko Rasanen, okko.rasanen@aalto.fi. 

if(isdeployed)
    %maindir = fullfile(pwd,'/');
    
    maindir = '~/repos/WCE_VM/';
    
else
    maindir = fileparts(which('WCEtrain.m'));
end


if nargin <3            
    outputfile = [maindir '/outputs/output_default.csv'];    
elseif(isempty(outputfile))
    outputfile = [maindir '/outputs/output_default.csv'];       
else
    outputfile = fullfile(outputfile);
end

if nargin <2
    modelfile = [maindir '/models/model_default.mat'];
    fprintf('WCE model not specified. Using default model at %s.\n',modelfile)
elseif(isempty(modelfile))
    modelfile = [maindir '/models/model_default.mat'];
    fprintf('WCE model not specified. Using default model at %s.\n',modelfile)
else
    modelfile = fullfile(modelfile);
end    

if nargin <1
    error('input data files not specified');
else
    files_test = fullfile(files_test);
end

if(~iscell(files_test))
    try
        files_test = importdata(files_test);
    catch
       error('Cannot read training data files. Please check format.'); 
    end
end

if(~isdeployed)
    addpath([maindir '/LSTMseg']);
    addpath([maindir '/WN_rate_estimator']);
    addpath([maindir '/thetaOscillator']);
    addpath([maindir '/aux/']);
end

load(modelfile);

conf = WCEmodel.conf;

syl_envelope_test = getSyllables(conf.syl_method,files_test,conf);

nuclei_est_test = zeros(length(syl_envelope_test),1);
for k = 1:length(syl_envelope_test)
    [dih,duh] = peakdet(syl_envelope_test{k},WCEmodel.syl_thr);
    nuclei_est_test(k) = size(dih,1);
end

X_other = getWCEfeatures(files_test,conf,syl_envelope_test);

X_test = [nuclei_est_test X_other];

X_test(isnan(X_test)) = 0;
X_test(isinf(X_test)) = 0;

counts_estimated = X_test*WCEmodel.M;


counts_estimated(isinf(counts_estimated)) = 0;
counts_estimated(isnan(counts_estimated)) = 0;
counts_estimated(counts_estimated < 0) = 0;

% Write to output file

[a,b,suf] = fileparts(outputfile);
if(strcmp(suf,'.mat'))
    save(outputfile,'counts_estimated');
elseif(strcmp(suf,'.csv') || strcmp(suf,'.txt'))       
    csvwrite(outputfile,counts_estimated);
end




