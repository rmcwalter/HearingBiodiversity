function X = Meas_SynthStats(dex_sub,dexm_sub,mfb_mode)
% MEAS_SYNTHSTATS  Compute the full set of texture statistics for a sound.
%
% Inputs:
%   dex_sub   - subband envelopes (num_subbands x time)
%   dexm_sub  - modulation-filtered subband envelopes, cell array (num_subbands x 1)
%   mfb_mode  - modulation filterbank spacing string (e.g. 'halfoctave'),
%               used to load the matching auditory system configuration
%
% Output:
%   X  - struct with fields:
%     .Px   - subband envelope power (num_subbands x 1)
%     .I    - subband indices sorted by descending power (transposed)
%     .Mx   - envelope marginal statistics: mean, variance, skewness, kurtosis
%     .Vx   - envelope variance per subband
%     .Cx   - pairwise subband envelope correlations
%     .MPx  - modulation power, normalised by subband envelope variance
%     .MVx  - modulation variance, normalised by subband envelope variance
%     .MCx  - modulation correlation between adjacent subbands

% Load auditory system parameters (fcc, mfin, etc.) for the given spacing
load(['_system/AudSys_Setup_' mfb_mode '.mat'])

% Compute each statistic in turn
[X.Px,X.I] = Envelope_Power(dex_sub);
X.Mx = Envelope_Marginals(dex_sub);
X.Vx = Envelope_Variance(dex_sub);
X.Cx = Envelope_Correlation(dex_sub);
X.MPx = Modulation_Power(dexm_sub,dex_sub,fcc,mfin);
X.MVx = Modulation_Variance(dexm_sub,dex_sub);
X.MCx = Modulation_Correlation(dexm_sub);
X.I = X.I';

