function derivedpars = convert_exgauss(basepars,prior)

switch prior
   
   case 'moment1'
      mean_gen = basepars(1);
      var_gen = basepars(2)^2;
      skew_gen = basepars(3);
      derivedpars = exgaussmom2par(mean_gen,var_gen,skew_gen);

   case 'mixratio'
      mean_gen = basepars(1);
      p_gen = basepars(2);
      if basepars(3) == 0; basepars(3) = 10^-10; end
      var_gen = basepars(3)^2;
      if p_gen >= 1; p_gen = 1 - 10^-10; end
      if p_gen <= 0; p_gen = 10^-10; end
      
      tau = sqrt(p_gen*var_gen);
      eta = sqrt((1 - p_gen)*var_gen);
      mu = mean_gen - tau;
      sigma = eta;
      derivedpars = [mu sigma tau];
   
   case 'unipar'
      derivedpars = basepars;

   otherwise
      error('Prior type not recognised!');

end
