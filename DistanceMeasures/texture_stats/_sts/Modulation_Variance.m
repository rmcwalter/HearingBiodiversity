function MV = Modulation_Variance(dem_sub,de_sub)
% MODULATION_VARIANCE  Compute modulation variance normalised by subband variance.
%
% Inputs:
%   dem_sub - modulation-filtered subband envelopes, cell array (num_subbands x 1);
%             each cell is (time x num_mod_channels)
%   de_sub  - subband envelopes (num_subbands x time), used for normalisation
%
% Output:
%   MV - modulation variance matrix (num_subbands x num_mod_channels)
%        Each value is the variance of the modulation channel divided by the
%        variance of the corresponding subband envelope

MV = ones(size(dem_sub,1),size(dem_sub{1},2));

for i = 1:size(dem_sub,1)
    % Subband envelope variance (population variance, std flag = 1)
    cV = std(de_sub(i,:),1)^2;
    for j = 1:size(dem_sub{i},2)
        % Normalised variance for each modulation channel
        MV(i,j) = std(dem_sub{i}(:,j),1)^2/cV;
    end
end