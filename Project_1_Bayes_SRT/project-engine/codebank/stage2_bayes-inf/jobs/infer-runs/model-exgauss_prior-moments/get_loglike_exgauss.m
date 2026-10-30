function [modelpars,loglike] = get_loglike_exgauss(ndims,hcube)
%GET_LOGLIKE Summary of this function goes here
%   Detailed explanation goes here

hcube = hcube(:);
maxNumCompThreads(1);

%===============================================================================
%% Load data, prior, and auxiliary files; configure options
%===============================================================================

datapath = './';
load([datapath, 'prior.mat'],'prior');
load([datapath, 'data.mat'], 'RTs');
convertfunc = @convert_exgauss;
convertopts = {'momentprior'};

%===============================================================================
%% Get params from prior and hypercube values
%===============================================================================

modelpars = parsfromhcube(hcube,prior,'conversion',convertfunc, ...
                                      'convopts',convertopts);

%===============================================================================
%% Run log-likelihoood routine
%===============================================================================

loglike = loglike_srt_exgauss(RTs,modelpars);
if isequal(loglike,inf); error('Infinite log-likelihood value returned!'); end

end
