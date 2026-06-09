function snrmV = Measure_mV(MVy, MVx)
% Measure_mV  Computes SNR (dB) for modulation variance.
%
% Inputs:   MVy     synthesised modulation variance matrix
%           MVx     target modulation variance matrix
%
% Output:   snrmV   SNR in dB

snrmV = 10 * log10(sum(sum(MVx.^2)) / sum(sum((MVx - MVy).^2)));
