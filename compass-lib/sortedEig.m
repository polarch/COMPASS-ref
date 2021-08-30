function [V,D] = sortedEig(SCM)
% SORTEDEIG Sorted EVD for Hermitian matrices at decreasing eigenvalue order 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This file is part of the COMPASS reference implementation, as described
% in the publication
%
%   Archontis Politis, Sakari Tervo, and Ville Pulkki. 2018. 
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
% INPUT ARGUMENTS
%
% SCM   % [nCH x nCH] spatial covariance matrix
%
% OUTPUT ARGUMENTS
%
% V     % [nCH x nCH] matrix of eigenvectors
% D     % [nCH x nCH] diagonal matrix of eigenvalues
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[V,D] = eig(SCM);
d = real(diag(D));
[d_sorted, idx] = sort(d,'descend');
D = diag(d_sorted);
V = V(:,idx);

end