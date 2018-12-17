function [F,E] = haeMelPiirteet(data_train,wl,ws,opfreq,usespecsub)

% Onko zero padding?

if nargin <5
    usespecsub = 0;
end

if nargin <4    
opfreq = 16000;
end

if nargin <3
    ws = 0.0125*opfreq;
else
    ws = round(ws*opfreq);
end
if nargin <2
    wl = 0.025*opfreq;
else
    wl = round(wl*opfreq);
end

ww = hamming(wl);
F = cell(length(data_train),1);
E = cell(length(data_train),1);

[MEL,MN,MX]= melbankm(24,wl,16000,0,0.5,'u');

for signal = 1:length(data_train)
    try
        [x,fs] = audioread(data_train{signal});
    catch
        [x,fs] = readsph(data_train{signal});
    end
   
   if(fs ~= opfreq)
       x = resample(x,opfreq,fs);
       fs = opfreq;
   end
   
   x = [zeros(round(wl/2),1);x;zeros(round(wl/2),1)];
      
   if(usespecsub)
       x = specsub(x,fs);
   end
      
   
   S = zeros(round(length(x)/ws)-2,size(MEL,1));
   E{signal} = zeros(round(length(x)/ws)-2,1);
   j = 1;
   for loc = 1:ws:length(x)-wl+1
       y = x(loc:loc+wl-1).*ww;
       tmp = abs(fft(y));
       tmp = tmp(2:wl/2);
       y = MEL*tmp;
       y = 20*log10(y);
       
       %figure(6);plot(y);
       %pause;
       
       S(j,:) = y;
       E{signal}(j) = sum(tmp);
       j = j+1;       
   end      
   
   F{signal} = S;
       
    procbar(signal,length(data_train));
end