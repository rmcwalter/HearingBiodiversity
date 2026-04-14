function V = Envelope_Variance(x_sub)
% ENVELOPE_VARIANCE  Compute variance of each subband envelope.
%
% Input:
%   x_sub - subband envelopes (num_subbands x time)
%
% Output:
%   V - variance per subband (num_subbands x 1)
%       Uses normalisation by N (population variance, std flag = 1)

V = std(x_sub,1,2).^2;