function g = gt_fir(fcc,fs,n,M,betamul,c,bandwidth)
% GT_FIR  Generate a bank of gammatone FIR filters.
%
% Implements the all-pole gammatone filter approximation as causal FIR filters
% with a specified bandwidth mode.
%
% Inputs:
%   fcc       - vector of centre frequencies (Hz)
%   fs        - sample frequency (Hz)
%   n         - filter length (samples)
%   M         - peripheral filter spacing parameter (1 = one filter per ERB)
%   betamul   - bandwidth tuning multiplier (typical value: 1.0183)
%   c         - chirp factor (0 for standard gammatone)
%   bandwidth - bandwidth mode: 'ERB' (4th-order), '3rd' or '12th' (12th-order),
%               'octave' (octave-spaced)
%
% Output:
%   g - cell array of FIR filter coefficients, one cell per centre frequency

% Compute ERB bandwidths and corresponding filter bandwidths
bw = 24.7 + fcc/9.265;
ourbeta = betamul*bw/M;

% Set filter order N and recompute bandwidth depending on bandwidth mode
if strcmp(bandwidth,'ERB')
    bw = 24.7 + fcc/9.265;
    ourbeta = betamul*bw/M;
    N = 4;   % 4th-order gammatone
elseif strcmp(bandwidth,'3rd')
    bw = max(fcc * (2^(1/3) -1)/2^(1/6),60);  % 1/3-octave bandwidth, min 60 Hz
    ourbeta = betamul*bw/M;
    N = 12;
elseif strcmp(bandwidth,'12th')
    bw = max(fcc * (2^(1/12) -1)/2^(1/24),30); % 1/12-octave bandwidth, min 30 Hz
    ourbeta = betamul*bw/M;
    N = 12;
elseif strcmp(bandwidth,'octave')
    bw = max(fcc * (2 -1)/2^(1/2),30);          % octave bandwidth, min 30 Hz
    ourbeta = betamul*bw/M;
else
    bw = 24.7 + fcc/9.265;
    ourbeta = betamul*bw/M;
end

g = {};
for ii = 1:length(fcc)
  % Peak delay of the gammatone envelope
  delay = 3/(2*pi*ourbeta(ii));

  % Scaling constant to normalise filter amplitude
  if strcmp(bandwidth,'ERB')
      scalconst = 1.9*(2*pi*ourbeta(ii))^N/factorial(N-1)/fs;
  elseif strcmp(bandwidth,'3rd')
      scalconst = 1.6*(2*pi*ourbeta(ii))^N/factorial(N-1)/fs;
  else
      scalconst = 1.9*(2*pi*ourbeta(ii))^N/factorial(N-1)/fs;
  end

  % Sample indices: causal portion (nlast) + pre-ringing wrap-around (nfirst)
  nfirst = ceil(fs*delay);
  nlast = n/2;
  t=[(1:nlast)/fs+delay,(1:nfirst)/fs-nfirst/fs+delay].';

  % Gammatone impulse response: amplitude envelope * complex carrier * chirp
  gwork = scalconst*t.^(N-1).*exp(2*pi*i*fcc(ii)*t + c*i*log(t)).*exp(-2*pi*ourbeta(ii)*t);

  % Store causal part, zero-padded middle, and wrapped pre-ringing
  g{ii}=[gwork(1:nlast);zeros(n-nlast-nfirst,1);gwork(nlast+1:nlast+nfirst)];
end
  