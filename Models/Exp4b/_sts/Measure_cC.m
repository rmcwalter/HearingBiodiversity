function snrcC = Measure_cC(C, Co)
% Measure_cC  Computes SNR (dB) for envelope correlation, considering only
% pairs within 4 subbands of each other.
%
% Inputs:   C    synthesised envelope correlation matrix
%           Co   target envelope correlation matrix
%
% Output:   snrcC  SNR in dB

% Zero out pairs separated by more than 4 subbands
for j = 1:size(C, 1)
    for k = (j+1):size(C, 2)
        kj = k - j;
        if ~(kj == 1 || kj == 2 || kj == 3 || kj == 4)
            C(j,k)  = 0; C(k,j)  = 0;
            Co(j,k) = 0; Co(k,j) = 0;
        end
    end
end
snrcC = 10 * log10(sum(sum(Co.^2)) / sum(sum((Co - C).^2)));
