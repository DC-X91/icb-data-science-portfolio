clear

load mlefitresults.mat

bounds = { ...
  [0 0 50]; ...    %bsd
  [0 0 0]; ...       %burr
  [0 0 0 50]; ...  %dagumshift
  [0 0 0]; ...       %exgauss
  [0 0 0]; ...       %exwald
  [0 0 50 0]; ...  %fss
  [0 0 50]; ...    %gammas
  [-inf 0 50]; ... %gev
  [0 0 50]; ...    %llogis
  [0 0 50]; ...    %nak
  [0 0 0 50 0]; ...    %ncf
  [0 0 50 0]; ...  %nct
  [0 0 50]; ...    %ric
  [0 -1 0 50; 2 1 inf inf]; ... %stable
  [0 0 50]; ...    %wald
  [0 0 50]; ...    $wbullshift
};

for ii = 1:length(bounds)
   b = bounds{ii};
   b = b';
   if size(b,2) == 1
      b = [b inf(size(b,1),1)];
   end
   bounds{ii} = b;
   parbounds(ii).Model = mlefitresults.Model(ii);
   parbounds(ii).Support = b;
end

save('parbounds','parbounds');

clear;