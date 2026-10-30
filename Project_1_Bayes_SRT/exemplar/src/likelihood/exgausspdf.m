function f = exgausspdf(x,mu,sigma,tau)
%EXGAUSSPDF Returns values from the probability density function of the
%ExGaussian distribution
%   
%   f = EXGAUSSPDF(x,mu,sigma,tau)

%exgaussargcheck(mu,sigma,tau,x);
f = (1/tau)*normcdf((x - mu - (sigma^2/tau))/sigma).*exp(-(x - mu)/tau)*exp(sigma^2/(2*tau^2));

end
