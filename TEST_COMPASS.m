close all, clear all, dbstop if error %#ok

%% EXAMPLE1: Synthetic recording - 4 sources - band - anechoic/dry

% analysis/synthesis order 1-3
for SHorder=1:3
    
    % Configure analysis
    input_struct.fs         = 48000;
    input_struct.SHorder    = SHorder;
    input_struct.AMBformat  = 0; % 0:N3d, 1:SN3D, 2: FuMa   
    analysis_struct = compass_analysis_init(input_struct);
    
    % Load input recording
    nSH = (input_struct.SHorder+1)^2;
    ambisig = audioread('./resources/01_bandDry_synth_hoa3_n3d.wav');
    ambisig = ambisig(:, 1:nSH);
    
    % Apply analysis
    [compass_signals, compass_parameters] = compass_analysis(ambisig, analysis_struct);
    
    % Configure synthesis
    load('./resources/Lspkr_example.mat', 'ls_dirs_deg_aziElev')
    output_struct.ls_dirs = ls_dirs_deg_aziElev;
    output_struct.mode = 1; % 0: loudspeaker rendering, 1: headphone monitoring of loudspeaker rendering
%    output_struct.eq = 1;
    output_struct.streamBalance = 1;
    output_struct.decodeBalance = 1;
    output_struct.diffusionLevel = 0.5;
    output_struct.vbapNorm = 0;
    output_struct.vbapSpread = 15;
    if output_struct.mode
        sofa_struct = loadSofaFile('./resources/ownsurround2016_short_48k.sofa');
        output_struct.hrirs = sofa_struct.IR;
        output_struct.hrtf_fs = sofa_struct.IR_fs;
        output_struct.hrtf_dirs = sofa_struct.SourcePosition(1:2,:).';
    end
    synthesis_struct = compass_synthesis_init(analysis_struct, output_struct);
    
    % Apply synthesis
    [output_signals, synthesis_struct] = compass_synthesis(compass_signals, synthesis_struct, compass_parameters);
    if output_struct.mode==0
        output_signals = 0.5*output_signals/max(max(abs(output_signals)));
        audiowrite(['bandDry_o' num2str(SHorder) '_ls.wav'], output_signals, input_struct.fs);
    elseif output_struct.mode==1
        output_signals = 0.5*output_signals/max(max(abs(output_signals)));
        audiowrite(['bandDry_o' num2str(SHorder) '_hp.wav'], output_signals, input_struct.fs);
    end
       
end

%% EXAMPLE2: Eigenmike order-3 recording - orchestra - concert hall

% analysis/synthesis order 1-3
for SHorder=1:3
    
    % Configure analysis
    input_struct.fs         = 48000;
    input_struct.SHorder    = SHorder;
    input_struct.AMBformat  = 0; % 0:N3d, 1:SN3D, 2: FuMa
    input_struct.rotation_ypr = [80 0 0];     % microphone is mistakenly rotated towards the right of the stage, align here
    analysis_struct = compass_analysis_init(input_struct);
    
    % Load input recording
    nSH = (input_struct.SHorder+1)^2;
    ambisig = audioread('./resources/02_orchestra_em32_hoa3_n3d.wav');
    ambisig = ambisig(:, 1:nSH);
    
    % Apply analysis
    [compass_signals, compass_parameters] = compass_analysis(ambisig, analysis_struct);
    
    % Configure synthesis
    load('./resources/Lspkr_example.mat', 'ls_dirs_deg_aziElev')
    output_struct.ls_dirs = ls_dirs_deg_aziElev;
    output_struct.mode = 1; % 0: loudspeaker rendering, 1: headphone monitoring of loudspeaker rendering
%    output_struct.eq = 1;
    output_struct.streamBalance = 1;
    output_struct.decodeBalance = 1;
    output_struct.diffusionLevel = 0.5;
    output_struct.vbapNorm = 0;
    output_struct.vbapSpread = 15;
    if output_struct.mode
        sofa_struct = loadSofaFile('./resources/ownsurround2016_short_48k.sofa');
        output_struct.hrirs = sofa_struct.IR;
        output_struct.hrtf_fs = sofa_struct.IR_fs;
        output_struct.hrtf_dirs = sofa_struct.SourcePosition(1:2,:).';
    end
    synthesis_struct = compass_synthesis_init(analysis_struct, output_struct);
    
    % Apply synthesis
    [output_signals, synthesis_struct] = compass_synthesis(compass_signals, synthesis_struct, compass_parameters);
    if output_struct.mode==0
        output_signals = 0.5*output_signals/max(max(abs(output_signals)));
        audiowrite(['orchestra_o' num2str(SHorder) '_ls.wav'], output_signals, input_struct.fs);
    elseif output_struct.mode==1
        output_signals = 0.5*output_signals/max(max(abs(output_signals)));
        audiowrite(['orchestra_o' num2str(SHorder) '_hp.wav'], output_signals, input_struct.fs);
    end
       
end

%% EXAMPLE3: Soundfield ST350 order-1 recording - choir - cathedral

% analysis/synthesis order 1
SHorder=1;
    
    % Configure analysis
    input_struct.fs         = 48000;
    input_struct.SHorder    = SHorder;
    input_struct.AMBformat  = 2; % 0:N3d, 1:SN3D, 2: FuMa  
    input_struct.rotation_ypr = [-30 0 0];    
    analysis_struct = compass_analysis_init(input_struct);
    
    % Load input recording
    nSH = (input_struct.SHorder+1)^2;
    ambisig = audioread('./resources/03_choir_st350_foa_fuma.wav');
    ambisig = ambisig(:, 1:nSH);
    
    % Apply analysis
    [compass_signals, compass_parameters] = compass_analysis(ambisig, analysis_struct);
    
    % Configure synthesis
    load('./resources/Lspkr_example.mat', 'ls_dirs_deg_aziElev')
    output_struct.ls_dirs = ls_dirs_deg_aziElev;
    output_struct.mode = 1; % 0: loudspeaker rendering, 1: headphone monitoring of loudspeaker rendering
%    output_struct.eq = 1;
    output_struct.streamBalance = 1;
    output_struct.decodeBalance = 1;
    output_struct.diffusionLevel = 0.5;
    output_struct.vbapNorm = 0;
    output_struct.vbapSpread = 30;
    if output_struct.mode
        sofa_struct = loadSofaFile('./resources/ownsurround2016_short_48k.sofa');
        output_struct.hrirs = sofa_struct.IR;
        output_struct.hrtf_fs = sofa_struct.IR_fs;
        output_struct.hrtf_dirs = sofa_struct.SourcePosition(1:2,:).';
    end
    synthesis_struct = compass_synthesis_init(analysis_struct, output_struct);
    
    % Apply synthesis
    [output_signals, synthesis_struct] = compass_synthesis(compass_signals, synthesis_struct, compass_parameters);
    if output_struct.mode==0
        output_signals = 0.5*output_signals/max(max(abs(output_signals)));
        audiowrite(['choir_o' num2str(SHorder) '_ls.wav'], output_signals, input_struct.fs);
    elseif output_struct.mode==1
        output_signals = 0.5*output_signals/max(max(abs(output_signals)));
        audiowrite(['choir_o' num2str(SHorder) '_hp.wav'], output_signals, input_struct.fs);
    end
