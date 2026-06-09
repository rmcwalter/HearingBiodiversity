function snrmC = Measure_mC(MCy, MCx)
% Measure_mC  Computes SNR (dB) for modulation correlation, averaged
% across all modulation channels.
%
% Inputs:   MCy     synthesised modulation correlation array
%           MCx     target modulation correlation array
%
% Output:   snrmC   SNR in dB (mean across modulation channels)

snrmC = 0;
for j = 1:size(MCy, 2)
    snrmC = snrmC + (1/size(MCy, 2)) * ...
        (sum(sum(MCx(j,:,:).^2)) / sum(sum((MCx(j,:,:) - MCy(j,:,:)).^2)));
end
snrmC = 10 * log10(snrmC);
