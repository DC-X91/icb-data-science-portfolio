clear; close all;
makeplot = true;

include = { ...
            %'birnbaumsaunders_shift', ...
            %'burr', ...
            %'dagum_shift'
            %'exgauss', ...
            %'exwald', ...
            %'f_shiftscale', ...
            %'gamma_shift', ...
            %'gev', ...
            'loglogistic_shift', ...
            %'nakagami_shift', ...
            %'noncentralf_shiftscale', ...
            %'noncentralt_shiftscale', ...
            %'rician_shift', ...
            %'stable', ...
            %'wald_shift', ...
            %'weibull_shift', ...
          };

opts = statset;
opts.FunValCheck = 'off';
opts.MaxFunEvals=10^7;
opts.MaxIter=10^7;

for ii = 1:length(include)
   
   switch include{ii}         
      
      case 'birnbaumsaunders_shift'
         
         % Birnbaum-Saunders distribution fit
         %----------------------------------------------------------------------
         
         addpath ../birnbaumsaunders_shift/
         pdfhdl = @(data,alpha,beta,shift) pdf_bsdshift(data,[alpha beta shift]);
         llfunc = @loglike_srt_bsdshift;
         p0 = [50 0.7 110];
         parbound = [0 0 -inf];
         mleargs = {'LowerBound',parbound,'Options',opts};
         mlepars.bsd_shift = srt_model_mlefit(pdfhdl,p0,mleargs,llfunc,makeplot);
         rmpath ../birnbaumsaunders_shift/
         
      
      case 'burr'
         
         % Burr Type XII distribution fit
         %----------------------------------------------------------------------
         
         addpath ../burr/
         pdfhdl = @(x,alpha,c,k) pdf('Burr',x,alpha,c,k);
         llfunc = @loglike_srt_burr;
         p0 = [255 17 0.5];
         parbound = [0 0 0];
         mleargs = {'LowerBound',parbound,'Options',opts};
         mlepars.burr = srt_model_mlefit(pdfhdl,p0,mleargs,llfunc,makeplot);
         rmpath ../burr/
      
         
      case 'dagum_shift'
         
         % Shifted Dagum distribution fit
         %----------------------------------------------------------------------
         
         addpath ../dagum_shift/
         pdfhdl = @(data,a,b,p,shift) pdf_dagshift(data,[a b p shift]);
         llfunc = @loglike_srt_dagshift;
         p0 = [4.5,90,2,100]; %[3.32 52 3.36 138]; %[3.8174   80.0636    1.9459  150.5039];
         parbound = [0 0 0 -inf];
         mleargs = {'LowerBound',parbound,'Options',opts};
         mlepars.dagshift = srt_model_mlefit(pdfhdl,p0,mleargs,llfunc,makeplot);
         rmpath ../dagum_shift/
         
      
      case 'exgauss'
         
         % Ex-Gaussian distribution fit
         %----------------------------------------------------------------------
         
         addpath ../exgaussian/
         pdfhdl = @(data,mu,sigma,tau) pdf_exgauss(data,[mu sigma tau]);
         llfunc = @loglike_srt_exgauss;
         p0 = [200 20 40];
         parbound = [0 0 0];
         mleargs = {'LowerBound',parbound,'Options',opts};
         mlepars.exgauss = srt_model_mlefit(pdfhdl,p0,mleargs,llfunc,makeplot);
         rmpath ../exgaussian/
         
         
      case 'exwald'
         
         % Ex-Wald distribution fit
         %----------------------------------------------------------------------
         
         addpath ../exwald/
         pdfhdl = @(data,mu,sigma,tau) pdf_exwald(data,[mu sigma tau]);
         llfunc = @loglike_srt_exwald;
         p0 = [1/200 0.005 100];
         parbound = [0 0 0];
         mleargs = {'LowerBound',parbound,'Options',opts};
         mlepars.exwald = srt_model_mlefit(pdfhdl,p0,mleargs,llfunc,makeplot);
         rmpath ../exwald/
         
         
      case 'f_shiftscale'
         
         % Shifted and scaled F distribution fit
         %----------------------------------------------------------------------
         
         addpath ../f_shiftscale/
         pdfhdl = @(data,v1,v2,shift,scale) pdf_fshiftscale(data,[v1 v2 shift scale]);
         llfunc = @loglike_srt_fshiftscale;
         p0 = [10 10 120 75];
         parbound = [0 0 0 0];
         mleargs = {'LowerBound',parbound,'Options',opts};
         mlepars.f_shiftscale = srt_model_mlefit(pdfhdl,p0,mleargs,llfunc,makeplot);
         rmpath ../f_shiftscale/
         
         
      case 'gamma_shift'
         
         % Shifted Gamma distribution fit
         %----------------------------------------------------------------------
         
         addpath ../gamma_shift/
         pdfhdl = @(data,a,b,s) pdf_gamshift(data,[a b s]);
         llfunc = @loglike_srt_gamshift;
         p0 = [10 10 100];
         parbound = [0 0 -inf];
         mleargs = {'LowerBound',parbound,'Options',opts};
         mlepars.gamma_shift = srt_model_mlefit(pdfhdl,p0,mleargs,llfunc,makeplot);
         rmpath ../gamma_shift/
      
         
      case 'gev'
         
         % Generalised Extreme Value distribution fit
         %----------------------------------------------------------------------
         
         addpath ../gev/
         pdfhdl = @gevpdf;
         llfunc = @loglike_srt_gev;
         p0 = [-0.0132 32 257];
         parbound = [-inf 0 -inf];
         mleargs = {'LowerBound',parbound,'Options',opts};
         mlepars.gev = srt_model_mlefit(pdfhdl,p0,mleargs,llfunc,makeplot);
         rmpath ../gev/
         
         
      case 'loglogistic_shift'
         
         % Shifted log-logistic distribution fit
         %----------------------------------------------------------------------
         
         addpath ../loglogistic_shift/
         pdfhdl = @(data,alpha,beta,shift) ...
                  pdf_llogisticshift(data,[alpha beta shift]);
         llfunc = @loglike_srt_llogisticshift;
         p0 = [80 3.5 100];
         parbound = [0 0 -inf];
         mleargs = {'LowerBound',parbound,'Options',opts};
         mlepars.llogis_shift = srt_model_mlefit(pdfhdl,p0,mleargs,llfunc,makeplot);
         rmpath ../loglogistic_shift/
         
         
      case 'nakagami_shift'
         
         % Shifted Nakagami distribution fit
         %----------------------------------------------------------------------
         
         addpath ../nakagami_shift/
         pdfhdl = @(data,mu,omega,shift) pdf_nakshift(data,[mu omega shift]);
         llfunc = @loglike_srt_nakshift;
         p0 = [1.5 7000 120];
         parbound = [0 0 -inf];
         mleargs = {'LowerBound',parbound,'Options',opts};
         mlepars.nakagami_shift = srt_model_mlefit(pdfhdl,p0,mleargs,llfunc,makeplot);
         rmpath ../nakagami_shift/
      
      
      case 'noncentralf_shiftscale'
         
         % Shifted and scaled non-central F distribution fit
         %----------------------------------------------------------------------
         
         addpath ../noncentralf_shiftscale/
         pdfhdl = @(data,v1,v2,delta,shift,scale) ...
                  pdf_ncfshiftscale(data,[v1 v2 delta shift scale]);
         llfunc = @loglike_srt_ncfshiftscale;
         p0 = [10 10 2 120 50];
         parbound = [0 0 0 -inf 0];
         mleargs = {'LowerBound',parbound,'Options',opts};
         mlepars.ncf_shiftscale = srt_model_mlefit(pdfhdl,p0,mleargs,llfunc,makeplot);
         rmpath ../noncentralf_shiftscale/
       
         
      case 'noncentralt_shiftscale'
         
         % Shifted and scaled non-central t-distribution fit
         %----------------------------------------------------------------------
         
         addpath ../noncentralt_shiftscale/
         pdfhdl = @(data,v,delta,shift,scale) ...
                  pdf_nctshiftscale(data,[v delta shift scale]);
         llfunc = @loglike_srt_nctshiftscale;
         p0 = [5.7 2 195 27];
         parbound = [0 0 -inf 0];
         mleargs = {'LowerBound',parbound,'Options',opts};
         mlepars.nct_shiftscale = srt_model_mlefit(pdfhdl,p0,mleargs,llfunc,makeplot);
         rmpath ../noncentralt_shiftscale/
         
      case 'rician_shift'
         
         % Shifted Rician distribution fit
         %----------------------------------------------------------------------
         
         addpath ../rician_shift/
         pdfhdl = @(data,s,sigma,shift) pdf_ricshift(data,[s sigma shift]);
         llfunc = @loglike_srt_ricshift;
         p0 = [80 80 120];
         parbound = [0 0 -inf];
         mleargs = {'LowerBound',parbound,'Options',opts};
         mlepars.rician = srt_model_mlefit(pdfhdl,p0,mleargs,llfunc,makeplot);
         rmpath ../rician_shift/
         
         
      case 'stable'
         
         % Stable distribution fit
         %----------------------------------------------------------------------
         
         addpath ../stable/
         pdfhdl = @(x,alpha,beta,gam,delta) pdf('Stable',x,alpha,beta,gam,delta);
         llfunc = @loglike_srt_stable;
         p0 = [1.7 0.998 22.9 265];
         lbound = [0 -1 0 -inf];
         ubound = [2 1 inf inf];
         mleargs = {'LowerBound',lbound,'UpperBound',ubound,'Options',opts};
         mlepars.stable = srt_model_mlefit(pdfhdl,p0,mleargs,llfunc,makeplot);
         rmpath ../stable/
         
         
      case 'wald_shift'
         
         % Shifted Wald distribution fit
         %----------------------------------------------------------------------
         
         addpath ../wald_shift/
         pdfhdl = @(data,mu,sigma,tau) pdf_waldshift(data,[mu sigma tau]);
         llfunc = @loglike_srt_waldshift;
         p0 = [1/200 0.005 50];
         parbound = [0 0 -inf];
         mleargs = {'LowerBound',parbound,'Options',opts};
         mlepars.wald_shift = srt_model_mlefit(pdfhdl,p0,mleargs,llfunc,makeplot);
         rmpath ../wald_shift/
         
         
      case 'weibull_shift'
         
         % Shifted Weibull distribution fit
         %----------------------------------------------------------------------

         addpath ../weibull_shift/
         pdfhdl = @(data,mu,sigma,tau) pdf_wbullshift(data,[mu sigma tau]);
         llfunc = @loglike_srt_wbullshift;
         p0 = [100 2.5 120];
         parbound = [0 0 0];
         mleargs = {'LowerBound',parbound,'Options',opts};
         mlepars.weibull_shift = srt_model_mlefit(pdfhdl,p0,mleargs,llfunc,makeplot);
         rmpath ../weibull_shift/
         
         
      otherwise
         warning('Not recognised');
   end
end