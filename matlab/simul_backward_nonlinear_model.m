function DynareOutput = simul_backward_nonlinear_model(initial_conditions, sample_size, DynareOptions, DynareModel, DynareOutput, innovations)

% Simulates a stochastic non linear backward looking model with arbitrary precision (a deterministic solver is used).
%
% INPUTS
% - initial_conditions  [double]      n*1 vector, initial conditions for the endogenous variables.
% - sample_size         [integer]     scalar, number of periods for the simulation.
% - DynareOptions       [struct]      Dynare's options_ global structure.
% - DynareModel         [struct]      Dynare's M_ global structure.
% - DynareOutput        [struct]      Dynare's oo_ global structure.
% - innovations         [double]      T*q matrix, innovations to be used for the simulation.
%
% OUTPUTS
% - DynareOutput        [struct]      Dynare's oo_ global structure.
%
% REMARKS
% [1] The innovations used for the simulation are saved in DynareOutput.exo_simul, and the resulting paths for the endogenous
%     variables are saved in DynareOutput.endo_simul.
% [2] The last input argument is not mandatory. If absent we use random draws and rescale them with the informations provided
%     through the shocks block.
% [3] If the first input argument is empty, the endogenous variables are initialized with 0, or if available with the informations
%     provided thrtough the histval block.

% Copyright (C) 2012-2017 Dynare Team
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

if DynareModel.maximum_lead
    error('simul_backward_nonlinear_model:: The specified model is not backward looking!')
end

if nargin<6
    % Set the covariance matrix of the structural innovations.
    variances = diag(DynareModel.Sigma_e);
    number_of_shocks = length(DynareModel.Sigma_e);
    positive_var_indx = find(variances>0);
    effective_number_of_shocks = length(positive_var_indx);
    covariance_matrix = DynareModel.Sigma_e(positive_var_indx,positive_var_indx);
    covariance_matrix_upper_cholesky = chol(covariance_matrix);
    % Set seed to its default state.
    if DynareOptions.bnlms.set_dynare_seed_to_default
        set_dynare_seed('default');
    end
    % Simulate structural innovations.
    switch DynareOptions.bnlms.innovation_distribution
      case 'gaussian'
        DynareOutput.bnlms.shocks = randn(sample_size,effective_number_of_shocks)*covariance_matrix_upper_cholesky;
      otherwise
        error(['simul_backward_nonlinear_model:: ' DynareOption.bnlms.innovation_distribution ' distribution for the structural innovations is not (yet) implemented!'])
    end
    % Put the simulated innovations in DynareOutput.exo_simul.
    DynareOutput.exo_simul = zeros(sample_size,number_of_shocks);
    DynareOutput.exo_simul(:,positive_var_indx) = DynareOutput.bnlms.shocks;
    DynareOutput.exo_simul = [zeros(1,number_of_shocks); DynareOutput.exo_simul];
else
    DynareOutput.exo_simul = innovations;
end

% Get usefull vector of indices.
ny1 = nnz(DynareModel.lead_lag_incidence(1,:));
iy1 = find(DynareModel.lead_lag_incidence(1,:)>0);
idx = 1:DynareModel.endo_nbr;
jdx = idx+ny1;
hdx = 1:ny1;

% Get the name of the dynamic model routine.
model_dynamic = str2func([DynareModel.fname,'_dynamic']);
model_dynamic_s = str2func('dynamic_backward_model_for_simulation');

% initialization of vector y.
y = NaN(length(idx)+ny1,1);

% initialization of the returned simulations.
DynareOutput.endo_simul = NaN(DynareModel.endo_nbr,sample_size+1);
if isempty(initial_conditions)
    if isfield(DynareModel,'endo_histval')
        DynareOutput.endo_simul(:,1:DynareModel.maximum_lag) = DynareModel.endo_histval;
    else
        warning('simul_backward_nonlinear_model:: Initial condition is zero for all variables! If the model is nonlinear, the model simulation may fail with the default initialization')
        DynareOutput.endo_simul(:,1) = 0;
    end
else
    DynareOutput.endo_simul(:,1) = initial_conditions;
end
Y = DynareOutput.endo_simul;

% Simulations (call a Newton-like algorithm for each period).
for it = 2:sample_size+1
    ylag = Y(iy1,it-1);                   % Set lagged variables.
    y = Y(:,it-1);                        % A good guess for the initial conditions is the previous values for the endogenous variables.
    Y(:,it) = dynare_solve(model_dynamic_s, y, DynareOptions, model_dynamic, ylag, DynareOutput.exo_simul, DynareModel.params, DynareOutput.steady_state, it);
end

DynareOutput.endo_simul = Y;