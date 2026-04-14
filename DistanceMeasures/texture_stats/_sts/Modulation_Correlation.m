function MC1 = Modulation_Correlation(dem_sub)
% MODULATION_CORRELATION  Compute correlations between modulation channels
%                         of adjacent subbands.
%
% Input:
%   dem_sub - modulation-filtered subband envelopes, cell array (num_subbands x 1);
%             each cell is (time x num_mod_channels)
%
% Output:
%   MC1 - correlation array (num_subbands x num_subbands x num_mod_channels)
%         Only filled for subband pairs separated by 0, 1, or 2 channels;
%         all other entries remain zero. The matrix is symmetric: MC1(j,k,i) = MC1(k,j,i).

for i = 1:size(dem_sub{1},2)       % loop over modulation channels
    for j = 1:size(dem_sub,1)      % loop over subbands
        for k = j:size(dem_sub,1)  % upper triangle only (symmetry applied below)
            % Only correlate subbands within 2 channels of each other
            if (k - j) == 0 || (k - j) == 1 || (k - j) == 2
                C_temp = corrcoef(dem_sub{j}(:,i),dem_sub{k}(:,i));
                MC1(j,k,i) = C_temp(2);  % off-diagonal element of 2x2 corrcoef output
                MC1(k,j,i) = C_temp(2);  % enforce symmetry
            end
        end
    end
end

% MC1 = zeros(size(dem_sub{1},2),size(dem_sub,1),size(dem_sub,1));
% 
% for i = 1:size(dem_sub{1},2)
%     for j = 1:size(dem_sub,1)
%         for k = 1:size(dem_sub,1)
%             C_temp = corrcoef(dem_sub{j}(:,i),dem_sub{k}(:,i));
%             MC1(i,j,k) = C_temp(2);
%         end
%     end
% end
