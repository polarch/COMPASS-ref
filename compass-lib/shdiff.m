function psi = shdiff(lambda)
% SHDIFF Diffueness COMEDIE estimator in the spherical harmonic domain
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This file is part of the COMPASS reference implementation, as described
% in the publication
%
%   Politis, Archontis, Sakari Tervo, and Ville Pulkki. 2018. 
%   "COMPASS: Coding and multidirectional parameterization of ambisonic 
%   sound scenes." 
%   IEEE Int. Conf. on Acoustics, Speech and Signal Processing (ICASSP).
%
% Author:   Archontis Politis (archontis.politis@gmail.com)
% Copyright (C) 2021 - Archontis Politis
% 
% The COMPASS reference code is free software; you can redistribute it 
% and/or modify it under the terms of the GNU General Public License as 
% published by the Free Software Foundation; either version 2 of the 
% License, or (at your option) any later version.
% 
% The COMPASS reference code is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General 
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along 
% with this program; if not, see <https://www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Implementation based on the COMEDIE estimator as described in:
%   Epain, N. and Jin, C.T., 2016. 
%   Spherical Harmonic Signal Covariance and Sound Field Diffuseness. 
%   IEEE/ACM Transactions on Audio, Speech, and Language Processing, 24(10), 
%   pp.1796-1807.
%
% INPUT ARGUMENTS
%
% lambda    % vector of eigenvalues of the spatial covariance matrix of
%             ambisonic signals
%
% OUTPUT ARGUMENTS
%
% psi       % diffuseness estimate, from 0 to 1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SHorder = sqrt(length(lambda))-1;
nSH = (SHorder+1)^2;
if all(lambda==0)
    psi = 1;
else
    g_0 = 2*(nSH-1);
    mean_ev = sum(lambda)/nSH;
    g = (1/mean_ev)*sum(abs(lambda-mean_ev));
    psi = 1-g/g_0;
end
end
