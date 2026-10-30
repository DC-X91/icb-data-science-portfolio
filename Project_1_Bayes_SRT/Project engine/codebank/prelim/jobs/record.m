%{
path = [projectdir() filesep 'data', ...
filesep 'sim-study', ...
filesep 'simdata-250', ...
filesep 'all-data.mat'];
load(path);
min(allRTs)
prior_setting
meanRT - minRT
prior_setting
alphadist = (param2(:,1)) ./ (param2(:,1) + param2(:,3));
histogram(alphadist)
histogram(alphadist,'Normalization','pdf')
f3 = betafit(alphadist);
f3 = betapdf(x,f3(1),f3(2));
plot(x,f3)
betapars = betapdf(x,f3(1),f3(2));
f3 = betafit(alphadist);
betapars = betafit(alphadist);
betapars(1) + (betapars(1) + betapars(2))
betapars(1) / (betapars(1) + betapars(2))
betapars(1)*betapars(2)/((betapars(1) + betapars(2))^2(betapars(1) + betapars(2) + 1))
betapars(1)*betapars(2)/((betapars(1) + betapars(2))^2*(betapars(1) + betapars(2) + 1))
sqrt(betapars(1)*betapars(2)/((betapars(1) + betapars(2))^2*(betapars(1) + betapars(2) + 1)))
prior_setting
min(allRTs)
scatter(param1(:,4),param2(:,4))
histogram(param1(:,4))
histogram(param1(:,5))
histogram(param1(:,2))
histogram(param1(:,1))
histogram(param1(:,3))
prior_setting
rddcheck
ccc
x2_intrasubject_comparisons
%}



%{
ccc;
fetch_param_estimates
param(:,:,1) = table2array(paramest.rocdd(:,2:end));
param(:,:,2) = table2array(paramest.rocddalt(:,2:end));
baseparams = zeros(size(param));
for ii = 1:2
for jj = 1:5
baseparams(:,1,:) = param(:,1,:) + param(:,3,:);
baseparams(:,2,:) = (param(:,1,:) - 40)./(baseparams(:,1,:) - 40);
baseparams(:,3,:) = param(:,2,:);
baseparams(:,4:5,:) = param(:,4:5,:);
baseparams(:,:,1)
baseparams(:,:,2)
histogram(baseparams(:,1,1))
histogram(baseparams(:,2,1))
histogram(baseparams(:,3,1))
histogram(baseparams(:,4,1))
histogram(baseparams(:,5,1))
histogram(baseparams(:,1,2))
histogram(baseparams(:,2,2))
histogram(baseparams(:,3,2))
histogram(baseparams(:,4,2))
histogram(baseparams(:,5,2))
histogram(baseparams(:,1,1),200:20:800)
histogram(baseparams(:,1,1),200:20:300)
min(baseparams(:,1,:))
min(baseparams(:,2,:))
min(baseparams(:,3,:))
histogram(baseparams(:,3,2))
histogram(baseparams(:,3,1))
r = expfit(baseparams(:,3,1))
r = expfit(baseparams(:,3,2))
shortG
format shortG
r = expfit(baseparams(:,3,2))
sum(baseparams(:,3,1) > 0.0025)
sum(baseparams(:,3,1) < 0.0025)
sum(baseparams(:,3,2) < 0.0025)
sum(baseparams(:,3,2) > 0.0025)
histogram([baseparams(:,3,1); baseparams(:,3,2)])
expfit([baseparams(:,3,1); baseparams(:,3,2)])
histogram([baseparams(:,3,1); baseparams(:,3,2)],'Normalization','pdf')
x = linspace(0,4*10^-3,1000);
f = exppdf(x,0.001113);
hold on; plot(x,f)
f = exppdf(x,0.0025);
hold on; plot(x,f)
histogram(baseparams(:,1,1))
close
histogram(baseparams(:,1,1))
histogram(baseparams(:,2,1))
histogram(baseparams(:,3,1))
histogram(baseparams(:,4,1))
expfit(baseparams(:,4,1))
expfit(baseparams(:,5,1))
histogram(baseparams(:,5,1))
histogram(baseparams(:,5,2))
histogram(baseparams(:,5,2),0:0.02:0.2)
clear
%}


fetch_param_estimates
derivpars(:,:,1) = table2array(paramest.waldshift(:,2:end));
derivpars(:,:,2) = table2array(paramest.exgaussian(:,2:end));
derivpars(:,:,3) = table2array(paramest.exwald(:,2:end));
basepars = zeros(size(derivpars));

basepars(:,1,:) = derivpars(:,1,:) + derivpars(:,3,:);

basepars(:,2,1) = (derivpars(:,1,1) - 40) ./ (basepars(:,1,1) - 40);
basepars(:,3,1) = sqrt(derivpars(:,2,1).^2 .* derivpars(:,1,1).^3);

derivpars(:,2,3) = derivpars(:,2,3).*derivpars(:,1,3).^(3/2);
basepars(:,3,2:3) = sqrt(derivpars(:,2,2:3).^2 + derivpars(:,3,2:3).^2);
basepars(:,2,2:3) = derivpars(:,3,2:3).^2 ./ basepars(:,3,2:3).^2;

%{
basepars(:,3,1) = 1./basepars(:,3,1);
basepars(:,3,1) = sqrt(basepars(:,3,1));
basepars(:,3,1) = basepars(:,3,1).^2;
basepars(:,3,1) = 1./basepars(:,3,1);
basepars(:,3,1) = 1./basepars(:,3,1);
basepars(:,3,1) = sqrt(basepars(:,3,1));
basepars(:,3,1) = sqrt((1./derivpars(:,2,1).^2) ./ derivpars(:,1,1).^3);
basepars(:,3,1) = sqrt((derivpars(:,2,1).^2) ./ derivpars(:,1,1).^3);
basepars(:,3,1) = sqrt((derivpars(:,2,1).^2) .* derivpars(:,1,1).^3);

basepars(:,2,2:3) = derivpars(:,3,2:3).^2 ./ basepars(:,3,2:3);
basepars(:,2,2:3) = derivpars(:,3,2:3).^2 ./ basepars(:,3,2:3).^2;
%}
