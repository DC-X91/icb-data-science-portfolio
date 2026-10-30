function [bayesfac,comparisondata,evidencetables,critcomp] = ...
   bayes_ensemble_comp(studypath,corpora,corpuscode,unitid,ndatapts,jobids,modelids,refidx)
%BAYES_ENSEMBLE_COMP Run a complete posterior Bayesian model ensemble selection
%analysis
%
%*******************************************************************************


%% Parse inputs
ncorpora = length(corpora);
N = ncorpora;



%% Prepare outputs
bayesfac = zeros(N,ncorpora);
comparisondata = struct('Corpus',[],'ComparisonTable',[]);
comparisondata(N) = comparisondata;
evidencetables = struct('Corpus',[],'EvidenceTable',[]);
evidencetables(N) = evidencetables;
critcomp = struct('Corpus',[],'AllResults',[],'MainTable',[]);
critcomp(N) = critcomp;



% Main reoutine
it = 0;

for ic = 1:ncorpora
      
      it = it + 1;
      
      % Specify data corpus:
      datasetroot = [studypath filesep 'results' filesep 'dataset-' corpora{ic}];
      datasetid = strcat(corpuscode{ic});


      %% SUBJECT/MODEL RESULTS
      %===============================================================================
      
      % Get basic results for each subject:
      inptbl = prepcomptable(datasetroot,unitid,jobids,'modelnames',modelids);
      comptable = comparison_inferstats(inptbl,'ensemble',true);
      comparisondata(it).Corpus = datasetid;
      comparisondata(it).ComparisonTable = comptable;
      
      evtable = bayesfactors(comptable,refidx{ic});
      evidencetables(it).Corpus = datasetid;
      evidencetables(it).EvidenceTable = evtable;
      
      crittable = infocrit(comptable,ndatapts(ic),'ensemble','ref',refidx{ic});
      critcomp(it).Corpus = datasetid;
      critcomp(it).AllResults = crittable;
      critcomp(it).MainTable = crittable.rankByModel.weightAgainst;
      
      for ii = 1:length(modelids)
         idx = find(ismember(evtable.Model,modelids{ii}));
         bayesfac(it,ii) = evtable.pos2lnB10(idx); 
      end
      
      % Display results:
      rule = repmat('-',1,70);
      msg = sprintf('%s\n\nData corpus %s results:\n\n',rule,datasetid);
      disp(msg);
      disp(evtable);
      disp(crittable.rankByModel.weightAgainst);

end

disp(rule);

end
