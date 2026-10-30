% Script to generate virtual subject SRT data
%
% RNG seed in line 17 should be set to 101 to recreate study results
%*******************************************************************************

saveflag = true;
savepath = fullfile(projectdir,'/data/sim-study/simdata-25k');
%savepath = fullfile(pwd,'/test');
if ~exist(savepath,'dir'); mkdir(savepath); end

model_reg = {'rocdd','wald_shift','exgaussian','exwald'};
ntrials = 25000;
nvsubs = 5;
lb = 120;
ub = 2000;

load model-register.mat
rng(101);
nmodels = length(model_reg);
nsims = nvsubs*nmodels;
[~,nsubs,moments] = find_best_subs(nvsubs);
metadata = struct('subject',[],'simmodel',[],'simpars',[],'modelon',[]);
allRTs = zeros(ntrials,nsims);

k = [1 3 4 7 16];

isim = 1;
for imod = 1:nmodels
   
   model = modelregister(model_reg{imod}).prefix;
   
   pars = load(['mlepars-' model '.mat']);
   f = fieldnames(pars);
   pars = pars.(f{1});
   if isequal(model_reg{imod},'rocdd'); pars = pars(:,1:5); end
   
   simfunc = str2func([model 'rnd']);
   
   for ivsub = 1:nvsubs
      
      s = k(ivsub);
      
      if ~isequal(model_reg{imod},'rocdd')
         p = num2cell(pars(s,:));
         RTs = simfunc(p{:},ntrials,1);
      else
         RTs = simfunc(pars(s,:),ntrials,1);
      end
      
     %RTs(isnan(RTs) | RTs > ub) = inf;
      metadata(isim).subject = isim;
      metadata(isim).simmodel = model;
      metadata(isim).simpars = pars(s,:);
      metadata(isim).modelon = s;
      allRTs(:,isim) = RTs;
      
      subid = sprintf('%0*d',length(num2str(nsims)),isim);
      
      if saveflag
         save([savepath '/subject-' subid '_model-' model],'RTs');
      end
      
      isim = isim + 1;
      
   end
end

if saveflag
   save([savepath '/all-data.mat'],'allRTs');
   save([savepath '/metadata.mat'],'metadata');
end

% Reality check
p_mean = ranksum(nanmean(allRTs)',moments(:,1));
p_std = ranksum(nanstd(allRTs)',moments(:,2));
p_skew = ranksum(skewness(allRTs)',moments(:,3));

if saveflag
   save([savepath '/p_values'],'p_mean','p_std','p_skew');
end

% Plot histograms
figure;
isim = 1;
xub = 800;
for imod = 1:nmodels
   for ivsub = 1:nvsubs
      subplot(nmodels,nvsubs,isim);
      histogram(allRTs(:,isim),140:20:xub,'Normalization','pdf');
      xlim([0 xub]); ylim([0 0.016]);
      title(['Subject ' num2str(ivsub) ', Model ' model_reg{imod}]);
      isim = isim + 1;
   end
end

rangeRTs = [min(allRTs)' max(allRTs)'];
