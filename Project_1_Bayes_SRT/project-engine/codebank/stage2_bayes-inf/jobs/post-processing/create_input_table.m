%% 
%-------------------------------------------------------------------------------

dataset = 'sim-data';  
chainspath = '~/Dropbox/Work/1-Research/investigations/bayes-srt/results/bayes-inf/sim-data/';
prefix = 'job_';

S = {'driftdiff'           '1985188'      'subject'      'neurofit-';
     'exgaussian'          '1985181'      'subject'      'neurofit-';
     'loglogistic_shift'   '1985192'      'subject'      'neurofit-';
     'wald_shift'          '1985179'      'subject'      'neurofit-';
    };
S = cell2table(S,'VariableNames',{'Model','Job','partname','root'});
nmodels = size(S,1);


%% Create input table
%-------------------------------------------------------------------------------

T = cell(nmodels,4);
headers = {'jobdir','partname','root','optargs'};

for ii = 1:nmodels
   T{ii,1} = [chainspath '/' S.Model{ii} '/' prefix S.Job{ii} '/chains'];
   T{ii,2} = S.partname{ii};
   T{ii,3} = S.root{ii};
   r = struct('chains',[],'dataset',[],'model',[],'parnames',[]);
   r.chains = S.Job{ii};
   r.dataset = dataset;
   r.model = S.Model{ii};
   T{ii,4} = r;
end

T = cell2table(T,'VariableNames',headers);
clearvars -except T
save('cache/input-table.mat');
