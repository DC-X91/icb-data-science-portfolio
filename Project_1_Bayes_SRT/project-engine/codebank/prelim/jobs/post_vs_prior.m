% Preliminary definitions
rootpath = fullfile(projectdir(),'code','resources','bayes-inputs');

%% Fetch prior parameter distribution
% Load prior to be tested
load(fullfile(rootpath,'exwald','priors','prior-exwald-moments1.mat'));

% Prepare conversion function:
addpath(fullfile(rootpath,'exwald','reparam'));
hcube2parfunc = @convert_exwald;
hcube2paropts = {'moment1'};
momconv = @exwaldpar2mom;
fname = 'exwald';

%% Prep outputs
% Test parameters and outputs
npars = length(prior.dists);
nsamps = 10^4;
h = rand(nsamps,npars);
parsprior = zeros(size(h));
momsprior = zeros(size(h));

%%
% Get parameters and moments from prior
for ii = 1:length(h)
   parsprior(ii,:) = parsfromhcube(h(ii,:)',prior,'conversion',hcube2parfunc,'convopts',hcube2paropts);
   if all(~isnan(parsprior(ii,:)))
      momsprior(ii,:) = momconv(parsprior(ii,1),parsprior(ii,2),parsprior(ii,3));
   else
      momsprior(ii,:) = nan;
   end
end

%% Get maximum likelihood parameters and moments

addpath('../stage4_param-estim-analysis/');
run fetch_param_estimates.m

parsmle = table2array(paramest.(fname).mle(:,2:end));

momsmle = zeros(size(parsmle));
for ii = 1:size(parsmle,1)
   momsmle(ii,:) = momconv(parsmle(ii,1),parsmle(ii,2),parsmle(ii,3));
end

%% Plots

for ii = 1:npars
   figure; hold on;
   histogram(parsprior(:,ii),'Normalization','pdf');
   histogram(parsmle(:,ii),'Normalization','pdf');
   title(sprintf('Parameter no. %d',ii));
end

for ii = 1:3
   figure; hold on;
   histogram(momsprior(:,ii),'Normalization','pdf');
   histogram(momsmle(:,ii),'Normalization','pdf');
   title(sprintf('Moment no. %d',ii));
end
