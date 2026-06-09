function M = Envelope_Marginals(x_sub)
% Envelope_Marginals  Computes the first four marginal moments of each
% subband envelope.
%
% Inputs:   x_sub   subband envelope matrix (channels x time)
%
% Output:   M       [channels x 4] matrix:
%             col 1 - mean
%             col 2 - coefficient of variation squared (variance / mean^2)
%             col 3 - skewness
%             col 4 - kurtosis

M(:, 1) = mean(x_sub, 2);
M(:, 2) = std(x_sub, 1, 2).^2 ./ (M(:, 1).^2);
M(:, 3) = skewness(x_sub')';
M(:, 4) = kurtosis(x_sub')';
