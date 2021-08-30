function [new_doa_xyz, nElimDOAs] = eliminateAdjacentDOAs(doa_xyz, angThreshold)
% ELIMINATEADJACENTDOAS Merge DOAs closer than threshold into a single one
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
% doa_xyz       % [K x 3] direction (unit) vectors of estimated DOAs
% angThreshold  % angular threshold in radians under which two DOAs closer
%                 than this are merged into a single mean DOA
%
% OUTPUT ARGUMENTS
%
% new_doa_xyz   % [L x 3] resulting DOAs after elimination of close ones,
%                 with L<=K
% nElimDOAs     % number of eliminated DOAs if any
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


nDOAs = size(doa_xyz,1);
distMtx = acos(min(doa_xyz*doa_xyz.',1));  
nElimDOAs = 0;
if nDOAs==2
        if distMtx(2,1)<=angThreshold
            new_doa_xyz = sum(doa_xyz);
            new_doa_xyz = new_doa_xyz./sqrt(sum(new_doa_xyz.^2));
            nElimDOAs = 1;
        else
            new_doa_xyz = doa_xyz;
        end
else
    distMtx = distMtx + pi*eye(nDOAs);
    while any(distMtx(:)<angThreshold)
        % find two closest DOAs
        [~, idxmin] = min(distMtx(:));
        [i,j] = ind2sub([nDOAs nDOAs],idxmin);
        % compute new clustered point from two closest
        avg_doa_xyz = sum(doa_xyz([i j],:));
        avg_doa_xyz = avg_doa_xyz./sqrt(sum(avg_doa_xyz.^2));
        % remove the two closest from the set of DOAs
        closestRemoved = setdiff((1:nDOAs),[i j]);
        doa_xyz = doa_xyz(closestRemoved,:);
        % insert new clustered point
        nDOAs = nDOAs-1;
        doa_xyz(nDOAs,:) = avg_doa_xyz;
        % compute new distance matrix and iterate
        distMtx = acos(min(doa_xyz*doa_xyz.',1));
        distMtx = distMtx + pi*eye(nDOAs);
        nElimDOAs = nElimDOAs+1;
    end     
    new_doa_xyz = doa_xyz;
end
