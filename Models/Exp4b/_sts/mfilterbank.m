function xm_sub = mfilterbank(x_sub, mfb)
% mfilterbank  Applies the modulation filterbank to each subband envelope.
%
% Inputs:   x_sub   subband envelopes (channels x time)
%           mfb     modulation filterbank cell array of filter coefficients
%
% Output:   xm_sub  cell array {channel}(time x mod_channels) of
%                   modulation-filtered envelopes

for i = 1:size(x_sub, 1)
    xm_sub{i, 1} = ufilterbank(x_sub(i,:), mfb, 1);
end
