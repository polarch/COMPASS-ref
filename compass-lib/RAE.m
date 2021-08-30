function [K, obfunc] = RAE(lambda)
% RAE Ratio of successive eigenvalues as an estimator of source number
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
% lambda    % vector of eigenvalues of the spatial covariance matrix of
%             ambisonic signals in descending order
%
% OUTPUT ARGUMENTS
%
% K         % the number of detected sources in the mixtures
% obfunc    % the successive values of the eigenvalue ratios as log 
%             differences - its maximum indicates the source number
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nCH = length(lambda);
if all(lambda==0)
    K = nCH;
else
    obfunc = log(lambda(1:end-1)) - log(lambda(2:end));
    [~,K] = max(obfunc);
end

end
