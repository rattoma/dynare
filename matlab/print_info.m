function print_info(info, noprint, DynareOptions)
% Prints error messages
%
% INPUTS
%   info              [double]     vector returned by resol.m
%   noprint           [integer]    equal to 0 if the error message has to be printed.
%   DynareOptions     [structure]  --> options_
% OUTPUTS
%    none
%
% SPECIAL REQUIREMENTS
%    none

% Copyright (C) 2005-2017 Dynare Team
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

if ~noprint
    switch info(1)
      case 1
        error(['The model doesn''t determine the current variables' ...
               ' uniquely'])
      case 2
        error(['The generalized Schur (QZ) decomposition failed. ' ...
               'For more information, see the documentation for Lapack function dgges: info=' ...
               int2str(info(2)) ', n=' int2str(info(3)) ...
               '. You can also run model_diagnostics to get more information on what may cause this problem.'])
      case 3
        error(['Blanchard Kahn conditions are not satisfied: no stable' ...
               ' equilibrium'])
      case 4
        error(['Blanchard Kahn conditions are not satisfied:' ...
               ' indeterminacy'])
      case 5
        error(['Blanchard Kahn conditions are not satisfied:' ...
               ' indeterminacy due to rank failure'])
      case 6
        error(['The Jacobian matrix evaluated at the steady state contains elements ' ...
               'that are not real or are infinite'])
      case 7
        error('One of the eigenvalues is close to 0/0 (the absolute value of numerator and denominator is smaller than %s!\n If you believe that the model has a unique solution you can try to reduce the value of qz_zero_threshold.',num2str(DynareOptions.qz_zero_threshold))
      case 8
        if size(info,2)>=2
            global M_;
            disp_string=deblank(M_.param_names(info(2),:));
            for ii=1:length(info)-2
                disp_string=[disp_string,', ',deblank(M_.param_names(info(2+ii),:))];
            end
            error(['The Jacobian contains NaNs because the following parameters are NaN: '...
                   disp_string])
        else
            error(['The Jacobian contains NaNs. For more information, use options_.debug.'])
        end
      case 9
        error(['k_order_pert was unable to compute the solution'])
      case 10
        error(['The Jacobian of the dynamic model contains Inf. For more information, use options_.debug.'])
      case 11
        error('The Hessian of the dynamic model used for second order solutions must not contain Inf')
      case 12
        error('The Hessian of the dynamic model used for second order solutions must not contain NaN')
      case 19
        error('The steadystate file did not compute the steady state')
      case 20
        if DynareOptions.linear
            error(['Impossible to find the steady state. Either the model' ...
                   ' doesn''t have a steady state or there are an infinity of steady states.' ...
                   ' Check whether your model is truly linear or whether there is a mistake in linearization.'])
        else
            error(['Impossible to find the steady state. Either the model' ...
                   ' doesn''t have a steady state, there are an infinity of steady states,' ...
                   ' or the guess values are too far from the solution'])
        end
      case 21
        error('The steady state is complex')
      case 22
        error('The steady state contains NaN or Inf')
      case 23
        error('Some updated params are complex')
      case 24
        error('Some updated params contain NaN or Inf')
      case 25
        error('The solution to the static equations is not a steady state of the dynamic model: verify that the equations tagged by [static] and [dynamic] are consistent')
      case 26
        error('The loglinearization of the model cannot be performed, because the steady state is not strictly positive.')
      case 30
        error('Variance can''t be computed')
      case 41
        error('one (many) parameter(s) do(es) not satisfy the lower bound');
      case 42
        error('one (many) parameter(s) do(es) not satisfy the upper bound');
      case 43
        error('Covariance matrix of structural shocks is not positive definite')
      case 44 %DsgeLikelihood_hh / dsge_likelihood
        error('The covariance matrix of the measurement errors is not positive definite.');
      case 45 %DsgeLikelihood_hh / dsge_likelihood
        error('Likelihood is not a number (NaN) or a complex number');
      case 46 %DsgeLikelihood_hh / dsge_likelihood
        error('Likelihood is a complex number');
      case 47 %DsgeLikelihood_hh / dsge_likelihood
        error('Prior density is not a number (NaN)');
      case 48 %DsgeLikelihood_hh / dsge_likelihood
        error('Prior density is a complex number');
      case 49
        error('The model violates one (many) endogenous prior restriction(s)')
      case 50
        error('Likelihood is Inf')
      case 51
        fprintf('\n The dsge_prior_weight is dsge_var=%5.4f, but must be at least %5.4f for the prior to be proper.\n',info(2),info(3));
        error('You are estimating a DSGE-VAR model, but the value of the dsge prior weight is too low!')
      case 52 %dsge_var_likelihood
        error('You are estimating a DSGE-VAR model, but the implied covariance matrix of the VAR''s innovations, based on artificial and actual sample is not positive definite!');
      case 53 %dsge_var_likelihood
        error('You are estimating a DSGE-VAR model, but the implied covariance matrix of the VAR''s innovations, based on the artificial sample, is not positive definite!');
      case 55
        error('Fast Kalman filter only works with stationary models [lik_init=1] or stationary observables for non-stationary models [lik_init=3]')
      case 61 %Discretionary policy
        error(['Discretionary policy: maximum number of iterations has been reached. Procedure failed. ']);
      case 62
        error(['Discretionary policy: some eigenvalues greater than options_.qz_criterium. Model potentially unstable.']);
      case 63
        error(['Discretionary policy: NaN elements are present in the solution. Procedure failed.']);
      case 71
        error(['Calibrated covariance of the structural errors implies correlation larger than  +-1.']);
      case 72
        error(['Calibrated covariance of the measurement errors implies correlation larger than  +-1.']);
        % Aim Code Conversions by convertAimCodeToInfo.m
      case 81
        error(['Ramsey: The solution to the static first order conditions for optimal policy could not be found. Either the model' ...
               ' doesn''t have a steady state, there are an infinity of steady states, ' ...
               ' or the guess values are too far from the solution']);
      case 82
        error(['Ramsey: The steady state computation resulted in NaN in the static first order conditions for optimal policy']);
      case 83
        error(['Ramsey: The steady state computation resulted in NaN in the auxiliary equations for optimal policy']);
      case 84
        error(['Ramsey: The steady state file computation for the Ramsey problem resulted in NaNs at the initial values of the instruments']);
      case 85
        error(['Ramsey: The steady state file does not solve the static first order conditions conditional on the instruments.']);
      case 86
        error(['Ramsey: The steady state file provides complex numbers conditional on the instruments.']);
      case 87
        error(['Ramsey: The maximum number of iterations has been reached. Try increasing maxit.']);
      case 102
        error('Aim: roots not correctly computed by real_schur');
      case 103
        error('Aim: too many explosive roots: no stable equilibrium');
      case 135
        error('Aim: too many explosive roots, and q(:,right) is singular');
      case 104
        error('Aim: too few explosive roots: indeterminacy');
      case 145
        error('Aim: too few explosive roots, and q(:,right) is singular');
      case 105
        error('Aim: q(:,right) is singular');
      case 161
        error('Aim: too many exact shiftrights');
      case 162
        error('Aim: too many numeric shiftrights');
      case 163
        error('Aim: A is NAN or INF.')
      case 164
        error('Aim: Problem in SPEIG.')
      otherwise
        error('This case shouldn''t happen. Contact the authors of Dynare')
    end
end
