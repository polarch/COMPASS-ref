function synthesis_struct = compass_synthesis_init(analysis_struct, output_struct)
% COMPASS_SYNTHESIS_INIT Initializes structure of params for COMPASS synthesis
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
% analysis_struct                % structure with time-frequency transform,
%                                 spatial format parameters, and analysis
%                                 parameters, created by COMPASS_ANALYSIS_INIT.m
%
% output_struct.mode            % 0: loudspeaker rendering
%                                 1: headphone monitoring rendering
% output_struct.eq              % apply a global magnitude correction at all output channels
%                                 0: no EQ
%                                 scalar: just a gain value (same at all bands)
%                                 vector [nBands x 1]: EQ magnitude response
%                                 default: a provided empirical EQ computed from
%                                 binaural references
% output_struct.streamBalance   % control balance between source stream and
%                                 ambient/residual stream, with values {0~2}.
%                                 For example,
%                                 0:only diffuse, 1:equal, 2:only source stream
%                                 scalar: same balance at all bands
%                                 vector [nBands x 1]: balance per frequency band
%                                 default: 1
% output_struct.decodeBalance   % control balance between parametric and standard
%                                 ambisonic decoding, with values {0~1}.
%                                 1: only parametric COMPASS
%                                 0: only standard ambisonic decoding
%                                 scalar: same decoding balance at all bands
%                                 vector [nBands x 1]: decoding balance per frequency band
%                                 default: 1
% output_struct.diffusionLevel  % control the balance between the ambient
%                                 stream (0), and decorrelated ambient
%                                 stream(1) {0~1}.
%
%%% LOUDSPEAKER RENDERING
%
% output_struct.ls_dirs       % nLS x 2 matrix of loudspeaker angles in
%                               [azimuth elevation] format (degrees)
% output_struct.vbapNorm      % a factor that tunes the p-value coefficient of VBAP
%                               in a frequency-dependent way, to avoid bass-boosting
%                               at low frequencies
%                               0: for normal reverberant rooms (classic p=2 at all frequencies)
%                               1: for anechoic room playback
%                               {0~1}: in between, from normal to dry rooms
%                               default: 0
% output_struct.vbapSpread    % directional spread for VBAP gains in degrees (MDAP),
%                               0: for standard (minimum-spread) VBAP
%                               default: 10 degrees
%%% HEADPHONE MONITORING
%
% output_struct.hrirs         % lHRIRs x 2 x nHRTF matrix of HRIRs at nHRTF directions
% output_struct.hrtf_dirs     % nHRTF x 2 matrix of HRTF directions in
%                               [azimuth elevation] format (degrees)
% output_struct.hrtf_fs       % HRIR sample rate
%
%
% OUTPUT ARGUMENTS
%
% synthesis_struct                % structure with spatial modification and
%                                 rendering parameters

addpath('./compass-lib')

%%% ARGUMENT CHECK AND SETTING DEFAULT VALUES
if ~isfield(output_struct, 'mode') || isempty(output_struct.mode)
    error('output_struct.mode field not defined, set 0: loudspeaker rendering, 1: headphone monitoring')
end
if ~isfield(output_struct, 'eq') || isempty(output_struct.eq)
    warning('output_struct.eq field not defined, setting it to default EQ vector')
    load('./resources/EQ_example.mat','eq_oct1_hybrid')
    output_struct.eq = eq_oct1_hybrid; clear eq_oct1_hybrid
end
if ~isfield(output_struct, 'streamBalance') || isempty(output_struct.streamBalance)
    warning('output_struct.streamBalance field not defined, setting it to 1 (balanced)')
    output_struct.streamBalance = 1;
end
if ~isfield(output_struct, 'decodeBalance') || isempty(output_struct.decodeBalance)
    warning('output_struct.decodeBalance field not defined, setting it to 1 (full COMPASS)')
    output_struct.decodeBalance = 1;
end
if ~isfield(output_struct, 'diffusionLevel') || isempty(output_struct.diffusionLevel)
    warning('output_struct.diffusionLevel field not defined, setting it to 0.5 (50/50 non- and fully-decorrelated ambient stream)')
    output_struct.diffusionLevel = 0.5;
end

% LOUDSPEAKER RENDERING
if ~isfield(output_struct, 'ls_dirs') || isempty(output_struct.ls_dirs)
    error('output_struct.ls_dirs field not defined. Speaker layout should be specified!')
end
if ~isfield(output_struct, 'vbapNorm') || isempty(output_struct.vbapNorm)
    warning('output_struct.vbapNorm field not defined, setting it to 0 (p=2)')
    output_struct.vbapNorm = 0;
end
if ~isfield(output_struct, 'vbapSpread') || isempty(output_struct.vbapSpread)
    warning('output_struct.vbapSpread field not defined, setting it to 10 degrees')
    output_struct.vbapSpread = 10;
end

if output_struct.mode==1
    % HEADPHONE RENDERING
    if ~isfield(output_struct, 'hrirs') || isempty(output_struct.hrirs)
        warning('output_struct.hrirs field not defined, loading default HRIR set ()')
        
        load('./resources/HRIRs_example.mat','hrirs','hrtf_fs','hrtf_dirs_deg_aziElev')
        output_struct.hrirs = hrirs;
        output_struct.hrir_fs = hrtf_fs;
        output_struct.hrtf_dirs = hrtf_dirs_deg_aziElev;
    end
    if ~isfield(output_struct, 'hrtf_dirs') || isempty(output_struct.hrtf_dirs)
        warning('output_struct.hrtf_dirs field not defined, loading default HRIR set ()')
        
        load('./resources/HRIRs_example.mat','hrirs','hrtf_fs','hrtf_dirs_deg_aziElev')
        output_struct.hrirs = hrirs;
        output_struct.hrir_fs = hrtf_fs;
        output_struct.hrtf_dirs = hrtf_dirs_deg_aziElev;
    end
    if ~isfield(output_struct, 'hrtf_fs') || isempty(output_struct.hrtf_fs)
        warning('output_struct.hrtf_fs field not defined, loading default HRIR set ()')
        
        load('./resources/HRIRs_example.mat','hrirs','hrtf_fs','hrtf_dirs_deg_aziElev')
        output_struct.hrirs = hrirs;
        output_struct.hrir_fs = hrtf_fs;
        output_struct.hrtf_dirs = hrtf_dirs_deg_aziElev;
    end
end
synthesis_struct.mode = output_struct.mode;

%%% Copy parameters relavant to the synthesis from the analysis struct
synthesis_struct.hopSize = analysis_struct.hopSize;
synthesis_struct.blockSize = analysis_struct.blockSize;
synthesis_struct.bandFreq = analysis_struct.bandFreq;
synthesis_struct.nFramesInBlock = analysis_struct.nFramesInBlock;
synthesis_struct.nERBands = analysis_struct.nERBands;
synthesis_struct.ERBbinIdx = analysis_struct.ERBbinIdx;
synthesis_struct.DOAgrid = analysis_struct.DOAgrid;
synthesis_struct.SHgrid = analysis_struct.SHgrid;

%%% DECODER PRECOMPUTATIONS
if length(output_struct.streamBalance)==1, synthesis_struct.streamBalance = ones(analysis_struct.nBands,1)*output_struct.streamBalance; end
if length(output_struct.decodeBalance)==1, synthesis_struct.decodeBalance = ones(analysis_struct.nBands,1)*output_struct.decodeBalance; end
synthesis_struct.diffusionLevel = output_struct.diffusionLevel;
if output_struct.eq==0, synthesis_struct.eq = ones(analysis_struct.nBands,1);
elseif length(output_struct.eq)==1, synthesis_struct.eq = ones(analysis_struct.nBands,1)*output_struct.eq;
else, synthesis_struct.eq = output_struct.eq;
end
synthesis_struct.nullAngSepThresh = pi./(2*(1:analysis_struct.maxSHorder));

% diffuse renderer
if analysis_struct.maxSHorder<5
    [~, DIFFgrid_aziElev]   = getTdesign(2*(analysis_struct.maxSHorder+1)); % grid for diffuse rendering
else
    [~, DIFFgrid_aziElev]   = getTdesign(10); % cap at 60 diffuse plane waves
end
DIFFgrid_aziElev        = DIFFgrid_aziElev*180/pi;
synthesis_struct.SHgrid_diff = (4*pi)*getRSH(analysis_struct.maxSHorder, DIFFgrid_aziElev).';
nDiff = size(DIFFgrid_aziElev,1);
synthesis_struct.decorrelationDelays = getDecorrelationDelays(nDiff,analysis_struct.bandFreq,analysis_struct.fs,2*analysis_struct.nFramesInBlock,synthesis_struct.hopSize);

%%% LOUDSPEAKER RENDERING
% vbap gains for grid directions
DOAgrid_aziElev     = unitCart2sph(analysis_struct.DOAgrid)*180/pi;
ls_groups           = findLsTriplets(output_struct.ls_dirs);
layoutInvMtx        = invertLsMtx(output_struct.ls_dirs, ls_groups);
synthesis_struct.vbap_gtable = vbap(DOAgrid_aziElev, ls_groups, layoutInvMtx, output_struct.vbapSpread).';

% p-value for VBAP normalization
if output_struct.vbapNorm == 0
    synthesis_struct.vbap_pValue = 2*ones(analysis_struct.nBands,1);
else
    synthesis_struct.vbap_pValue = getPvalue(output_struct.vbapNorm,synthesis_struct.bandFreq);
end

% ambisonic decoding matrix
a2e = sqrt(4*pi/size(output_struct.ls_dirs,1))/(4*pi/size(output_struct.ls_dirs,1)); % amplitude->energy preserving normalisation term
synthesis_struct.ambiDec = a2e * ambiDecoder(output_struct.ls_dirs, 'epad', 0, analysis_struct.maxSHorder);

% diffuse renderer
synthesis_struct.vbap_gtable_diff = vbap(DIFFgrid_aziElev, ls_groups, layoutInvMtx).';

%%% HEADPHONE MONITORING
if output_struct.mode==1
    % find indices of the closest HRTFs to the loudspeaker setup
    hrtf_dirs_xyz = unitSph2cart(output_struct.hrtf_dirs*pi/180);
    ls_dirs_xyz = unitSph2cart(output_struct.ls_dirs*pi/180);
    hrtf_idx_closest = findClosestGridPoints(hrtf_dirs_xyz, ls_dirs_xyz);
    temp_hrirs = output_struct.hrirs(:,:,hrtf_idx_closest);
    % resample if HRIRs do not match the sample rate of the recordings
    if output_struct.hrtf_fs~=analysis_struct.fs
        warning('HRIR sample rate does not match the recording sample rate, resampling HRIRs')
        synthesis_struct.hrirs = resample(temp_hrirs, synthesis_struct.fs, output_struct.hrir_fs);
    else
        synthesis_struct.hrirs = temp_hrirs;
    end
end

end
