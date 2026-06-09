function [f, g] = m_funk(y1, mPx, y2, mCx, y, FLAG)
% m_funk  Cost function and gradient for imposing modulation statistics
% via L-BFGS (called by Apply_Mod_Stats via minFunc).
%
% Inputs:   y1    current modulation channel signal (Ly x 1)
%           mPx   target modulation power (scalar)
%           y2    reference modulation channel for correlation
%           mCx   target modulation correlation with y2 (scalar)
%           y     parent subband envelope (used for power normalisation)
%           FLAG  active stat flags: 1 = Mod Power, 2 = Mod Correlation
%
% Outputs:  f     scalar cost
%           g     gradient vector (Ly x 1)

Ly   = length(y1);
yvar = std(y, 1)^2;

% Modulation power (normalised by subband envelope variance)
mPy = 1/Ly * sum((y1 - mean(y1)).^2) / yvar;
mP  = (mPx - mPy)^2;
mPg = -2 * (mPx - mPy) * 2/Ly*(y1 - sum(y1)/Ly) / yvar;

% Modulation correlation between y1 and reference y2
mCy = 1/Ly * sum((y1 - mean(y1)).*(y2 - mean(y2))) / (std(y1,1)*std(y2,1));
mC  = (mCx - mCy)^2;
mCg = 2*(mCx - mCy) * ...
      (-(1/Ly*(y2 - mean(y2))) * (std(y1,1)^(-1)*std(y2,1)^(-1)) + ...
        1/Ly * sum((y1 - mean(y1)).*(y2 - mean(y2))) * ...
        (1/2*(1/Ly*sum((y1 - mean(y1)).^2))^(-3/2) * (1/(Ly)*(2*y1 - 2*mean(y1)))) * std(y2,1)^(-1));

f = 0;
g = zeros(Ly, 1);
if sum(FLAG == 1), f = f + mP;  g = g + mPg; end
if sum(FLAG == 2), f = f + mC;  g = g + mCg; end
