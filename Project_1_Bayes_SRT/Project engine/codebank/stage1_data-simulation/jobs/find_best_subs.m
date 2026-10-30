function [subs,nsubjects,moments] = find_best_subs(npoints,plotopt)
% NB Deprecated

   if ~exist('plotopt','var'); plotopt = false; end
   
   load(fullfile(projectdir,'./data/study-1/processed/bayes-inf-collated-3d.mat'),'RTs');
   nsubjects = size(RTs,3);
   RTs(RTs < 120 | RTs > 600) = nan;
   RTs = reshape(RTs,size(RTs,1)*size(RTs,2),nsubjects);

   meanRTs = nanmean(RTs)';
   stdRTs = nanstd(RTs)';
   skewRTs = skewness(RTs)';
   moments = [meanRTs stdRTs skewRTs];

   D = pdist(moments);
   D = squareform(D);

   S = nchoosek(1:nsubjects,npoints);
   dismS = zeros(size(S,1),1);

   for ir = 1:size(S,1)
      pts = S(ir,:);
      pairs = nchoosek(S(ir,:),2);

      com = mean(moments(unique(pairs),:));
      comdist = zeros(npoints,1);
      for ip = 1:npoints
         comdist(ip) = sum(sqrt((moments(pts(ip),:) - com).^2));
      end

      pwdist = zeros(size(pairs,1),1);
      for jj = 1:size(pairs,1)
         pwdist(jj) = 1/(1+D(pairs(jj,1),pairs(jj,2)));
      end

      dismS(ir) = sum(pwdist);
   end

   [~,ind] = min(dismS);
   subs = S(ind,:);

   if plotopt
      scatter3(meanRTs,stdRTs,skewRTs)
      hold on
      scatter3(meanRTs(subs),stdRTs(subs),skewRTs(subs),'filled')
   end
end
