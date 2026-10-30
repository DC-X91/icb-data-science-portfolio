function mlepars = srt_model_mlefit(custom_pdf,pinit,mleargs,llfunc,makeplot)

load('../../../bayes-inf/infer-run/src/inputs/runpars.mat','runpars');
runpars.minRT = 120;

pars = zeros(18,length(pinit));
maxloglike = zeros(18,1);
bic = zeros(18,1);
n = 10000;
t = linspace(1,runpars.maxRT,n)';
f = zeros(n,18);

if makeplot
   figure
end

fprintf(['\nFunction: ' func2str(custom_pdf) '\n--------------------\n\n']);

for ii = 1:18
   
   fprintf(['   Subject ' num2str(ii) ' processing... ']);

   load(['../../../../data/study-1/processed/bayes-inf/subject-' num2str(ii) '.mat'],'RTs');
   RTs = RTs(:); RTs = RTs(RTs > runpars.minRT & RTs < runpars.maxRT);
   phat = pinit;
   phold = zeros(size(phat)); 
   
   while ~isequal(phold,phat)
      phold = phat;
      phat = mle(RTs,'pdf',custom_pdf,'start',phat,mleargs{:});
   end
   
   maxloglike(ii) = llfunc(RTs,phat,runpars);
   bic(ii) = length(pinit)*log(length(RTs)) - 2*maxloglike(ii);
   
   pars(ii,:) = phat;
   p = num2cell(phat);
   f(:,ii) = custom_pdf(t,p{:});
   
   if makeplot
      subplot(3,6,ii); hold on;
      histogram(RTs,'Normalization','pdf')
      plot(t,f(:,ii),'LineWidth',2);
   end
   
   fprintf('Complete.\n')

end

mlepars.map = pars;
mlepars.loglike = maxloglike;
mlepars.bic = bic;
mlepars.min = min(pars);
mlepars.max = max(pars);
mlepars.t = t;
mlepars.f = f;

fprintf('\n');

end