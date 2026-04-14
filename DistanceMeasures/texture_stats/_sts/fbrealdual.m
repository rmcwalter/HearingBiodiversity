function gdout = fbrealdual(g,L)
% FBREALDUAL  Compute the dual filterbank for perfect reconstruction.
%
% Given an analysis filterbank g, computes the synthesis (dual) filters gd
% such that the filterbank achieves perfect reconstruction. Uses the
% frequency-domain polyphase method for uniform filterbanks.
%
% Inputs:
%   g - cell array of analysis FIR filters
%   L - signal length (determines the DFT size used for the dual)
%
% Output:
%   gdout - cell array of dual (synthesis) filters, same length as g

M = length(g);

% Zero-pad each filter to length L in the frequency domain
g = cellfun(@(x) fir2long(x,L),g,'UniformOutput',false);

% Build frequency-domain matrix G (L x M): each column is the DFT of one filter
G = zeros(L,M);
for ii = 1:M
    G(:,ii) = fft(g{ii});
end

N = L;
gd = zeros(N,M);

% Compute dual filters via frequency-domain least-squares inversion
% (polyphase frame operator inversion for uniform, critically-sampled filterbank)
for w = 0:N-1
    idx_a = mod(w-(0:1-1)*N,L)+1;
    idx_b = mod((0:1-1)*N-w,L)+1;
    Ha = G(idx_a,:);
    Hb = conj(G(idx_b,:));
    % Solve for the dual: (Ha*Ha' + Hb*Hb') \ Ha
    Ha = (Ha*Ha'+Hb*Hb')\Ha;
    gd(idx_a,:) = Ha;
end

% Convert back to time domain
gd = ifft(gd);

% Discard negligible imaginary parts for real-valued filterbanks
if isreal(g)
    gd = real(gd);
end

% Pack columns of gd into a cell array
gdout = cell(1,M);
for m = 1:M
    gdout{m} = gd(:,m);
end