function [u,v] = exgaussargcheck(mu,sigma,tau,x)
%EXGAUSSARGCHECK Validates parameter and abscissa values for the PDF and CDF of
%the ExGaussian distribution
%   
%   EXGAUSSARGCHECK(mu,sigma,tau[,x])
%   [u,v] = EXGAUSSARGCHECK(mu,sigma,tau[,x])

assert(isscalar(mu), ...
   'First (mean) parameter must be a scalar!');

assert(isscalar(sigma) & sigma > 0, ...
   'Second (scale) parameter must be a positive scalar!');

assert(isscalar(tau) & tau > 0, ...
   'Third (decay) parameter must be a positive scalar!');

if exist('x','var')
   assert(isreal(x), ...
      'ExGaussian PDF/CDF abscissa values must be real numbers!');
end

if nargout > 0
   u = (x - mu) / tau;
   v = sigma / tau;
end

end
