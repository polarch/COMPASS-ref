function [K, obfunc] = SORTE(lambda)
% SORTE Second ORder sTatistic of Eigenvalues estimator of source number
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
% Implementation based on the SORTE estimator as described in:
%   He, Z., Cichocki, A., Xie, S., & Choi, K. (2010). 
%   Detecting the number of clusters in n-way probabilistic clustering. 
%   IEEE Transactions on Pattern Analysis and Machine Intelligence, 32(11), 
%   pp.2006-2021.
%
% INPUT ARGUMENTS
%
% lambda    % vector of eigenvalues of the spatial covariance matrix of
%             ambisonic signals
%
% OUTPUT ARGUMENTS
%
% K         % the number of detected sources in the mixtures
% obfunc    % the values of the SORTE criteria for the different source
%             numbers - its minimum indicates theestimated source number
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if all(lambda==0)
    K = 0;
else
    N = length(lambda);
    Dlambda = lambda(1:end-1) - lambda(2:end);
    for k=1:N-1
        meanDlambda = 1/(N-k)*sum(Dlambda(k:N-1));
        sigma2(k) = 1/(N-k)*sum( (Dlambda(k:N-1) - meanDlambda).^2 );
    end
    for k=1:N-2
        if sigma2(k)>0, obfunc(k) = sigma2(k+1)/sigma2(k);
        elseif sigma2(k) == 0, obfunc(k) = Inf;
        end
    end
    obfunc(end) = Inf;
    [~,K] = min(obfunc);    
end

end
