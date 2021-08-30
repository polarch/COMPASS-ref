function delaysInFrames = getDecorrelationDelays(nCH, bandfreqs, fs, maxDelInFrames, hopSize)
% GETDECORRELATIONDELAYS Generate delays for FB/STFT-based decorrelation
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
% Implementation of band-delay decorrelation follows the publication:
%   Laitinen, M. V., Kuech, F., Disch, S., & Pulkki, V. (2011). 
%   Reproducing applause-type signals with directional audio coding. 
%   Journal of the Audio Engineering Society, 59(1/2), pp.29-43.
%
% INPUT ARGUMENTS
%
% nCH               % number of channels
% bandfeqs          % center frequencies of STFT bins or filterbank bands
% fs                % samplerate
% maxDelInFrames    % maximum allowed delay in number of STFT frames
% hopSize           % STFT hopsize
%
% OUTPUT ARGUMENTS
%
% delaysInFrames    % delays per band/bin, in STFT frames 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nBands = length(bandfreqs);
maxMilliseconds     = min(80,(maxDelInFrames-1)*hopSize/fs*1000);
delayRangeMax       = max(7, min(maxMilliseconds,50*1000./(bandfreqs+1e-20)));
delayRangeMin       = max(3, min(20,10*1000./(bandfreqs+1e-20)));
normalized_delays   = repmat((0:nCH-1)/nCH,[nBands 1])+rand(nBands,nCH)/(nCH);
for band=1:nBands
    normalized_delays(band,:) = normalized_delays(band,randperm(nCH));
end

delays          = normalized_delays .* repmat(delayRangeMax-delayRangeMin,[1 nCH]) + ...
                    repmat(delayRangeMin,[1 nCH]);
delaysInFrames  = round(delays'/1000*fs/hopSize);

end