%
%*******************************************************************************

%% Data
%trialsetid = {'Two-way','Three-way','Four-way'};
% m = [15  15   5];  % number of trials
% k = [ 8   6   2];  % number of successes
% n = [ 2   3   4];   % number of models in pool
trialsetid = {'All ensembles'}; m = 1; k = 1; n = 4;
q0 = 1./n;
priors = {'Bayes-Laplace','Haldane','Jeffreys','Challenge'};


%% Prepare output
ntrialsets = length(trialsetid);
npriors = length(priors);
outtbl = struct('TrialSet',[],'Prior',[],'q_obs',[],'q0',[],'qmax',[], ...
                'PostRatio',[],'Evidence',[],'AbsGain',[],'RelGain',[], ...
                'AllResults',[]);
outtbl(ntrialsets*npriors) = outtbl;


%% Run analyses
c = 1;
for it = 1:ntrialsets
   for ip = 1:npriors
      [alpha,beta] = getpriorhyppars(priors{ip},m(it),q0(it));
      results = beta_prior_update(alpha,beta,m(it),k(it),q0(it));
      eval = evidence_strength(results.stats.postratio_2ln);
      outtbl(c).TrialSet = trialsetid{it};
      outtbl(c).Prior = priors{ip};
      outtbl(c).q_obs = k(it) / m(it);
      outtbl(c).q0 = q0(it);
      outtbl(c).qmax = results.stats.qmax;
      outtbl(c).PostRatio = results.stats.postratio_2ln;
      outtbl(c).Evidence = eval;
      outtbl(c).AbsGain = results.stats.qmax - q0(it);
      outtbl(c).RelGain = (results.stats.qmax - q0(it)) / q0(it);
      outtbl(c).AllResults = results;
      c = c + 1;
   end
end

outtbl = struct2table(outtbl);

%%
function [alpha,beta] = getpriorhyppars(priorname,m,q0)

if strcmpi(priorname,'bayes-laplace'); priorname = 'uniform'; end

switch lower(priorname)
   case 'uniform'
      alpha = 1; beta = 1;
   case 'haldane'
      alpha = 0.01; beta = 0.01;
   case 'jeffreys'
      alpha = 0.5; beta = 0.5;
   case 'challenge'
      s = 1;
      alpha = round(q0*s*m); beta = round(s*m) - alpha;
   otherwise
      error('Prior name not recognised!');
end

end
