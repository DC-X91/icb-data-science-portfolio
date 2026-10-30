function [modelpars,loglike] = get_loglike_rocdd(ndims,hcube)
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
convertfunc = @convert_rocdd;
convertopts = {'momentprior'};

%===============================================================================
%% Get params from prior and hypercube values
%===============================================================================

modelpars = parsfromhcube(hcube,prior,'conversion',convertfunc, ...
                                      'convopts',convertopts);

%===============================================================================
%% Run log-likelihoood routine
%===============================================================================

loglike = loglike_srt_rocdd(RTs,modelpars);

end
