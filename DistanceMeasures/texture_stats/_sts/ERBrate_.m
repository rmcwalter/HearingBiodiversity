function f = ERBrate_(fmin,fmax,fs,ERB_chan)
% ERBRATE_  Generate ERB-spaced centre frequencies between fmin and fmax.
%
% Uses the ERB-rate scale: ERBrate = 21.4 * log10(0.00437*f + 1)
%
% Inputs:
%   fmin     - lowest centre frequency (Hz)
%   fmax     - highest centre frequency (Hz, typically fs/2)
%   fs       - sample frequency (Hz)
%   ERB_chan - number of filters per ERB (1 = one filter per ERB bandwidth)
%
% Output:
%   f - vector of ERB-spaced centre frequencies (Hz) from fmin to fmax

% Total number of ERB channels across the full auditory range up to fs/2
M = ceil(21.4*log10(4.37*(fs/(2*1e3)) + 1) * ERB_chan);

% Convert fmin and fmax to ERB-rate
ERBr_min = 21.4*log10(0.00437*fmin + 1);
ERBr_max = 21.4*log10(0.00437*fmax + 1);

% Linearly space M points in ERB-rate, then convert back to Hz
ERBr = linspace(ERBr_min,ERBr_max,M);
f = (10.^(ERBr/21.4) - 1) / 0.00437;

% Trim to the requested [fmin, fmax] range
[dummy,fmin_ind] = min(abs(f - fmin));
[dummy,fmax_ind] = min(abs(f - fmax));
f = f(fmin_ind:fmax_ind);