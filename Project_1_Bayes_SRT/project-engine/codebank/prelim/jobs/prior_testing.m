% Preliminary definitions
rootpath = fullfile(projectdir(),'code','resources','bayes-inputs');

% Load prior to be tested
load(fullfile(rootpath,'wald-shift','priors','prior-wald-shift-unipar.mat'));

% Prepare conversion function
addpath(fullfile(rootpath,'wald-shift','reparam'));
convfunc = @convert_waldshift;
convopts = {'unipar'};

% Test parameters and outputs
N = 10^4;
h = rand(N,3);
pars = zeros(size(h));
moms = zeros(size(h));
momconv = @waldshiftpar2mom;

% Get parameters
for ii = 1:length(h)
   pars(ii,:) = parsfromhcube(h(ii,:)',prior,'conversion',convfunc,'convopts',convopts);
   moms(ii,:) = momconv(pars(ii,1),pars(ii,2),pars(ii,3));
end

badidx = isnan(pars(:,1));
nbad = sum(badidx);

figure; hold on;
histogram(moms(badidx,3));
histogram(moms(:,3));
