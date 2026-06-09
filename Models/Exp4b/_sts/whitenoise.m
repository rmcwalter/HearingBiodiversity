function y = whitenoise(L, x)
% whitenoise  Generates a white Gaussian noise signal with specified power.
%
% Inputs:   L   length of output signal (samples)
%           x   optional reference signal; if provided its RMS power is matched
%
% Output:   y   white noise vector of length L

if nargin < 2
    Px = 1e-4;
else
    Px = 1/length(x) * sum(x.^2);
end

rng('shuffle');
y  = randn(L, 1);
Py = 1/length(y) * sum(y.^2);
y  = y * sqrt(Px/Py);
