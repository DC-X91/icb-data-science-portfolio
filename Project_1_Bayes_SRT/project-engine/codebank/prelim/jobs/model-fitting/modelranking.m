clear
close
load mlefitresults.mat
mlefitresults = struct2table(mlefitresults);

bic = [mlefitresults.Results(:).bic]';
modelnames = mlefitresults.Model;

logZ = -bic/2;
logZ(isinf(logZ)) = -inf;

[modelrank.subject.bayesfactor,modelindex] = sort(logZ,'descend');
modelrank.subject.bayesfactor = ...
   modelrank.subject.bayesfactor - modelrank.subject.bayesfactor(1,:);
modelrank.subject.modelrank = modelnames(modelindex);


totallogZ = sum(logZ,2);
[modelrank.aggr.bayesfactor,modelindex] = sort(totallogZ,'descend');
modelrank.aggr.bayesfactor = ...
   modelrank.aggr.bayesfactor - modelrank.aggr.bayesfactor(1);
modelrank.aggr.modelrank = modelnames(modelindex);

save('modelrankresults.mat','modelrank');