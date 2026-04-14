function [P,I] = Envelope_Power(e_sub)
% ENVELOPE_POWER  Compute mean power of each subband envelope.
%
% Inputs:
%   e_sub - subband envelopes (num_subbands x time)
%
% Outputs:
%   P - mean power per subband (num_subbands x 1)
%   I - subband indices sorted by descending power

P = zeros(size(e_sub,1),1);

% Mean squared amplitude for each subband
for i = 1:size(e_sub,1)
    P(i,1) = 1/length(e_sub(i,:)) * sum(e_sub(i,:).^2);
end

% Sort ascending then flip to get descending order
[Px,I] = sort(P);
I = flipud(I);