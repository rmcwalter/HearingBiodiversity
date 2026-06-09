function X = Meas_SynthStats(dex_sub, dexm_sub, mfb_mode)
% Meas_SynthStats  Measures all auditory texture statistics for a sound.
%
% Inputs:   dex_sub     downsampled subband envelopes (channels x time)
%           dexm_sub    subband modulations cell array {channel}(time x mod_chan)
%           mfb_mode    modulation filterbank spacing string (e.g. 'halfoctave')
%
% Output:   X           struct with fields:
%             Px  - subband envelope power
%             Mx  - envelope marginals [mean, coeff. of var., skewness, kurtosis]
%             Vx  - envelope variance
%             Cx  - envelope pairwise correlation matrix
%             MPx - modulation power
%             MVx - modulation variance
%             MCx - modulation pairwise correlation
%             I   - subband index sorted by descending power

load(['_system/AudSys_Setup_' mfb_mode '.mat'])

[X.Px, X.I] = Envelope_Power(dex_sub);
X.Mx  = Envelope_Marginals(dex_sub);
X.Vx  = Envelope_Variance(dex_sub);
X.Cx  = Envelope_Correlation(dex_sub);
X.MPx = Modulation_Power(dexm_sub, dex_sub, fcc, mfin);
X.MVx = Modulation_Variance(dexm_sub, dex_sub);
X.MCx = Modulation_Correlation(dexm_sub);
X.I   = X.I';
