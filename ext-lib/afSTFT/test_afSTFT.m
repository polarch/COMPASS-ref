addpath('./afSTFT');

% load an eigenmike recording converted to 3rd-order HOA signals (real SHs)
[x, fs] = audioread('./signals/musiikitalo_session1_1_eigen2HOA.wav');

% set parameters for the aliasing-suppression filterbank
pars.fs = fs;
% hop size, determines resolution - the number of bands will be hopsize+1
% (for uniform mode)
pars.hopSize = 128;
% length of buffer for real-time processing, or how many windows to 
% process at once and make available at each iteration for offline processing
pars.frameSize = 16*128;
% options {'uniform','hybrid','low_delay'} for 
% a) normal STFT bin resolution, 
% b) for hybrid with LF additional bands, 
% c) for hybrid with lower processing delay for real-time apps (but with 
% reduced alias suppression than 'hybrid', only for real-time apps)
pars.STFTmode = 'uniform';
switch pars.STFTmode
    case 'uniform'
        pars.centerfreq = (0:pars.hopSize)'*pars.fs/(2*pars.hopSize);
    case {'hybrid','low_delay'}
        switch pars.fs
            case 44100
                load('./data/afSTFTCenterFreq133.mat', 'afCenterFreq44100');
                pars.centerfreq = afCenterFreq44100;
            case 48000
                load('./data/afSTFTCenterFreq133.mat', 'afCenterFreq48000');
                pars.centerfreq = afCenterFreq48000;
        end
end

% fake linear processing doing nothing
nCH_in = size(x,2);
nBands = length(pars.centerfreq);
M_dec = repmat(eye(nCH_in), [1 1 nBands]);
pars.M_dec = M_dec; % filter matrix mapping inputs to outputs

% process input
y = afSTFT_template(x, pars);
% plot result
plot(x(1:1000,1)), hold on, plot(y(1:1000,1),'--r')

%% Example with applying an actual filter matrix with 3rd-order-to-binaural mixing filters
load('./resources/ambi2bin_akis.mat','ambi2bin_o3_fbcoeffs_uniform')
pars.M_dec = permute(ambi2bin_o3_fbcoeffs_uniform, [3 2 1]); % permute to (channels_out, channels_in, bands)

% process input
y_bin = afSTFT_template(x, pars);
soundsc(y_bin,fs)

%% Same example but with synthetic ideal 3rd-order signals - anechoic mix of 4 sources
%    -90     0 : speech    
%    135     0 : claps
%     30     0 : fountain
%      0    90 : piano

[x, fs] = audioread('./signals/4src_mix_anechoic_hoa3.wav');

% process input
y_bin = afSTFT_template(x, pars);
soundsc(y_bin,fs)