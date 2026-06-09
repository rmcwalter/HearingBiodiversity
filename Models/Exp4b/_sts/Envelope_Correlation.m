function C = Envelope_Correlation(e_sub)
% Envelope_Correlation  Computes pairwise Pearson correlations between all
% subband envelope pairs.
%
% Inputs:   e_sub   subband envelope matrix (channels x time)
%
% Output:   C       [channels x channels] correlation matrix

C = zeros(size(e_sub, 1));

for i = 1:size(e_sub, 1)
    for j = 1:size(e_sub, 1)
        x    = e_sub(i, :);
        y    = e_sub(j, :);
        xvar = sqrt(sum((x - mean(x)).^2));
        yvar = sqrt(sum((y - mean(y)).^2));
        C(i, j) = sum((x - mean(x)).*(y - mean(y))) / (xvar * yvar);
    end
end
