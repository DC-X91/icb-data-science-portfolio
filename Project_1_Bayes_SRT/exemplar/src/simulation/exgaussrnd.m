function samps = exgaussrnd(mu,sigma,tau,varargin)
%EXGAUSSRND Returns random values drawn from the ExGaussian distribution
%   
%   r = EXGAUSSRND(mu,sigma,tau)
%   r = EXGAUSSRND(mu,sigma,tau,sz)
%   r = EXGAUSSRND(mu,sigma,tau,sz1, ..., szN)

exgaussargcheck(mu,sigma,tau);
sz = getsize(varargin{:});
samps = normrnd(mu,sigma,sz) + exprnd(tau,sz);
%samps = rand(sz);
%samps = exgaussinv(samps,mu,sigma,tau);

end
