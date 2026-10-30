load mlefitresults.mat;
load modeldirs.mat;
path = {modeldirs.name};

priorstruct = prior_range_est(mlefitresults);

for ii = 1:length(path)
   prior = priorstruct(ii).prior;
   save(['../' path{ii} '/prior.mat'],'prior');
end