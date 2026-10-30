path = [projectdir() filesep 'data', ...
                     filesep 'sim-study', ...
                     filesep 'simdata-250', ...
                     filesep 'all-data.mat'];
load(path);

meanRT = nanmean(allRTs);
minRT = min(allRTs);
alpha = (meanRT - minRT) ./ meanRT;

mu = mean(alpha);
var = (3*std(alpha)).^2;

coeff = (var + (mu - 1)*mu)/var;
R(1) = -mu*coeff;
R(2) = (mu - 1)*coeff;

x = linspace(0,1,1000);
r = betafit(alpha);
f = betapdf(x,r(1),r(2));
f2 = betapdf(x,R(1),R(2));

figure; hold on;
histogram(alpha,'Normalization','pdf');
plot(x,f,'LineWidth',2);
plot(x,f2,'LineWidth',2);
