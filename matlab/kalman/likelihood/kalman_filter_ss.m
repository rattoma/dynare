function [LIK, likk, a] = kalman_filter_ss(Y,start,last,a,T,K,iF,dF,Z,pp,Zflag)
% Computes the likelihood of a stationnary state space model (steady state kalman filter).

%@info:
%! @deftypefn {Function File} {[@var{LIK},@var{likk},@var{a},@var{P} ] =} DsgeLikelihood (@var{Y}, @var{start}, @var{last}, @var{a}, @var{P}, @var{kalman_tol}, @var{riccati_tol},@var{presample},@var{T},@var{Q},@var{R},@var{H},@var{Z},@var{mm},@var{pp},@var{rr},@var{Zflag},@var{diffuse_periods})
%! @anchor{kalman_filter}
%! @sp 1
%! Computes the likelihood of a stationary state space model, given initial condition for the states (mean), the steady state kalman gain and the steady state inveverted covariance matrix of the prediction errors.
%! @sp 2
%! @strong{Inputs}
%! @sp 1
%! @table @ @var
%! @item Y
%! Matrix (@var{pp}*T) of doubles, data.
%! @item start
%! Integer scalar, first period.
%! @item last
%! Integer scalar, last period (@var{last}-@var{first} has to be inferior to T).
%! @item a
%! Vector (mm*1) of doubles, initial mean of the state vector.
%! @item T
%! Matrix (mm*mm) of doubles, transition matrix of the state equation.
%! @item K
%! Matrix (mm*@var{pp}) of doubles, steady state kalman gain.
%! @item iF
%! Matrix (@var{pp}*@var{pp}) of doubles, inverse of the steady state covariance matrix of the prediction errors.
%! @item dF
%! Double scalar, determinant of the steady state covariance matrix of teh prediction errors.
%! @item Z
%! Matrix (@var{pp}*mm) of doubles or vector of integers, matrix relating the states to the observed variables or vector of indices (depending on the value of @var{Zflag}).
%! @item pp
%! Integer scalar, number of observed variables.
%! @item Zflag
%! Integer scalar, equal to 0 if Z is a vector of indices targeting the obseved variables in the state vector, equal to 1 if Z is a @var{pp}*@var{mm} matrix.
%! @end table
%! @sp 2
%! @strong{Outputs}
%! @sp 1
%! @table @ @var
%! @item LIK
%! Double scalar, value of (minus) the likelihood.
%! @item likk
%! Column vector of doubles, values of the density of each observation.
%! @item a
%! Vector (mm*1) of doubles, mean of the state vector at the end of the (sub)sample.
%! @end table
%! @sp 2
%! @strong{This function is called by:}
%! @sp 1
%! @ref{kalman_filter}
%! @sp 2
%! @strong{This function calls:}
%! @sp 1
%! @end deftypefn
%@eod:

% Copyright (C) 2011 Dynare Team
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

% AUTHOR(S) stephane DOT adjemian AT univ DASH lemans DOT fr

% Get sample size.
smpl = last-start+1;

% Initialize some variables.
t    = start;              % Initialization of the time index.
likk = zeros(smpl,1);      % Initialization of the vector gathering the densities.
LIK  = Inf;                % Default value of the log likelihood.

while t <= last
    if Zflag
        v = Y(:,t)-Z*a;
    else
        v = Y(:,t)-a(Z);
    end
    a = T*(a+K*v);
    likk(t-start+1) = transpose(v)*iF*v;
    t = t+1;
end

% Adding constant determinant of F (prediction error covariance matrix)
likk = likk + log(dF);

% Add log-likelihhod constants and divide by two
likk = .5*(likk + pp*log(2*pi));

% Sum the observation's densities (minus the likelihood)
LIK = sum(likk);