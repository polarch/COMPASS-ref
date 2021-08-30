function [erb_idx, erb_freqs] = findERBpartitions(bandfreqs, maxFreqLim)
% FINDERBPARTITIONS Partition spectrum into ERB regions
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
% bandfeqs      % center frequencies of STFT bins or filterbank bands
% maxFreqLim    % upper frequency to stop partitioning - the rest of
%                 bins/bands are partitioned into a last region up to Nyquist
%
% OUTPUT ARGUMENTS
%
% erb_idx       % the bin indices of each ERB region
% erb_freqs     % the upper frequency of each ERB region
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (nargin<2), maxFreqLim = 20000; end
if (maxFreqLim>20000), maxFreqLim = 20000; end
band_centerfreq = (2^(1/3) + 1)/2;  % multiplier for band center frequency (from lower frequency limit)
erb_freqs = bandfreqs(1);
erb_idx = 1;

counter = 1;
while erb_freqs(counter) < maxFreqLim
    erb = 24.7 + 0.108 * erb_freqs(counter) * band_centerfreq;  % Compute the width of the band.
    erb_freqs(counter+1) = erb_freqs(counter) + erb;            % Upper frequency limit of band
    % find closest band frequency as upper partition limit
    [~, erb_idx(counter+1)] = min(abs(erb_freqs(counter+1) - bandfreqs));
    % force at least one bin bands (for low frequencies)
    if (erb_idx(counter+1) == erb_idx(counter)), erb_idx(counter+1) = erb_idx(counter+1)+1; end
    erb_freqs(counter+1) = bandfreqs(erb_idx(counter+1));          % quantize new band limit to bins
    
    counter = counter+1;
end
% last limit set at last band
erb_freqs(counter+1) = bandfreqs(end);
erb_idx(counter+1) = length(bandfreqs);

end
