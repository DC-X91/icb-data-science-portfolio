function [loglike,predictions] = loglike_srt_exgauss(data,modelpars,ub)
%LOGLIKE_SRT_EXGAUSS Finds log-likelihood of response time data under a shifted
%log-logistic distribution model of response time
%   Detailed explanation goes here

%===============================================================================
%% Load empirical data and correct
%===============================================================================

data = data(:);
ntrials = numel(data);
if exist('ub','var'); cutoff = true; else, ub = inf; cutoff = false; end
ignore_trials = isnan(data);
miss_trials = data > ub;
success_trials = ~ignore_trials & ~miss_trials;


%===============================================================================
%% Find log-likelihood
%===============================================================================

likelihood = zeros(ntrials,1);
modelpars = num2cell(modelpars);

likelihood(success_trials) = exgausspdf(data(success_trials),modelpars{:});

if cutoff || nargout == 2
   probmiss = 1 - exgausscdf(ub,modelpars{:});
   likelihood(miss_trials) = probmiss;
end

likelihood(ignore_trials) = 1;

loglike = sum(log(likelihood(:)));
if isnan(loglike); loglike = -inf; end

if nargout == 2
   t = linspace(0,ub,10^6)';
   f = exgausspdf(t,modelpars{:});
   predictions.pdf = [t f];
   predictions.probmiss = probmiss;
end

end
