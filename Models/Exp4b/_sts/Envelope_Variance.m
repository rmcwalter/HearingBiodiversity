function V = Envelope_Variance(x_sub)
% Envelope_Variance  Computes the variance of each subband envelope.
%
% Inputs:   x_sub   subband envelope matrix (channels x time)
%
% Output:   V       column vector of per-channel variances

V = std(x_sub, 1, 2).^2;
