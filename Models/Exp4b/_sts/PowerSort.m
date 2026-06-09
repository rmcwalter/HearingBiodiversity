function I = PowerSort(P)
% PowerSort  Returns channel indices sorted by descending power.
%
% Inputs:   P   vector of per-channel power values
%
% Output:   I   indices in descending power order

[~, I] = sort(P);
I = fliplr(I');
