function xm_sub = mfilterbank(x_sub,mfb)
% MFILTERBANK  Apply a modulation filterbank to each subband envelope.
%
% Inputs:
%   x_sub   - subband envelopes, size (num_subbands x time)
%   mfb     - modulation filterbank (cell array of FIR filters)
%
% Output:
%   xm_sub  - cell array (num_subbands x 1); each cell contains the
%             modulation-filtered output for one subband (time x num_mod_channels)

Lm = 0;

% Apply the modulation filterbank independently to each subband envelope
for i = 1:size(x_sub,1)
       xm_sub{i,1} = ufilterbank(x_sub(i,:),mfb,1);
end
