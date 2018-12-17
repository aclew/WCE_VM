function WCEtrain(files_train,train_counts,modelfile,configfile,alpha)
% function WCEtrain(files_train,train_counts,modelfile,configfile,alpha)
%
% Trains a word count estimator (WCE) from a list of utterances and the
% corresponding number of words in each. 
% 
% Inputs:
% 
%       files_train          = list of signal files to train (a cell
%                             array or pointer to a .csv/.txt file with one
%                             utterance .wav per row)
%       train_counts        = word counts corresponding to train files (a
%                             vector or path to a .csv/.txt file with one 
%                             integer per row)
%       modelfile           = file where the model is stored
%       configfile          = configuration file to be used
%       alpha               = recall of the SAD (0-1) preceding the WCE
%                             block. Uused to correct count predictions by  
%                             corrected = original/alpha. Default = 1.
%
% Usage examples:
%
%   WCE(files_train,train_counts) trains a model using the
%       default configuration (configs/config_default.m) and stores it
%       as the new default model (models/model_default.mat).
%
%   WCE(files_train,train_counts,modelfile,configfile) trains a model using
%       user-specified configuration file (specified by configfile) and
%       stores the model with user-specified path and name.
%
%   WCE(files_train,train_counts,modelfile,configfile) trains a model using
%       user-specified configuration file (specified by configfile) and
%       stores the model with user-specified path and name.
%
% (c) Okko Rasanen, okko.rasanen@aalto.fi. 


if(isdeployed)
    %maindir = fullfile(pwd,'/');
    maindir = '~/repos/WCE_Beta/';
else
    maindir = fileparts(which('WCEtrain.m'));
end

if nargin <5
    alpha = 1;
elseif(ischar(alpha))
    alpha = importdata(alpha);
end

if nargin <4
    configfile = [maindir '/configs/config_default.txt'];
elseif(isempty(configfile))
    configfile = [maindir '/configs/config_default.txt'];    
else
    configfile = fullfile(configfile);
end
if nargin <3
    modelfile = [maindir '/models/model_default.mat'];
elseif(isempty(modelfile))
    modelfile = [maindir '/models/model_default.mat'];
else
    modelfile = fullfile(modelfile);
end

if nargin <2
    error('input word/syllable counts not specified');
end

if nargin <1
    error('input data files not specified');
end


if(~iscell(files_train))
    try
        files_train = importdata(files_train);
    catch
       error('Cannot read training data files. Please check format.'); 
    end
end



if(ischar(train_counts))
    try
        train_counts = importdata(train_counts);
    catch
       error('Cannot read training data word counts. Please check format.'); 
    end
end


if(length(files_train) ~= length(train_counts))   
   error('the number of input files does not match the size of the word count vector'); 
end

if(~isdeployed)
    addpath([maindir '/LSTMseg']);
    addpath([maindir '/WN_rate_estimator']);
    addpath([maindir '/thetaOscillator']);
    addpath([maindir '/aux/']);
    addpath([maindir '/voicebox/']);
end

if(exist(modelfile,'file'))
   fprintf('Overwriting existing model of the same name: %s.\n',modelfile); 
end

if(~exist(configfile,'file'))
    error('Could not find config file: %s',configfile);    
end


% Load config

WCEmodel = struct;

WCEmodel.configfile = configfile;
WCEmodel.modelfile = modelfile;

% Load config
try
    tmp = importdata(configfile);
    for k = 1:size(tmp,1)       
       eval(tmp{k}); 
    end
        
catch CONFER
    disp('Could not load WCE config. Check config specifications and error below.');    
    rethrow(CONFER)
end
fprintf('Training WCE using %s\n',conf.name);

if(conf.verbose)
    fprintf('Config file: %s.\n',configfile);
    fprintf('Model file: %s.\n',modelfile);
    fprintf('------------------------------ \n');
    fprintf('Features to include: \n');
   for k = 1:length(conf.features)
       fprintf('%s\n',conf.features{k});
   end
   fprintf('------------------------------ \n');
   fprintf('Syllabifier: %s.\n',conf.syl_method);
    
end

% Extract envelope features
syl_envelope_train = getSyllables(conf.syl_method,files_train,conf);

% Get thresholds from config
thrvals = conf.syl_thrvals;

% Estimate the best syllable detection threshold that has a linear
% relationship to the target word counts 
nuclei_est = zeros(length(syl_envelope_train),length(thrvals));
for k = 1:length(syl_envelope_train)
    thriter = 1;
    for thr = thrvals          
        [dih,duh] = peakdet(syl_envelope_train{k},thr);
        nuclei_est(k,thriter) = size(dih,1);               
        thriter = thriter+1;
    end    
end

% Find the best linear correlation (since linear mapping is also used)

if(size(train_counts,2) > size(train_counts,1))
    train_counts = train_counts';
end

corvals = zeros(length(thrvals),1);
for k = 1:length(thrvals)            
    corvals(k) = corr(train_counts,nuclei_est(:,k));
end

max(corvals)

[~,i] = max(corvals);

best_thr = thrvals(i);
nuclei_counts = nuclei_est(:,i);

WCEmodel.syl_thr = best_thr;

X_other = getWCEfeatures(files_train,conf,syl_envelope_train);

X = [nuclei_counts X_other];

M = regress(train_counts,X);

est_counts = X*M;

% Error on train


RMSE_train = sqrt(mean(((est_counts(train_counts > 0)-train_counts(train_counts > 0))./train_counts(train_counts > 0)).^2))*100;

fprintf('Relative RMSE error on training set: %0.2f%% per SAD segment (r = %0.2f).\n',RMSE_train,corr(est_counts,train_counts));

WCEmodel.M = M./alpha;

WCEmodel.alpha = alpha;


WCEmodel.RMSE_train = RMSE_train;

% Create ID for used training signals

i1 = [files_train{1}(max(1,end-15):end-4) files_train{end}(max(1,end-15):end-4) files_train{round(length(files_train)/2)}(max(1,end-15):end-4) sprintf('_%d_%d',length(files_train),sum(cellfun(@length,files_train)))];

WCEmodel.trainID = i1;

WCEmodel.conf = conf;

save(modelfile,'WCEmodel');

fprintf('WCE adaptation completed.\n');
