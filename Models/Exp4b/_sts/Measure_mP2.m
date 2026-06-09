function snrmP2 = Measure_mP2(MP2y, MP2x)
% Measure_mP2  Computes SNR (dB) for a cell-array modulation power
% representation, averaged across subbands.
%
% Inputs:   MP2y    synthesised modulation power cell array
%           MP2x    target modulation power cell array
%
% Output:   snrmP2  SNR in dB

snrmP2 = 0;
for k = 1:size(MP2y, 1)
    snrmP2 = snrmP2 + (1/size(MP2y, 1)) * ...
        (sum(sum(MP2x{k}.^2)) / sum(sum((MP2x{k} - MP2y{k}).^2)));
end
snrmP2 = 10 * log10(snrmP2);
