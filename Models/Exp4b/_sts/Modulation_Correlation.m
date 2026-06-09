function MC1 = Modulation_Correlation(dem_sub)
% Modulation_Correlation  Computes pairwise correlations between adjacent
% subband modulation channels (within ±2 subbands).
%
% Only correlations between channels j and k where |k-j| <= 2 are computed;
% all other entries remain zero.
%
% Inputs:   dem_sub     subband modulations cell {channel}(time x mod_chan)
%
% Output:   MC1         [channels x channels x mod_channels] correlation array

for i = 1:size(dem_sub{1}, 2)
    for j = 1:size(dem_sub, 1)
        for k = j:size(dem_sub, 1)
            if (k - j) == 0 || (k - j) == 1 || (k - j) == 2
                C_temp    = corrcoef(dem_sub{j}(:,i), dem_sub{k}(:,i));
                MC1(j,k,i) = C_temp(2);
                MC1(k,j,i) = C_temp(2);
            end
        end
    end
end
