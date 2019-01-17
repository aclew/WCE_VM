function envelope = LSTMseg(filenames,modelname,store_tmp,usespecsub)
% function envelope = LSTMseg(filenames,modelname,store_tmp)
%
%

if nargin <4
    usespecsub = 0;
end

if nargin <3
    store_tmp = 0;
end

% Edit the path below to point to your Python 2.7 binary that has Keras and
% Theano or Tensorflow installed.
if(exist('/Users/rasaneno/anaconda/bin/','dir'))
    python_path = '/Users/rasaneno/anaconda/bin/';
elseif(exist('/anaconda3/bin/','dir'))
    python_path = '/anaconda3/bin/';
else
    python_path = '';
end

if nargin <2
     modelname = 'BLSTM_60_60_Estonian_Korean_Augmented.h5';
elseif(isempty(modelname))
     modelname = 'BLSTM_60_60_Estonian_Korean_Augmented.h5';
end

[a,b1,c] = fileparts(filenames{1});
[a,b2,c] = fileparts(filenames{end});

selfdir = fileparts(which('LSTMseg'));

feature_file = [selfdir sprintf( '/tmp_files/feats_tmp_%d_%0.0f_%s_%s_%d.mat',length(filenames),mean(cellfun(@length,filenames)),b1,b2,usespecsub)];

if(~exist(feature_file,'file'))
    F_test = haeMelPiirteet(filenames,0.025,0.01,16000,usespecsub);    
    if(store_tmp)
    save(feature_file,'F_test');
    end
elseif(store_tmp) % load only if storing is used
    load(feature_file);
    if(~exist('F_test','var'))
        F_test = F_train;
    end
else
    F_test = haeMelPiirteet(filenames,0.025,0.01,16000,usespecsub);    
end

fprintf('\n\n');

% Load params and normalization factors
curdir = fileparts(which('LSTMseg.m'));
load([curdir sprintf('/trained_models/LSTM_params_%s.mat',modelname)],'wl','ws','meme','devi'); 

totframes_test = sum(cellfun(@length,F_test));
wloc = 1;
Fall_test = zeros(totframes_test,size(F_test{1},2));
timestamps = zeros(totframes_test,2);

utlen = zeros(length(F_test),1);
for k = 1:length(F_test)
   Fall_test(wloc:wloc+size(F_test{k},1)-1,:) = F_test{k};
   timestamps(wloc:wloc+size(F_test{k},1)-1,1) = k;
   timestamps(wloc:wloc+size(F_test{k},1)-1,2) = (1:size(F_test{k},1))';
   utlen(k) = size(F_test{k},1);
   wloc = wloc+size(F_test{k},1);
end
Fall_test = Fall_test(1:wloc-1,:);
timestamps = timestamps(1:wloc-1,:);

Fall_test = Fall_test-repmat(meme,size(Fall_test,1),1);
Fall_test = Fall_test./repmat(devi,size(Fall_test,1),1);

% Make sure that the length of the data is equal to multiple of window
% length to avoid any clipping of endings

tmp = mod(size(Fall_test,1),ws);

if(tmp ~= 0)
    Fall_test = [Fall_test;zeros(tmp,size(Fall_test,2))];      
    timestamps = [timestamps;zeros(tmp,size(timestamps,2))];
end


% Chunk into segments for DNN training

total_slices = ceil(size(Fall_test,1)./ws);

X_test_in = zeros(total_slices,wl,size(Fall_test,2));
timestamps_in = zeros(total_slices,wl,2);

cc = 1;
for wloc = 1:ws:size(Fall_test,1)-wl+1
    X_test_in(cc,:,:) = Fall_test(wloc:wloc+wl-1,:);   
    timestamps_in(cc,:,:) = timestamps(wloc:wloc+wl-1,:);
   cc = cc+1;     
end

X_test_in(isinf(X_test_in)) = 0;
X_test_in(isnan(X_test_in)) = 0;


a = whos('X_test_in');
if(a.bytes-2e9 > 0) % Need to split into multiple files?
    chunks = ceil(a.bytes/2e9);
    
    chunksize = round(size(X_test_in,1)/chunks);
    
    X_in_chunk = cell(chunks,1);
    for c = 1:chunks
        X_in_chunk{c} = X_test_in((c-1)*chunksize+1:min(size(X_test_in,1),c*chunksize),:,:);
        if(c < chunks)
            X_in_chunk{c}(end,end,end) = 1;
        end
        
        curdir = fileparts(which('LSTMseg'));
        save_filename = [curdir sprintf('/data_in_%d.mat',c)];        
        X_in = X_in_chunk{c};
        save(save_filename,'X_in'); 
    end    
else
    curdir = fileparts(which('LSTMseg'));
    save_filename = [curdir '/data_in_1.mat'];
    X_in = X_test_in;
    save(save_filename,'X_in');    
end

%fprintf('%s',save_filename);

ss = [python_path 'python ' curdir '/LSTMseg.py' ' ' '''' curdir '''' ' ' '''' modelname ''''];

rval = system(ss);
if(rval ~= 0)
    error('LSTM segmentation Python call failed. Aborting.');
end

D = importdata([curdir '/data_out.csv']);


%D = filter(ones(3,1)./3,1,D');
%D = D';

% Do overlap and add reconstruction of the envelopes

%ww = hamming(wl)+0.01; % use window to emphasize certain frames
ww = ones(wl,1);

envelope = cell(length(filenames),1);
for k = 1:length(envelope)
   envelope{k} = zeros(utlen(k),1); 
end

maxlen = max(cellfun(@length,F_test));

totsums = zeros(length(filenames),maxlen);

for k = 1:size(D,1)    
    t = squeeze(timestamps_in(k,:,:));    
    for j = 1:size(t,1)
        if(t(j,1) > 0)
        envelope{t(j,1)}(t(j,2)) = envelope{t(j,1)}(t(j,2))+D(k,j)*ww(j);        
        totsums(t(j,1),t(j,2)) = totsums(t(j,1),t(j,2))+ww(j);
        end
    end  
end

for k = 1:length(envelope)
    for j = 1:size(envelope{k},1)
       envelope{k}(j) = envelope{k}(j)./totsums(k,j);
    end    
    envelope{k}(isnan(envelope{k})) = 0;
end



