function de_sub = imfilterbank(dem_sub, mfbd)
% imfilterbank  Inverts the modulation filterbank to reconstruct subband
% envelopes from their modulation-domain representation.
%
% Inputs:   dem_sub     modulation-domain subband cell array
%           mfbd        modulation filterbank synthesis dual filters
%
% Output:   de_sub      reconstructed subband envelopes (channels x time)

for i = 1:size(dem_sub)
    de_sub(i,:) = 2 * real(ifilterbank(dem_sub{i}, mfbd, 1, size(dem_sub{i}, 1)));
end
