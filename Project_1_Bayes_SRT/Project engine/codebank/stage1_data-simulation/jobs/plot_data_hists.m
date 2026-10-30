load([projectdir() '/data/sim-study/simdata-250/all-data.mat']);
load([projectdir() '/data/sim-study/simdata-250/metadata.mat']);

modelkey = {'rocdd','waldshift','exgauss','exwald'};
modelid = {'RDD','WSH','EXG','EXW'};
modeldict = containers.Map(modelkey,modelid);

nsubs = size(allRTs,2);
nmodels = length(unique({metadata.simmodel}));
nsubs = nsubs/nmodels;

reorder = [6:20 1:5];
allRTs = allRTs(:,reorder);
metadata = metadata(reorder);

figure;
xlabel('Response time /ms');
ylabel('Frequency');
isim = 1;
xub = 600;
bins = 100:25:xub;

for imod = 1:nmodels
   for ivsub = 1:nsubs
      
      subRTs = allRTs(:,isim);
      notshown = subRTs(subRTs > xub);
      
      ax = subplot(nmodels,nsubs,isim);
      h = histogram(allRTs(:,isim),bins, ...
                    'FaceColor',[72 83 104]/255,'FaceAlpha',1);
      
      
      xlim([100 xub]); ylim([0 100]);
      xticks(100:100:xub);
      xtickangle(45);
      grid on;
      
      if ~isempty(notshown)
         rec = cell(length(notshown),1);
         for l = 1:length(notshown)
            rec{l}= sprintf('%.3gms',notshown(l));
         end
         
         formatspec = ['Not shown:\n' repmat('%s\n',1,length(notshown))];
         txt = sprintf(formatspec,rec{:});
         text(0.8,0.5,txt,'Units','normalized','FontName','Utopia','HorizontalAlignment','Right');
      end
      
      title([modeldict(metadata(isim).simmodel) num2str(ivsub)], ...
            'Units','normalized','Position',[0.8, 0.8, 0],...
            'HorizontalAlignment','Right','FontName','Utopia');
      
      ax.FontSizeMode = 'Manual';
      ax.FontSize = 9;
      ax.FontName = 'Utopia';
      
      isim = isim + 1;
   end
end
