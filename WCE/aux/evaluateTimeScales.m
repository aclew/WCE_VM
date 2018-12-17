function [RMSE_lp,realdur] = evaluateTimeScales(files_test,counts_estimated,test_counts,durations_to_test)

if nargin <4
    durations_to_test = [2,5,10,30,150,300];
end

test_dur = zeros(length(files_test),1);
for k = 1:length(files_test)
   i = audioinfo(files_test{k});
   test_dur(k) = i.Duration;
end

% Need to scramble order? No, it will make errors more IID --> use the
% original data order.
%ord = randperm(length(test_dur));
ord = 1:length(test_dur);
test_dur_n = test_dur(ord);
counts_estimated_n = counts_estimated(ord);
test_counts_n = test_counts(ord);

utt_duration_cum = cumsum(test_dur_n);

duriter = 1;
endpoint = ones(length(durations_to_test),length(test_dur_n)).*NaN;
for dur = durations_to_test
    rah = 1;
    for j = 1:length(test_dur_n)
        if(j > 1)
            curval = utt_duration_cum(j-1);
        else
            curval = 0;
        end
        tmp = find(utt_duration_cum(j:end)-curval >= dur,1);
        if(~isempty(tmp))
            endpoint(duriter,rah) = tmp-1;
            rah = rah+1;
        end
    end
    duriter = duriter+1;
end

RMSE_lp = zeros(length(durations_to_test),1);
realdur = zeros(length(durations_to_test),1);

duriter = 1;
for dur = durations_to_test
    est_lp = [];
    ref_lp = [];
    dur_lp = [];
    for k = 1:length(test_dur_n)
        if(~isnan(endpoint(duriter,k)))
            est_lp(k) = nansum(counts_estimated_n(k:k+max(0,endpoint(duriter,k)-1))); 
            ref_lp(k) = nansum(test_counts_n(k:k+max(0,endpoint(duriter,k)-1)));
            dur_lp(k) = nansum(test_dur_n(k:k+max(0,endpoint(duriter,k)-1)));
        end
    end
    RMSE_lp(duriter) = sqrt(mean(((est_lp-ref_lp)./ref_lp).^2))*100;
    realdur(duriter) = mean(dur_lp);
    duriter = duriter+1;
end

