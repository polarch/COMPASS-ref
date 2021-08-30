function peaks_idx = sphPeakFind(pmap, grid_xyz, nPeaks)
% SPHPEAKFIND Peak finding on sherical data
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
% pmap      % [nGrid x 1] vector of real data on the spherical grid points
% grid_xyz  % [nGrid x 3] unit vectors of the grid point coordinates
% nPeaks    % the number of peaks to be found
%
% OUTPUT ARGUMENTS
%
% peaks_idx % indices of grid points corresponding to the peaks
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

kappa  = 50; % Von Mises-Fisher concentration parameter
P_minus_peak = pmap;
peaks_idx = zeros(nPeaks, 1);
for k = 1:nPeaks-1
    [~, peak_idx] = max(P_minus_peak);
    peaks_idx(k) = peak_idx;
    VM_mean = grid_xyz(peak_idx,:); % orientation of VM distribution
    VM_mask = kappa/(2*pi*exp(kappa)-exp(-kappa)) * exp(kappa*grid_xyz*VM_mean'); % VM distribution
    VM_mask = 1./(0.00001+VM_mask); % inverse VM distribution
    P_minus_peak = P_minus_peak.*VM_mask;
end
[~, peak_idx] = max(P_minus_peak);
peaks_idx(nPeaks) = peak_idx;

end
