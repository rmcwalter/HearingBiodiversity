function MP = Modulation_Power(dem_sub,de_sub,fcc,mfin)
% MODULATION_POWER  Compute normalised modulation power for each subband
%                   and modulation channel.
%
% Inputs:
%   dem_sub - modulation-filtered subband envelopes, cell array (num_subbands x 1);
%             each cell is (time x num_mod_channels)
%   de_sub  - subband envelopes (num_subbands x time), used for normalisation
%   fcc     - gammatone filterbank centre frequencies (unused in current code,
%             retained for compatibility)
%   mfin    - modulation filterbank centre frequencies (unused in current code,
%             retained for compatibility)
%
% Output:
%   MP - modulation power matrix (num_subbands x num_mod_channels)
%        Each value is the mean squared deviation of the modulation channel,
%        normalised by the coefficient of variation squared of the subband envelope

MP = ones(size(dem_sub,1),size(dem_sub{1},2));

for k = 1:size(dem_sub,1)
    % Coefficient of variation squared: normalises for subband envelope level
    cV = std(de_sub(k,:),1)^2/mean(de_sub(k,:))^2;

    for j = 1:size(dem_sub{k},2)
        % Mean power of the mean-subtracted modulation channel, normalised by cV
        MP(k,j) = 1/size(dem_sub{k},1) * sum((dem_sub{k}(:,j) - mean(dem_sub{k}(:,j))).^2)/cV;
    end
end

