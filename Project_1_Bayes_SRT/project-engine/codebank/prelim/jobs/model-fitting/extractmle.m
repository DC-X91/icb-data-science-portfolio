c = [];

for ii = 1:length(mlepars)
   m = mlepars{ii};
   f = fieldnames(m);
   n = length(f);
   a = cell(n,2);
   for jj = 1:n
      a{jj,1} = f{jj};
      a{jj,2} = m.(f{jj});
   end
   c = [c; a];
end

c = cell2table(c,'VariableNames',{'Model','Results'});