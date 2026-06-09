function snrmP = Measure_mP(MPy, MPx, fcc, mfin)
% Measure_mP  Computes SNR (dB) for modulation power.
%
% Inputs:   MPy     synthesised modulation power matrix
%           MPx     target modulation power matrix
%           fcc     gammatone filterbank center frequencies (unused)
%           mfin    modulation filterbank center frequencies (unused)
%
% Output:   snrmP   SNR in dB

snrmP = 10 * log10(sum(sum(MPx.^2)) ./ sum(sum((MPx - MPy).^2)));
