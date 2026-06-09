function f = ERBrate_(fmin, fmax, fs, ERB_chan)
% ERBrate_  Generates a vector of frequencies spaced uniformly on the ERB
% (Equivalent Rectangular Bandwidth) rate scale.
%
% Inputs:   fmin        minimum frequency (Hz)
%           fmax        maximum frequency (Hz)
%           fs          sample frequency (Hz)
%           ERB_chan    number of ERB channels per ERB unit
%
% Output:   f           frequency vector (Hz) from fmin to fmax on ERB scale

M = ceil(21.4 * log10(4.37*(fs/(2*1e3)) + 1) * ERB_chan);

ERBr_min = 21.4 * log10(0.00437*fmin + 1);
ERBr_max = 21.4 * log10(0.00437*fmax + 1);

ERBr = linspace(ERBr_min, ERBr_max, M);
f    = (10.^(ERBr/21.4) - 1) / 0.00437;

[~, fmin_ind] = min(abs(f - fmin));
[~, fmax_ind] = min(abs(f - fmax));
f = f(fmin_ind:fmax_ind);
