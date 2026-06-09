function ey_sub = Apply_Power(ey_sub, X, CFLAG)
% Apply_Power  Scales each subband envelope to match the target power.
% Only applied when CFLAG contains the value 6.
%
% Inputs:   ey_sub  synthetic subband envelopes (channels x time)
%           X       target statistics struct with field Px
%           CFLAG   vector of active statistic flags
%
% Output:   ey_sub  power-scaled subband envelopes

if sum(CFLAG == 6)
    Ly = size(ey_sub, 2);
    for k = 2:size(ey_sub, 1)
        Py         = 1/Ly * sum(ey_sub(k,:).^2);
        ey_sub(k,:) = ey_sub(k,:) * sqrt(X.Px(k) / Py);
    end
end
