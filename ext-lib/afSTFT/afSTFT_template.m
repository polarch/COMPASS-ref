function [outsig, pars] = afSTFT_template(insig, pars)


%%% Output parameters at screen
disp(char(10))
pars
disp(char(10))

%%% Array T-F Processing
fprintf('\nT-F processing: ')

% Parameters
fs = pars.fs;
hopsize = pars.hopSize; % hopsize of transform (with 50% internal overlap)
framesize = pars.frameSize; % buffer size (multiple of hopsize)
centerfreq = pars.centerfreq; % frequency centers for bins
STFTmode = pars.STFTmode; % 'uniform', 'hybrid', 'low_delay' 

M_dec = pars.M_dec; % example mixing matrix

% Initializations
nCH_in = size(insig,2);
nCH_out = size(M_dec,1); % The method defines this, here in the example set as inputs times a mixing matrix M_dec
inputLength = size(insig,1);
switch STFTmode % inherent delay of afSTFT
    case 'uniform'
        afSTFTdelay = 9*hopsize;
    case 'hybrid'
        afSTFTdelay = 12*hopsize;
end
nBands = length(centerfreq);
nFrames = framesize/hopsize;
outsig = zeros(afSTFTdelay+inputLength, nCH_out);
prevInputFrame = 0;

% STFT allocation
switch STFTmode
    case 'uniform' % no argument for uniform resolution
        afSTFT(hopsize, nCH_in, nCH_out);
    case {'hybrid','low_delay'}
        afSTFT(hopsize, nCH_in, nCH_out, STFTmode);
    otherwise
        error('Invalid afSTFT mode')
end
% Process loop
startIndex = 1;
frameIndex = 1;
progress = 1;

while startIndex+framesize < inputLength
    % progress bar
    if (startIndex+framesize)*10/inputLength > progress
        fprintf('*'); if mod(progress,10)==0, fprintf('\n'), end
        progress=progress+1;
    end
    
    % Gather time-domain buffer
    TDrange = startIndex + (0:framesize-1);
    
    % STFT transform
    temp = afSTFT(insig(TDrange,:)); % returns (nBands,nFrames,nChan)
    newInputFrame = permute(temp, [3 2 1]); % permute to (nChan,nFrames,nBands) for more rational processing
    
    % Output buffer
    outputFrame = zeros(nCH_out,nFrames,nBands);
    
    % Frequency band processing (ENTER YOUR CODE HERE)   
    for band = 1:nBands
        
        % e.g. compute frequency-band covariance matrix
        % Cxx_band = (1/nFrames)*newInputFrame(:,:,band)*newInputFrame(:,:,band)';
        
        outputFrame(:,:,band) = M_dec(:,:,band)*newInputFrame(:,:,band); % as an axample apply a mixing matrix of filters passed as filterbank coeffs
    end    
    
    % inverse transform
    tempOut = permute(outputFrame, [3 2 1]); % back to afSTFT's (nBands,nFrames,nChan)
    outsig(TDrange,:)= afSTFT(tempOut);
    
    % update
    prevInputFrame = newInputFrame;  % store previous frame in case it is needed for recursive averages etc...
    startIndex = startIndex + framesize;
    frameIndex = frameIndex+1;
end

outsig = outsig(afSTFTdelay+(1:inputLength),:); % remove processing delay
afSTFT(); % free allocated memory for afSTFT
end
