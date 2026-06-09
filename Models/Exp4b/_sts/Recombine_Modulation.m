function dem_sub = Recombine_Modulation(demf_sub, deme_sub)
% Recombine_Modulation  Reconstructs subband modulations by multiplying
% modulation fine-structure with modulation envelope for each channel and
% modulation band.
%
% Inputs:   demf_sub    modulation fine-structure cell {channel}(time x mod_chan)
%           deme_sub    modulation envelope cell {channel}(time x mod_chan)
%
% Output:   dem_sub     recombined modulation cell {channel}(time x mod_chan)

for k = 1:size(deme_sub, 1)
    for j = 1:size(deme_sub{k}, 2)
        dem_sub{k,1}(:,j) = demf_sub{k}(:,j) .* deme_sub{k}(:,j);
    end
end
