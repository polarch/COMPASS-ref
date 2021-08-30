function [signal_out, ducker_struct] = extractTransients(signal_in, alpha, beta, ducker_struct)
% EXTRACTTRANSIENTS Filterbank/STFT-based transient extractor
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
% Implementation of transient extractor follows the publication:
%   Vilkamo, J., & Pulkki, V. (2015). 
%   Adaptive optimization of interchannel coherence with stereo and 
%   surround audio content. 
%   Journal of the Audio Engineering Society, 62(12), pp.861-869.
%
% INPUT ARGUMENTS
%
% signal_in     % [nCH x nFrames x nBands] multichannel input signal in
%                 STFT/FB domain
% alpha         % recursive smoothing parameters of the detector based
%                 on the aforementioned publication
% beta          % recursive smoothing parameters of the detector based
%                 on the aforementioned publication
%
% OUTPUT ARGUMENTS
%
% signal_out    % output signal without transients in STFT/FB domain
% ducker_struct % struct to store past extractor values, between successive
%                 input STFT blocks
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nCH = size(signal_in,1);
nFrames = size(signal_in,2);
nBands = size(signal_in,3);

signal_out = zeros(nCH, nFrames, nBands);

for frame = 1:nFrames
    detectorEne = abs(signal_in(:,frame,:)).^2;
    ducker_struct.transientDetector1 = ducker_struct.transientDetector1*alpha;
    selectorDetect = (ducker_struct.transientDetector1<detectorEne);
    ducker_struct.transientDetector1(selectorDetect) = detectorEne(selectorDetect);
    ducker_struct.transientDetector2 = ducker_struct.transientDetector2.*beta + (1-beta).*ducker_struct.transientDetector1;
    selectorDetect = (ducker_struct.transientDetector2>ducker_struct.transientDetector1);
    ducker_struct.transientDetector2(selectorDetect) = ducker_struct.transientDetector1(selectorDetect);
    transientEq = min(1,4*ducker_struct.transientDetector2./(1e-20+ducker_struct.transientDetector1));
    signal_out(:,frame,:) = signal_in(:,frame,:).*transientEq;
end

end