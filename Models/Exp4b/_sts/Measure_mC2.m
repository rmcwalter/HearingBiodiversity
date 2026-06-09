function snrmC2 = Measure_mC2(soMPy, soMPx)
% Measure_mC2  Computes SNR (dB) for second-order modulation correlation,
% averaged over all channel-pair and modulation-channel combinations.
%
% Inputs:   soMPy   synthesised second-order modulation correlation array
%           soMPx   target second-order modulation correlation array
%
% Output:   snrmC2  SNR in dB

snrmC2 = 0;
for n = 1:size(soMPy, 3)
    for m = 1:size(soMPy, 4)
        snrmC2 = snrmC2 + (1/size(soMPy, 1)) * (1/size(soMPy, 2)) * ...
            (sum(sum(soMPx(:,:,n,m).^2)) / sum(sum((soMPx(:,:,n,m) - soMPy(:,:,n,m)).^2)));
    end
end
snrmC2 = 10 * log10(snrmC2);
