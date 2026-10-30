% Script to extract a single subject's results across selected models in the
% simulation study of MultiNest for the SRT.
%*******************************************************************************

close all; clear;

%% PRELIMINARIES
%===============================================================================

study = 'sim-study';
corpus = {'wald-shift','exgaussian','exwald','rocdd'};
corpuscode = {'WSH','EXG','EXW','RDD'};
ncorpora = length(corpus);
nsubjects = 5;
subjectids = [6 7 8 9 10; 11 12 13 14 15; 16 17 18 19 20; 1 2 3 4 5];
N = ncorpora*nsubjects;

bayesfac = zeros(N,ncorpora);

comparisondata = cell(N,1);
evidencetable = cell(N,1);

it = 0;

for ic = 1:ncorpora

   for is = 1:nsubjects
      
      it = it + 1;
      
      % Specify data-set:

      unitid = sprintf('%0*d',length(num2str(N)),subjectids(ic,is));
      unit = ['subject-' unitid];
      datasetroot = [projectdir() filesep 'results' ...
                                  filesep study ...
                                  filesep 'stage2_bayes-inf' ...
                                  filesep 'dataset-' corpus{ic} ...
                                  filesep unit];
      subnumstr = sprintf('%0*d',length(num2str(nsubjects)),is);
      datasetid = strcat(corpuscode{ic},subnumstr);

      % Specify set of models to be compared:

      jobcodes = {'2268416', ...
                  '2288507', ...
                  '2295764', ...
                  '2300542', ...
                  '2427663'};
                  %}; %, ...
                  

       modelid = {'RDD-QD1a', ...
                  'RDD-QD1b', ...
                  'RDD-QD1c', ...
                  'RDD-QD2', ...
                  'RDD-QD3'};
                  %, ...




      %% SUBJECT/MODEL RESULTS
      %===============================================================================
      
      % Get basic results for each subject:
      inptbl = prepcomptable(datasetroot,'unitary',jobcodes,'modelnames',modelid);
      comparisondata{it} = comparison_inferstats(inptbl,'sort');
      evidencetable{it} = bayesfactors(comparisondata{it},'best');
      critcomp.(datasetid) = infocrit(comparisondata{it},250,'unitary');
      
      % Display results:
      rule = repmat('-',1,70);
      msg = sprintf('%s\n\nDataset %s%s results:\n',rule,datasetid);
      disp(msg);
      disp(evidencetable{it});
      
      for ii = 1:length(modelid)
         idx = find(ismember(evidencetable{it}.Model,modelid{ii}));
         bayesfac(it,ii) = evidencetable{it}.pos2lnB10(idx); 
      end

   end
end

disp(rule);

imagesc(-bayesfac);

ax = gca;
ax.CLim = [-10 10];
cmap(1:500,1) = 1;
cmap(501:1000,1) = 1 - linspace(0,1,500);
cmap(1:500,2) = linspace(0,1,500);
cmap(501:1000,2) = 1;
cmap(1:500,3) = linspace(0,1,500);
cmap(501:1000,3) = 1 - linspace(0,1,500);
colormap(cmap);

%*******************************************************************************
