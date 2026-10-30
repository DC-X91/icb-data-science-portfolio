function moments = exgausspar2mom(mu,sigma,tau)
%EXGAUSSPAR2MOM Returns values of the moments of the ExGaussian distribution
%given the parameters, using the {Gauss mean, Gauss std, Exp. decay}
%parameterisation.
%   
%   moments = EXGAUSSPAR2MOM(mu,sigma,tau)

exgaussargcheck(mu,sigma,tau);
MEAN = mu + tau;
VAR = sigma^2 + tau^2;
SKEW = 2*(tau/sigma)^3*(1 + (tau/sigma)^2)^(-3/2);
moments = [MEAN,VAR,SKEW];

end
