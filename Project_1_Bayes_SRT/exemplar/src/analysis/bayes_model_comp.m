function [bayesfac,comparisondata,evidencetables,critcomp] = ...
   bayes_model_comp(studypath,corpora,corpuscode,units,ndatapts,jobids,modelids,refidx)
%BAYES_MODEL_COMP Run a complete posterior Bayesian model selection analysis
%
%*******************************************************************************

%% Parse inputs
ncorpora = length(corpora);
nsubjects = size(units,2);
assert(size(units,1) == ncorpora, ...
       'Input «units» does not have same number of rows as length of «corpora»!');
N = ncorpora*nsubjects;



%% Prepare outputs
bayesfac = zeros(N,ncorpora);
comparisondata = struct('Dataset',[],'ComparisonTable',[]);
comparisondata(N) = comparisondata;
evidencetables = struct('Dataset',[],'EvidenceTable',[]);
evidencetables(N) = evidencetables;
critcomp = struct('Dataset',[],'AllResults',[],'MainTable',[]);
critcomp(N) = critcomp;



%% Main routine

it = 0;

for ic = 1:ncorpora

   for is = 1:nsubjects
      
      it = it + 1;
      
      % Specify data-set:
      datasetroot = [studypath filesep 'dataset-' corpora{ic} ...
                               filesep units{ic,is}];
      subnumstr = sprintf('%0*d',length(num2str(nsubjects)),is);
      datasetid = strcat(corpuscode{ic},subnumstr);


      %% SUBJECT/MODEL RESULTS
      %===============================================================================
      
      % Get basic results for each subject:
      inptbl = prepcomptable(datasetroot,'unitary',jobids,'modelnames',modelids);
      comptable = comparison_inferstats(inptbl);
      comparisondata(it).Dataset = datasetid;
      comparisondata(it).ComparisonTable = comptable;
      
      evtable = bayesfactors(comptable,refidx{ic});
      evidencetables(it).Dataset = datasetid;
      evidencetables(it).EvidenceTable = evtable;
      
      crittable = infocrit(comptable,ndatapts(ic,is),'unitary','ref',refidx{ic});
      critcomp(it).Dataset = datasetid;
      critcomp(it).AllResults = crittable;
      critcomp(it).MainTable = crittable.rankByModel.weightAgainst;
      
      for ii = 1:length(modelids)
         idx = find(ismember(evtable.Model,modelids{ii}));
         bayesfac(it,ii) = evtable.pos2lnB10(idx); 
      end
      
      % Display results:
      rule = repmat('=',1,70);
      msg = sprintf('%s\n\nDataset %s%s results:\n',rule,datasetid);
      disp(msg);
      disp(evtable);
      disp(crittable.rankByModel.weightAgainst);

   end
end

disp(rule);

end
