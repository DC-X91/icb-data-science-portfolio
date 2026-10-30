function p = prior_range_est(mleresults)
%PRIOR_RANGE_EST Summary of this function goes here
%   Detailed explanation goes here

nmodels = height(mleresults);
p = struct('model',[],'prior',[],'mlerange',[]);
load('parbounds.mat','parbounds');

for ii = 1:nmodels
   model = mleresults.Model{ii};
   mlebound = mleresults.Results(ii).range;
   r = range(mlebound,2);
   prior = [mlebound(:,1)-0.5*r mlebound(:,2)+0.5*r];
   
   b = parbounds(ii).Support;
   prior(prior(:,1) < b(:,1),1) = b(prior(:,1) < b(:,1),1);
   prior(prior(:,2) > b(:,2),2) = b(prior(:,2) > b(:,2),2);
   
   p(ii).model = model;
   p(ii).prior = prior;
   p(ii).mlerange = mlebound;
end

end

