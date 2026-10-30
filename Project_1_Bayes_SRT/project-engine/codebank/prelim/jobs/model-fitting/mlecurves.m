clear; close all;
makeplot = false;

include = { ...
            'bsd_shift', ...
            'burr', ...
            'dagum_shift', ...
            'exgauss', ...
            'exwald', ...
            'f_shiftscale', ...
            'gamma_shift', ...
            'gev', ...
            'llogis_shift', ...
            'nakagami_shift', ...
            'ncf_shiftscale', ...
            'nct_shiftscale', ...
            'rician_shift', ...
            'stable', ...
            'wald_shift', ...
            'weibull_shift', ...
          };
       
load mlefitresults.mat;

for ii = 1:length(include)
   
   switch include{ii}         
      
      case 'bsd_shift'
         
         % Birnbaum-Saunders distribution fit
         %----------------------------------------------------------------------
         
         addpath ../birnbaumsaunders_shift/
         pdfhdl = @(data,alpha,beta,shift) pdf_bsdshift(data,[alpha beta shift]);
         llfunc = @loglike_srt_bsdshift;
         modelidx = find(ismember({mlefitresults.Model},include{ii}));
         phat = mlefitresults(modelidx).Results.map;
         mlepars.bsd_shift = srt_model_mapcurve(phat,pdfhdl,llfunc,makeplot,include{ii});
         rmpath ../birnbaumsaunders_shift/
         
      
      case 'burr'
         
         % Burr Type XII distribution fit
         %----------------------------------------------------------------------
         
         addpath ../burr/
         pdfhdl = @(x,alpha,c,k) pdf('Burr',x,alpha,c,k);
         llfunc = @loglike_srt_burr;
         modelidx = find(ismember({mlefitresults.Model},include{ii}));
         phat = mlefitresults(modelidx).Results.map;
         mlepars.(include{ii}) = srt_model_mapcurve(phat,pdfhdl,llfunc,makeplot,include{ii});
         rmpath ../burr/
         
         
      case 'dagum_shift'
         
         % Shifted Dagum distribution fit
         %----------------------------------------------------------------------
         
         addpath ../dagum_shift/
         pdfhdl = @(data,a,b,p,shift) pdf_dagshift(data,[a b p shift]);
         llfunc = @loglike_srt_dagshift;
         modelidx = find(ismember({mlefitresults.Model},include{ii}));
         phat = mlefitresults(modelidx).Results.map;
         mlepars.(include{ii}) = srt_model_mapcurve(phat,pdfhdl,llfunc,makeplot,include{ii});
         rmpath ../dagum_shift/
      
      
      case 'exgauss'
         
         % Ex-Gaussian distribution fit
         %----------------------------------------------------------------------
         
         addpath ../exgaussian/
         pdfhdl = @(data,mu,sigma,tau) pdf_exgauss(data,[mu sigma tau]);
         llfunc = @loglike_srt_exgauss;
         modelidx = find(ismember({mlefitresults.Model},include{ii}));
         phat = mlefitresults(modelidx).Results.map;
         mlepars.(include{ii}) = srt_model_mapcurve(phat,pdfhdl,llfunc,makeplot,include{ii});
         rmpath ../exgaussian/
         
         
      case 'exwald'
         
         % Ex-Wald distribution fit
         %----------------------------------------------------------------------
         
         addpath ../exwald/
         pdfhdl = @(data,mu,sigma,tau) pdf_exwald(data,[mu sigma tau]);
         llfunc = @loglike_srt_exwald;
         modelidx = find(ismember({mlefitresults.Model},include{ii}));
         phat = mlefitresults(modelidx).Results.map;
         mlepars.(include{ii}) = srt_model_mapcurve(phat,pdfhdl,llfunc,makeplot,include{ii});
         rmpath ../exwald/
         
         
      case 'f_shiftscale'
         
         % Shifted and scaled F distribution fit
         %----------------------------------------------------------------------
         
         addpath ../f_shiftscale/
         pdfhdl = @(data,v1,v2,shift,scale) pdf_fshiftscale(data,[v1 v2 shift scale]);
         llfunc = @loglike_srt_fshiftscale;
         modelidx = find(ismember({mlefitresults.Model},include{ii}));
         phat = mlefitresults(modelidx).Results.map;
         mlepars.(include{ii}) = srt_model_mapcurve(phat,pdfhdl,llfunc,makeplot,include{ii});
         rmpath ../f_shiftscale/
         
         
      case 'gamma_shift'
         
         % Shifted Gamma distribution fit
         %----------------------------------------------------------------------
         
         addpath ../gamma_shift/
         pdfhdl = @(data,a,b,s) pdf_gamshift(data,[a b s]);
         llfunc = @loglike_srt_gamshift;
         modelidx = find(ismember({mlefitresults.Model},include{ii}));
         phat = mlefitresults(modelidx).Results.map;
         mlepars.(include{ii}) = srt_model_mapcurve(phat,pdfhdl,llfunc,makeplot,include{ii});
         rmpath ../gamma_shift/
      
         
      case 'gev'
         
         % Generalised Extreme Value distribution fit
         %----------------------------------------------------------------------
         
         addpath ../gev/
         pdfhdl = @gevpdf;
         llfunc = @loglike_srt_gev;
         modelidx = find(ismember({mlefitresults.Model},include{ii}));
         phat = mlefitresults(modelidx).Results.map;
         mlepars.(include{ii}) = srt_model_mapcurve(phat,pdfhdl,llfunc,makeplot,include{ii});
         rmpath ../gev/
         
         
      case 'llogis_shift'
         
         % Shifted log-logistic distribution fit
         %----------------------------------------------------------------------
         
         addpath ../loglogistic_shift/
         pdfhdl = @(data,alpha,beta,shift) ...
                  pdf_llogisticshift(data,[alpha beta shift]);
         llfunc = @loglike_srt_llogisticshift;
         modelidx = find(ismember({mlefitresults.Model},include{ii}));
         phat = mlefitresults(modelidx).Results.map;
         mlepars.(include{ii}) = srt_model_mapcurve(phat,pdfhdl,llfunc,makeplot,include{ii});
         rmpath ../loglogistic_shift/
         
         
      case 'nakagami_shift'
         
         % Shifted Nakagami distribution fit
         %----------------------------------------------------------------------
         
         addpath ../nakagami_shift/
         pdfhdl = @(data,mu,omega,shift) pdf_nakshift(data,[mu omega shift]);
         llfunc = @loglike_srt_nakshift;
         modelidx = find(ismember({mlefitresults.Model},include{ii}));
         phat = mlefitresults(modelidx).Results.map;
         mlepars.(include{ii}) = srt_model_mapcurve(phat,pdfhdl,llfunc,makeplot,include{ii});
         rmpath ../nakagami_shift/
      
      
      case 'ncf_shiftscale'
         
         % Shifted and scaled non-central F distribution fit
         %----------------------------------------------------------------------
         
         addpath ../noncentralf_shiftscale/
         pdfhdl = @(data,v1,v2,delta,shift,scale) ...
                  pdf_ncfshiftscale(data,[v1 v2 delta shift scale]);
         llfunc = @loglike_srt_ncfshiftscale;
         modelidx = find(ismember({mlefitresults.Model},include{ii}));
         phat = mlefitresults(modelidx).Results.map;
         mlepars.(include{ii}) = srt_model_mapcurve(phat,pdfhdl,llfunc,makeplot,include{ii});
         rmpath ../noncentralf_shiftscale/
       
         
      case 'nct_shiftscale'
         
         % Shifted and scaled non-central t-distribution fit
         %----------------------------------------------------------------------
         
         addpath ../noncentralt_shiftscale/
         pdfhdl = @(data,v,delta,shift,scale) ...
                  pdf_nctshiftscale(data,[v delta shift scale]);
         llfunc = @loglike_srt_nctshiftscale;
         modelidx = find(ismember({mlefitresults.Model},include{ii}));
         phat = mlefitresults(modelidx).Results.map;
         mlepars.(include{ii}) = srt_model_mapcurve(phat,pdfhdl,llfunc,makeplot,include{ii});
         rmpath ../noncentralt_shiftscale/
         
         
      case 'rician_shift'
         
         % Shifted Rician distribution fit
         %----------------------------------------------------------------------
         
         addpath ../rician_shift/
         pdfhdl = @(data,s,sigma,shift) pdf_ricshift(data,[s sigma shift]);
         llfunc = @loglike_srt_ricshift;
         modelidx = find(ismember({mlefitresults.Model},include{ii}));
         phat = mlefitresults(modelidx).Results.map;
         mlepars.(include{ii}) = srt_model_mapcurve(phat,pdfhdl,llfunc,makeplot,include{ii});
         rmpath ../rician_shift/
         
         
      case 'stable'
         
         % Stable distribution fit
         %----------------------------------------------------------------------
         
         addpath ../stable/
         pdfhdl = @(x,alpha,beta,gam,delta) pdf('Stable',x,alpha,beta,gam,delta);
         llfunc = @loglike_srt_stable;
         modelidx = find(ismember({mlefitresults.Model},include{ii}));
         phat = mlefitresults(modelidx).Results.map;
         mlepars.(include{ii}) = srt_model_mapcurve(phat,pdfhdl,llfunc,makeplot,include{ii});
         rmpath ../stable/
         
         
      case 'wald_shift'
         
         % Shifted Wald distribution fit
         %----------------------------------------------------------------------
         
         addpath ../wald_shift/
         pdfhdl = @(data,mu,sigma,tau) pdf_waldshift(data,[mu sigma tau]);
         llfunc = @loglike_srt_waldshift;
         modelidx = find(ismember({mlefitresults.Model},include{ii}));
         phat = mlefitresults(modelidx).Results.map;
         mlepars.(include{ii}) = srt_model_mapcurve(phat,pdfhdl,llfunc,makeplot,include{ii});
         rmpath ../wald_shift/
         
         
      case 'weibull_shift'
         
         % Shifted Weibull distribution fit
         %----------------------------------------------------------------------

         addpath ../weibull_shift/
         pdfhdl = @(data,mu,sigma,tau) pdf_wbullshift(data,[mu sigma tau]);
         llfunc = @loglike_srt_wbullshift;
         modelidx = find(ismember({mlefitresults.Model},include{ii}));
         phat = mlefitresults(modelidx).Results.map;
         mlepars.(include{ii}) = srt_model_mapcurve(phat,pdfhdl,llfunc,makeplot,include{ii});
         rmpath ../weibull_shift/
         
         
      otherwise
         warning(['Case "' include{ii} '" not recognised']);
   end
end