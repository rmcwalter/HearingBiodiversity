function AudSys_Setup(mfb_spacing)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AudSys_Setup configures the analysis system
%
% Inputs:   mfb_spacing     modulation filterbank spacing mode string
%                           ('halfoctave', 'octave', '2xoctave', etc.)
% Outpus:   saves all the analysis system parameters to
%           _system/AudSys_Setup_<mfb_spacing>_fs<fs>k.mat
%
% 'compression'     peripheral compression (per subband)
% 'fcc'             gammatone filter center frequencies
% 'fs'              sample frequency
% 'f0'              modulation filterbank lower frequency
% 'fs_d'            downsampled envelope sample frequency
% 'g'               gammatone filterbank (analysis)
% 'gd'              gammatone filterbank (synthesis dual)
% 'mfb'             modulation filterbank (analysis)
% 'mfbd'            modulation filterbank (synthesis dual)
% 'mfin'            modulation filterbank center frequencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% System config
fs   = 48e3;    % sample frequency
f0   = 0.5;     % modulation filterbank start frequency (Hz)
fs_d = 400;     % downsampled envelope sample frequency (mod filterbank upper cutoff)

betamul = 1.0183;  % gammatone filter bandwidth tuning parameter
M       = 1;       % peripheral filter spacing parameter (ERB channels per step)

% Generate gammatone filterbank for analysis and synthesis
fcc  = ERBrate_(50, fs/2, fs, M);                    % GT center frequencies
g    = gt_fir(fcc, fs, 5000, M, betamul, 0, 'ERB'); % GT analysis filters
gd   = fbrealdual(g, 5000);                          % GT synthesis dual filters

% Generate modulation filterbank
[mfb, mfin] = FIR_Mod_FB(fs_d, fs_d/f0, mfb_spacing, f0);
mfbd = fbrealdual(mfb, size(mfb{1}, 2));             % MFB synthesis dual

% Frequency-dependent peripheral compression (normal hearing)
f           = [1e3 2e3 4e3];
compression = [0.3 0.3 0.3];
compression = spline(f, compression, fcc);  % interpolate to match fcc length

% Save all auditory analysis system parameters
save(['_system/AudSys_Setup_' mfb_spacing '_fs' num2str(fs/1000, '%1.0f') 'k'], ...
     'compression', 'fcc', 'fs', 'f0', 'fs_d', 'g', 'gd', 'mfb', 'mfbd', 'mfin');
