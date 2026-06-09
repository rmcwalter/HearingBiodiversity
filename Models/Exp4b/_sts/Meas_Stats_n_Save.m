function Meas_Stats_n_Save(poule, mean_stats, input, mfb_mode)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meas_Stats_n_Save  Measures auditory texture statistics for a single wav
% file and saves the result to _stats/<input>.mat.
%
% Inputs:   poule       unused (legacy parallel-processing flag)
%           mean_stats  unused (legacy mean-stats flag)
%           input       wav filename stem (without .wav) in _samples/
%           mfb_mode    modulation filterbank spacing string
%
% Output:   saves _stats/<input>.mat with fields:
%   Px  - subband envelope power
%   Mx  - envelope marginals [mean, coeff. of var., skewness, kurtosis]
%   Vx  - envelope variance
%   Cx  - envelope pairwise correlation
%   MPx - modulation power
%   MVx - modulation variance
%   MCx - modulation pairwise correlation
%   I   - subband index sorted by descending power
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load auditory system parameters
load(['_system/AudSys_Setup_' mfb_mode '.mat'])

[x, fsx] = audioread(['_samples/' input '.wav']);
x = x(1:floor(length(x)/fsx)*fsx);
x = resample(x, fs, fsx);

% Normalise to fixed RMS power
Px = 1/length(x) * sum(x.^2);
x  = x * sqrt(1e-4/Px);

% Filenames starting with '_' indicate a noise seed: whiten before analysis
if strcmp(input(1), '_')
    x = whitenoise(length(x)*10, x);
end

% Extract subband envelopes and modulations, then measure all statistics
x_sub    = ufilterbank(x, g, 1)';
[dex_sub, exf_sub] = Subband_Envelopes(x_sub, fs, fs_d, compression, 'hilbert', fcc);
dexm_sub = mfilterbank(dex_sub, mfb);
[Px, I]  = Envelope_Power(dex_sub);
Mx       = Envelope_Marginals(dex_sub);
Vx       = Envelope_Variance(dex_sub);
Cx       = Envelope_Correlation(dex_sub);
MPx      = Modulation_Power(dexm_sub, dex_sub, fcc, mfin);
MVx      = Modulation_Variance(dexm_sub, dex_sub);
MCx      = Modulation_Correlation(dexm_sub);
I        = I';
save(['_stats/' input], 'Px', 'Mx', 'Vx', 'Cx', 'MPx', 'MVx', 'MCx', 'I');
