function MP = Modulation_Power(dem_sub, de_sub, fcc, mfin)
% Modulation_Power  Computes normalised modulation power for each
% subband-by-modulation-channel combination.
%
% Power is normalised by the subband envelope's coefficient of variation
% (variance / mean^2) so that channels with higher mean envelope amplitude
% do not dominate.
%
% Inputs:   dem_sub     subband modulations cell {channel}(time x mod_chan)
%           de_sub      subband envelopes (channels x time)
%           fcc         gammatone filterbank center frequencies
%           mfin        modulation filterbank center frequencies
%
% Output:   MP          [channels x mod_channels] modulation power matrix

MP = ones(size(dem_sub, 1), size(dem_sub{1}, 2));

for k = 1:size(dem_sub, 1)
    cV = std(de_sub(k,:), 1)^2 / mean(de_sub(k,:))^2;
    for j = 1:size(dem_sub{k}, 2)
        MP(k, j) = 1/size(dem_sub{k}, 1) * sum((dem_sub{k}(:,j) - mean(dem_sub{k}(:,j))).^2) / cV;
    end
end
