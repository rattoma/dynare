function DynareResults = initial_estimation_checks(xparam1,DynareDataset,Model,EstimatedParameters,DynareOptions,BayesInfo,DynareResults)
% function initial_estimation_checks(xparam1,gend,data,data_index,number_of_observations,no_more_missing_observations)
% Checks data (complex values, ML evaluation, initial values, BK conditions,..)
%
% INPUTS
%    xparam1:          vector of parameters to be estimated
%    gend:             scalar specifying the number of observations
%    data:             matrix of data
%
% OUTPUTS
%    DynareResults     structure of temporary results
%
% SPECIAL REQUIREMENTS
%    none

% Copyright (C) 2003-2011 Dynare Team
%
% This file is part of Dynare.
%
% Dynare is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <http://www.gnu.org/licenses/>.

if DynareDataset.info.nvobs>Model.exo_nbr+EstimatedParameters.nvn
    error(['initial_estimation_checks:: Estimation can''t take place because there are less shocks than observed variables!'])
end

% check if steady state solves static model (except if diffuse_filter == 1)
[DynareResults.steady_state] = ...
    evaluate_steady_state(DynareResults.steady_state,Model,DynareOptions,DynareResults,DynareOptions.diffuse_filter==0);

if DynareOptions.dsge_var
    [fval,cost_flag,info] = DsgeVarLikelihood(xparam1,DynareDataset,DynareOptions,Model,EstimatedParameters,BayesInfo,DynareResults);
else
    [fval,cost_flag,ys,trend_coeff,info] = DsgeLikelihood(xparam1,DynareDataset,DynareOptions,Model,EstimatedParameters,BayesInfo,DynareResults);
end

if info(1) > 0
    disp('Error in computing likelihood for initial parameter values')
    print_info(info, DynareOptions.noprint)
end

if any(abs(DynareResults.steady_state(BayesInfo.mfys))>1e-9) && (DynareOptions.prefilter==1)
    disp(['You are trying to estimate a model with a non zero steady state for the observed endogenous'])
    disp(['variables using demeaned data!'])
    error('You should change something in your mod file...')
end

disp(['Initial value of the log posterior (or likelihood): ' num2str(-fval)]);
