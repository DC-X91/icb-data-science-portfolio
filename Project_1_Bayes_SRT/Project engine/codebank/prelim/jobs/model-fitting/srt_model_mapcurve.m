function mlepars = srt_model_mapcurve(pars,pdffunc,llfunc,makeplot,modelname)

load('../../../code/bayes-inf/infer-run/src/inputs/runpars.mat','runpars');
runpars.minRT = 120;

maxloglike = zeros(18,1);
bic = zeros(18,1);
n = 10000;
t = linspace(1,runpars.maxRT,n)';
f = zeros(n,18);

if makeplot
   figure; sgtitle(modelname);
end

for ii = 1:18
   
   phat = pars(ii,:);
   load(['../../../data/study-1/processed/bayes-inf/subject-' num2str(ii) '.mat'],'RTs');
   RTs = RTs(:); RTs = RTs(RTs > runpars.minRT & RTs < runpars.maxRT);
   maxloglike(ii) = llfunc(RTs,phat,runpars);
   bic(ii) = length(phat)*log(length(RTs)) - 2*maxloglike(ii);
   
   p = num2cell(phat);
   f(:,ii) = pdffunc(t,p{:});
   
   if makeplot
      subplot(3,6,ii); hold on;
      histogram(RTs,'Normalization','pdf')
      plot(t,f(:,ii),'LineWidth',2);
   end

end

mlepars.map = pars;
mlepars.range = [min(pars)' max(pars)'];
mlepars.loglike = maxloglike;
mlepars.bic = bic;
mlepars.f = f;
mlepars.t = t;

end