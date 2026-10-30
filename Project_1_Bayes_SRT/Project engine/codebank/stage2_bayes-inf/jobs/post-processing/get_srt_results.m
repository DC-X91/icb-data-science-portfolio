addpath('~/Dropbox/Work/1-Research/investigations/bayes-srt/_tools/bayes-inf/post-processing/extract')

%% 
%-------------------------------------------------------------------------------

dataset = 'srt-subject';  
chainspath = '~/Dropbox/Work/1-Research/investigations/bayes-srt/results/bayes-inf/study-1/srt-subject';
prefix = 'job_';

S = {'distfit-burr'               '20180710'    'subject'   'fit-'; ...
     'distfit-gev'                '20180704'    'subject'   'fit-'; ...
     'distfit-stable'             '20180704'    'subject'   'fit-'; ...
     'lca-trial'                  '1860293'     'subject'   'neurofit-'; ...
     'srt-brownian-trial'         '20181117'    'subject'   'neurofit-'; ...
     'srt-brownian-trial-p'       '20181117'    'subject'   'neurofit-'; ...
     'srt-dd-collapsing-bounds'   '123990'      'subject'   'neurofit-'; ...
     'srt-dd-variable-drift'      '76189'       'subject'   'neurofit-'; ...
     'srt-dd-variable-params'     '72810'       'subject'   'neurofit-'; ...
     'srt-thresh-lin-trial-indn'  '2396382'     'subject'   'neurofit-'; ...
     'thresh-trial-indn'          '2052590'     'subject'   'neurofit-'};

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


%% Computte results
%-------------------------------------------------------------------------------

srt_results = aggregate_results(T);
clearvars -except srt_results