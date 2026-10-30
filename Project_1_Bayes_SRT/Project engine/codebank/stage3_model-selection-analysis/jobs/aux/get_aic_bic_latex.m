% Run x2 prior to this

datasets = fieldnames(critcomp);
n = length(datasets);

for ii = 1:length(datasets)
   m = critcomp.(datasets{ii}).rankByModel.weightAgainst;
   m = table2cell(m);
   for k = 1:numel(m)
      if isnumeric(m{k})
         if m{k} == 0
            new = sprintf('%.2f',m{k});
         else
            new = sprintf('-%.2f',m{k});
         end
         m{k} = new;
      end
   end
   matrix2latex(m,strcat('latexout/',datasets{ii},'.tex'));
end
   
