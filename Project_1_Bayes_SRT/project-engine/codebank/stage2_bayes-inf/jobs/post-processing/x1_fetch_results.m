% Script to generate all [root]results.mat files containing results of Bayesian
% inference per (model,prior,dataset) combination for the simulation study
% ==============================================================================

%studyid = 'sim-study';
%datasetroot = [projectdir filesep 'results' filesep studyid filesep ...
%               'stage2_bayes-inf' filesep datasetid];

clear; close all;
startdir = ['results' filesep 'sim-study' filesep 'stage2_bayes-inf' ...
            filesep 'dataset-'];
startdir = fullfile(projectdir(),startdir);
datasetids = {'wald-shift' 'exgaussian' 'exwald' 'rocdd'};

modelids = datasetids;
modelcode = {'waldshift','exgauss','exwald','rocdd'};
modeldict = containers.Map(modelids,modelcode);

results_aggr = cell(1000,1);
results_unit = cell(1000,1);
ctr_aggr = 1;
ctr_unit = 1;

%% DATASET ROUTINE
for iid = 1:length(datasetids)
   
   dirdatasetcurrent = strcat(startdir,datasetids{iid});
   dirsubjectlist = dir([dirdatasetcurrent filesep 'subject-*']);
   dataset = ['sim250-' datasetids{iid}];
   
   %% SUBJECT ROUTINE
   for iis = 1:length(dirsubjectlist)
      
      % Get paths to jobs within this subject's directory
      dirsubjectcurrent = ...
         fullfile(dirsubjectlist(iis).folder,dirsubjectlist(iis).name);
      dirjoblist = dir([dirsubjectcurrent filesep 'model-*']);
      
      % Extract model name from standard directory name structure:
      f = @(x,y) strfind(x,y);
      model = extractBetween(dirjoblist(iis).name,'model-','_prior');
      g = @(x) f(model,x);
      startidx = arrayfun(g,modelids,'UniformOutput',false);
      modelidx = ~cellfun(@isempty,startidx);
      model = modelids(modelidx);
      
      % Fetch parameter information to place into metadata: 
      prefix = modeldict(model{1});
      infofuncs = str2func([prefix 'parinfo']);
      pars = infofuncs();
      
      % Fetch full path to chains for ensemble statistics construction later:
      
      
      %% UNIT JOB ROUTINE
      for iij = 1:length(dirjoblist)
         
         dirjobcurrent = fullfile(dirjoblist(iij).folder,dirjoblist(iij).name);
         jobid = extractAfter(dirjoblist(iij).name,'job-');
         
         dirchains = dir([dirjobcurrent filesep 'chains*']);
         dirchains = fullfile(dirchains(1).folder,dirchains(1).name);
         fileschains = dir([dirchains filesep '*.txt']);
         chainsroot = strrep(fileschains(1).name,'.txt','');

         savepath = [dirjobcurrent filesep chainsroot 'results.mat'];
         
         results_unit{ctr_unit} = unitary_inferstats(dirchains, ...
                                     'save',false,'savepath',savepath);
                                    %'metadata',passmd, ...

         ctr_unit = ctr_unit + 1;
         
      end
      
      
      %% ENSEMBLE ROUTINE
      metadata = bimdmake('ensemble');
      metadata.jobid = jobid;
      metadata.dataset = dataset;
      metadata.model = model;
      metadata.prior = 'moments';
      metadata.parnames = pars.Names;
      metadata.pardescriptions = pars.Description;

      results_aggr{ctr_aggr} = ...
         ensemble_inferstats(currentjobdir,'subject-','metadata',metadata);

      passmd = bimdchangetype(metadata);

      ctr_aggr = ctr_aggr + 1;

   end
end

%results_aggr = results_aggr(1:ctr_aggr-1);
results_unit = results_unit(1:ctr_unit-1);

clearvars -except results_unit %results_aggr
