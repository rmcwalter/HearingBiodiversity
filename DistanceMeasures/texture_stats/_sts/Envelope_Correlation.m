function C = Envelope_Correlation(e_sub)
% ENVELOPE_CORRELATION  Compute pairwise Pearson correlations between subband envelopes.
%
% Input:
%   e_sub - subband envelopes (num_subbands x time)
%
% Output:
%   C - correlation matrix (num_subbands x num_subbands)
%       C(i,j) is the correlation between subbands i and j

C = zeros(size(e_sub,1));

for i = 1:size(e_sub,1)
    for j = 1:size(e_sub,1)
       x = e_sub(i,:);
       y = e_sub(j,:);
       % Normalise by the L2 norm of each mean-subtracted signal
       xvar = sqrt(sum((x - mean(x)).^2));
       yvar = sqrt(sum((y - mean(y)).^2));
       C(i,j) = sum((x - mean(x)).*(y - mean(y)))/(xvar*yvar);
    end
end