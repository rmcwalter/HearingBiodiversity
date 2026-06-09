function [P, I] = Envelope_Power(e_sub)
% Envelope_Power  Computes RMS power of each subband envelope.
%
% Inputs:   e_sub   subband envelope matrix (channels x time)
%
% Outputs:  P       column vector of per-channel power values
%           I       channel indices sorted by descending power

P = zeros(size(e_sub, 1), 1);
for i = 1:size(e_sub, 1)
    P(i, 1) = 1/length(e_sub(i,:)) * sum(e_sub(i,:).^2);
end

[~, I] = sort(P);
I = flipud(I);
