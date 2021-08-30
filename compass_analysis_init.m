function analysis_struct = compass_analysis_init(input_struct)
% COMPASS_ANALYSIS_INIT Initializes structure of params for COMPASS analysis 
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
% Copyright (C) 2021 - Archontis Politis & Leo McCormack
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
% input_struct.fs               % 44100 or 48000 for afSTFT
% input_struct.blockSize        % number of STFT frames for spatial parameter
%                                 estimation (default:2048)
% input_struct.SHorder          % ambisonic analysis order (scalar:broadband, 
%                                 or [133x1: individual order per afSTFT band)
% input_struct.AMBformat        % 0: N3D/ACN
%                                 1: ambiX (SN3D/ACN)
%                                 2: FuMa (up to 3rd order HOA)
%                                 (default: N3D/ACN)
% input_struct.DOAgrid          % spherical grid of K points for directional
%                                 analysis in Kx3 Cartesian format
%                                 (default: 900-point uniform Fliege set)
% input_struct.rotation_ypr     % Rotation of sound-field if needed, e.g.
%                                 to fix some some wrong orientation of the
%                                 ambisonic microphone. Rotation given in
%                                 Euler angles in degrees [yaw-pitch-roll]
%                                 default: [0 0 0]
%
% OUTPUT ARGUMENTS
%
% analysis_struct               % structure containing configuration parameters
%                                 and pre-initialised data required by
%                                 COMPASS_ANALYSIS.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('./compass-lib')
addpath('./ext-lib/afSTFT')

%%% ARGUMENT CHECK AND SETTING DEFAULT VALUES
if ~isfield(input_struct, 'fs') || isempty(input_struct.fs)
    error('input_struct.fs field not defined. Input sample rate should be defined!')
end 
if ~isfield(input_struct, 'SHorder') || isempty(input_struct.SHorder)
    error('input_struct.SHorder field not defined. Processing spherical harmonic order should be defined!')
end
if ~isfield(input_struct, 'AMBformat') || isempty(input_struct.AMBformat)
    warning('input_struct.AMBformat field not defined, setting it to 0 (N3D/ACN)')
    input_struct.AMBformat = 0;
end
if ~isfield(input_struct, 'DOAgrid') || isempty(input_struct.DOAgrid)
    warning('input_struct.DOAgrid field not defined, setting it to a 1296-point uniform t-design set')
    load('./resources/tdesign_N50.mat', 'dirs_xyz'); 
    input_struct.DOAgrid = dirs_xyz;
end
if ~isfield(input_struct, 'rotation_ypr') || isempty(input_struct.rotation_ypr)
    input_struct.rotation_ypr = [0 0 0];
end

% sample rate and afSTFT band frequencies
if input_struct.fs == 44100
    load('afSTFTcenterfreqs133.mat', 'afCenterFreq44100')
    bandFreq = afCenterFreq44100;
elseif input_struct.fs == 48000
    load('afSTFTcenterfreqs133.mat', 'afCenterFreq48000') 
    bandFreq = afCenterFreq48000;
else
    error('Input sample rate should be 44100 Hz or 48000 Hz')
end

% Copy to analysis structure
analysis_struct.fs = input_struct.fs;
analysis_struct.bandFreq = bandFreq; % filterbank centre frequencies
analysis_struct.nBands = length(bandFreq); % number of frequency bands 
analysis_struct.AMBformat = input_struct.AMBformat; % Ambisonic convention of input signals 
analysis_struct.DOAgrid = input_struct.DOAgrid; % scanning grid directions as Cartesian coordinates (unit vectors, xyz)

% Ambisonic analysis order
if length(input_struct.SHorder)==1, analysis_struct.SHorderPerBand = ones(analysis_struct.nBands,1)*input_struct.SHorder;
else,                               analysis_struct.SHorderPerBand = input_struct.SHorder; end
analysis_struct.maxSHorder = max(analysis_struct.SHorderPerBand);

% afSTFT hopsize and blocksize
% Note that the hopSize controls the temporal and frequency resolution of the afSTFT transform, whereas the blocksize
% refers to how many samples are used for each analysis block; i.e. the shorter the blocksize, the more frequently the  
% spatial parameters are updated
analysis_struct.hopSize = 128;    % hop length for STFT
analysis_struct.blockSize = 2048; % number of time-domain samples to process at a time
analysis_struct.nFramesInBlock = ceil(analysis_struct.blockSize/analysis_struct.hopSize); % number of down-sampled time indices per blocksize

% frequency smoothing band limits
analysis_struct.ERBmaxFreqLim = 12000; % maximum ERB frequency, above which, all bands are grouped into one
analysis_struct.ERBbinIdx = findERBpartitions(analysis_struct.bandFreq, analysis_struct.ERBmaxFreqLim); % indices defining ERB band grouping
analysis_struct.nERBands = length(analysis_struct.ERBbinIdx); % number of ERB bands

% Directional analysis grid
DOAgrid_aziElev = unitCart2sph(input_struct.DOAgrid)*180/pi; % scanning grid directions, in degrees
analysis_struct.SHgrid = sqrt(4*pi)*getRSH(analysis_struct.maxSHorder, DOAgrid_aziElev).'; % SH vectors for each scanning direction

% Rotation matrices
analysis_struct.rotation_ypr = input_struct.rotation_ypr;
rotation_Mtx = euler2rotationMatrix(input_struct.rotation_ypr(1)*pi/180, input_struct.rotation_ypr(2)*pi/180, input_struct.rotation_ypr(3)*pi/180, 'zyx');
analysis_struct.rotation_SHMtx = getSHrotMtx(rotation_Mtx, analysis_struct.maxSHorder, 'real');

end
