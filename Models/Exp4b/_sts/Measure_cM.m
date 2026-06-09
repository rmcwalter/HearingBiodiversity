function snr = Measure_cM(y, x)
% Measure_cM  Computes SNR (dB) between a target statistic vector x and
% a synthesised statistic vector y.
%
%   SNR = 10 * log10( sum(x^2) / sum((x - y)^2) )
%
% Inputs:   y   synthesised statistic values
%           x   target statistic values
%
% Output:   snr  SNR in dB

snr = 10 * log10(sum(sum(x.^2)) / sum(sum((x - y).^2)));
