function ey_sub = Apply_Sub_Stats(ey_sub, X, FLAG, mfb, F)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Apply_Sub_Stats  Imposes subband envelope statistics via gradient descent.
%
% Inputs:   ey_sub  subband envelope (channels x time, downsampled)
%           X       target statistics struct
%           FLAG    which stats to impose:
%                     1 = Power,  2 = Mean,    3 = Variance
%                     4 = Skewness, 5 = Kurtosis, 6 = Correlation
%           mfb     modulation filterbank (passed to cost function)
%           F       gradient descent mode: 'reg' = tight convergence,
%                   otherwise fast/loose
%
% Output:   ey_sub  statistics-constrained subband envelopes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options = [];
if strcmp(F, 'reg')
    options.display    = 'none';
    options.Method     = 'lbfgs';
    options.maxFunEvals = 200;
    options.optTol     = 1e-12;
    options.useMex     = 1;
else
    options.display    = 'none';
    options.Method     = 'lbfgs';
    options.maxFunEvals = 25;
    options.optTol     = 1e-5;
    options.useMex     = 1;
end

for j = X.I
    ey_sub(j,:) = min(minFunc(@c_funk, ey_sub(j,:)', options, X.Mx(j,:), ey_sub(j,:)', ...
                              X.Cx(j,j), mfb, X.MPx(j,:), X.Px(j,:), FLAG.*(FLAG<6))', 0.5);
    for k = (j+1):size(ey_sub, 1)
        ey_sub(k,:) = min(minFunc(@c_funk, ey_sub(k,:)', options, X.Mx(k,:), ey_sub(j,:)', ...
                                  X.Cx(k,j), mfb, X.MPx(j,:), X.Px(j,:), FLAG.*(FLAG>5))', 0.5);
    end
end
