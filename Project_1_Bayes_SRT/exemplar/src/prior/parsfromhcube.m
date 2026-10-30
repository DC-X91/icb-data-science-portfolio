function priorsamp = parsfromhcube(hcube,modelprior,varargin)
%PARSFROMHCUBE Get model input parameters from a hypercube sample and prior
%   
%
%   Syntax
%   ======
%
%   pars = PARSFROMHCUBE(hcube,prior)
%   pars = PARSFROMHCUBE(hcube,prior,Name,Value)
%
%
%   Input arguments
%   ===============
%
%   hcube - hypercube values
%   > Data type: numeric vector or array
%   > An array containing 
%
%   prior - prior information structure
%   > Data type: struct
%   > See the documentation of #makeprior# for details of the expected form of
%     this input.
%
%   NAME-VALUE PAIR ARGUMENTS
%   Specify optional comma-separated pairs of Name,Value arguments. Name is the
%   argument name and Value is the corresponding value. Name must appear inside
%   quotes. You can specify several name and value pair arguments in any order
%   as Name1,Value1,...,NameN,ValueN.
%
%   'conversion' - function to derive model input parameters from prior
%                  parameters
%   > Data type: Function handle
%   >
%
%   'convopts'
%   > Data type: cell vector
%   > Any additional arguments to be passed to conversion function.
%   
%   
%   Output arguments
%   ================
%   
%   pars - model input parameters
%   > Data type: numeric vector or array
%   > For each sample from the hypercube passed via «hcube», «pars» contains the
%     corresponding values of the model input parameters. For a model with N
%     parameters, where S samples are taken, «pars» be returned as an NxS array.
%     (Is this last statement still true?)
%
%
%   Tips
%   ====
%   Edit on below: removed conversion options for efficiency; leave to use to
%   incorporate in gll function as appopriate. Also, now requires
%   prior.jointpars field to be 
%   > The conversion options are provided for convenience, but will not be as
%     efficient as simply passing the «priorsample» output to the appropriate
%     place.
%   > You can use the "conversion" option to deal priors that need
%     reparameterising, i.e., when the prior is defined over a parameter space
%     other than the model's parameter space (e.g., prior defined over
%     distribution moments when function relating moments to model parameters
%     exists).
%   > Sometimes, your likelihood function will be more convenient to write with
%     the parameters being passed in in some form other than a vector. For such
%     eventualities, this function allows you to return «likefuncpars» to store
%     the parameter data object for use in the likelihood function, and 
%     «priorsamp» to return a vector of values listing the parameters as a
%     vector in the prior parameter space, as required by MultiNest. Note that
%     you will have to use to the "conversion" option to convert the prior
%     sample point into the convenient format. If no conversion is specified,
%     «likefuncpar» is, naturally, set to be the same as «priorsamp».
%
% see also: MAKEPRIOR ~ GETCATEGORYIND ~ MAKE_PRIOR_REGISTER
%
%-------------------------------------------------------------------------------


[groups,ngroups] = parseargs(hcube,modelprior,varargin{:});

priorsamp = zeros(size(hcube));
for ii = 1:ngroups
   ind = groups(ii,:);
   priorspecs = modelprior.dists(ind);
   priorspecs = priorspecs(1);
   priortype = priorspecs.distribution;
   hyperpars = priorspecs.hyperpar_vals;
   context = priorspecs.context;
   if ~iscell(hyperpars); hyperpars = num2cell(hyperpars); end
   priorsamp(ind) = getpriorsample(priortype,hcube,hyperpars,context);
end

%{
if ~isempty(convfunc)
   if ~isempty(convopts)
      likefuncpars = convfunc(priorsamp,convopts{:});
   else
      likefuncpars = convfunc(priorsamp);
   end
else
   likefuncpars = priorsamp;
end
%}

end



%% Local functions
%%------------------------------------------------------------------------------


%% Input parser

function [groups,ngroups] = parseargs(hcube,prior)

   %% Ensure hypercube and prior are in accord
   hcube = hcube(:);
   %assert(validateprior(prior),'Prior not of correct form! See MAKEPRIOR.');
   assert(size(hcube,1) == size(prior.dists,1), ...
      'Hypercube and prior dimensionalities do not match!');
   assert(all(hcube(:) > 0) && all(hcube(:) < 1), ...
      'Hypercube values must lie between 0 and 1!');
   assert(ismatrix(hcube));
   npars = size(hcube,1);
   
   if isempty(prior.jointpars)
      groups = logical(eye(npars));
	else
      groups = prior.jointpars;
      assert(islogical(groups) && (size(groups,2) == npars) && ...
             isequal(sum(groups,1),ones(1,npars)));
   end
   ngroups = size(groups,1);
   %% Name-Value pair arguments
   %{
   convfunc = [];
   convopts = [];
   %groups = getcategoryind(prior.jointpars,[],npars);

   if mod(length(varargin),2) ~= 0
      error('Name-Value arguments must come in pairs');
   end

   ii = 1;
   while ii <= length(varargin)
      
      if ischar(varargin{ii})
         
         inpval = varargin{ii+1};
         
         switch lower(varargin{ii})
            
            case 'conversion'
               assert(isa(inpval,'function_handle'), ...
                  'Value for `conversion` option must be a function handle!');
               convfunc = inpval;
               
            case 'convopts'
               assert((iscell(inpval) && isvector(inpval)) || isempty(inpval), ...
                  'Value for `convopts` option must be a cell vector!');
               convopts = inpval;
               
            otherwise
               error(['Invalid optional input argument ',varargin{ii},'!']);
         end
      else
         error('Name must be a character vector!');
      end
      ii = ii + 2;
   end
  %}
end


%% Helper function to 
function p = getparam(h,parprior)
   
end
