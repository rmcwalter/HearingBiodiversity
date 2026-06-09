function Meas_MeanStats_n_Save(poule, mean_stats, mfb_mode)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meas_MeanStats_n_Save  Measures auditory texture statistics for all wav
% files in _samples/ and saves their mean to _stats/mean.mat.
%
% Inputs:   poule       unused (legacy parallel-processing flag)
%           mean_stats  unused (legacy flag)
%           mfb_mode    modulation filterbank spacing string
%
% Output:   saves _stats/mean.mat with averaged statistics across all files:
%   Px  - subband envelope power
%   Mx  - envelope marginals [mean, coeff. of var., skewness, kurtosis]
%   Vx  - envelope variance
%   Cx  - envelope pairwise correlation
%   MPx - modulation power
%   MVx - modulation variance
%   MCx - modulation pairwise correlation
%   I   - subband index sorted by descending power
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dir_list = dir('_samples/*.wav');

% Load auditory system parameters
load(['_system/AudSys_Setup_' mfb_mode '.mat'])

for k = 1:length(dir_list)
    [x, fsx] = audioread(['_samples/' dir_list(k).name]);
    x = x(1:floor(length(x)/fsx)*fsx);
    x = resample(x, fs, fsx);

    x_sub    = ufilterbank(x, g, 1)';
    [dex_sub, exf_sub] = Subband_Envelopes(x_sub, fs, fs_d, compression, 'hilbert', fcc);
    dexm_sub = mfilterbank(dex_sub, mfb);

    [s(k).Px, s(k).I] = Envelope_Power(dex_sub);
    s(k).Mx  = Envelope_Marginals(dex_sub);
    s(k).Vx  = Envelope_Variance(dex_sub);
    s(k).Cx  = Envelope_Correlation(dex_sub);
    s(k).MPx = Modulation_Power(dexm_sub, dex_sub, fcc, mfin);
    s(k).MVx = Modulation_Variance(dexm_sub, dex_sub);
    s(k).MCx = Modulation_Correlation(dexm_sub);
end

% Average statistics across all wav files
Px  = zeros(size(s(1).Px));
Mx  = zeros(size(s(1).Mx));
Vx  = zeros(size(s(1).Vx));
Cx  = zeros(size(s(1).Cx));
MPx = zeros(size(s(1).MPx));
MVx = zeros(size(s(1).MVx));
MCx = zeros(size(s(1).MCx));
I   = zeros(size(s(1).I'));

for k = 1:length(s)
    Px  = Px  + s(k).Px  / length(s);
    Mx  = Mx  + s(k).Mx  / length(s);
    Vx  = Vx  + s(k).Vx  / length(s);
    Cx  = Cx  + s(k).Cx  / length(s);
    MPx = MPx + s(k).MPx / length(s);
    MVx = MVx + s(k).MVx / length(s);
    MCx = MCx + s(k).MCx / length(s);
    I   = I   + s(k).I'  / length(s);
end

save(['_stats/mean.mat'], 'Px', 'Mx', 'Vx', 'Cx', 'MPx', 'MVx', 'MCx', 'I');
