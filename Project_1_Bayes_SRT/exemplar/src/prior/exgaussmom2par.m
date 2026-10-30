function pars = exgaussmom2par(MEAN,VAR,SKEW)
%EXGAUSSMOM2PAR Summary of this function goes here
%   Detailed explanation goes here

%assert(SKEW < 2, 'Distribution SKEW must be less than 2!');
tau = (SKEW/2)^(1/3)*VAR^(1/2);
sigma = sqrt(VAR*(1 - (SKEW/2).^(2/3)));
mu = MEAN - tau;
pars = [mu,sigma,tau];
solnind = (imag(tau) == 0) & (imag(sigma) == 0) & (imag(mu) == 0);
pars = pars(solnind,:);
if isempty(pars); pars = nan(1,3); end

end

function y = F(x,m)
   y(1) = x(1) + x(3) - m(1);
   y(2) = x(2)^2 + x(3)^2 - m(2);
   y(3) = 2*(x(3)/x(2))^3*(1 + (x(3)/x(2))^2)^(-3/2) - m(3);
end
