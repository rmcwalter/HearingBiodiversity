function [mfb, fin] = FIR_Mod_FB(fs, L, spacing, f0)
% FIR_Mod_FB  Generates a modulation filterbank as a cell array of FIR
% bandpass filters with Kaiser windows.
%
% Filter center frequencies are determined by the spacing mode; bandwidth
% is set by a Q-factor of 2.  Each filter is zero-padded to length L and
% circularly shifted so that the impulse response is causal.
%
% Inputs:   fs       sample frequency (Hz)
%           L        filter length (samples)
%           spacing  frequency spacing mode:
%                      'log20'     - 20 log-spaced filters
%                      'octave'    - octave-spaced filters
%                      '2xoctave'  - two-octave-spaced filters
%                      'halfoctave'- half-octave-spaced filters
%                      'linSpace'  - 10 linearly-spaced filters
%                      'Lp5Hz'     - single 5 Hz lowpass
%                      'Lp150Hz'   - single 150 Hz lowpass
%           f0       lowest center frequency (Hz)
%
% Output:   mfb      cell array of FIR filter coefficients
%           fin      vector of filter center frequencies (Hz)

if strcmp('log20', spacing)
    fin = logspace(log10(f0), log10(fs/2), 20);
    Q   = 2;
    fb  = [(fin - fin/(Q))' min((fin + fin/(Q)), fs/2-1)'];

    for i = 1:length(fin)
        clear b bz
        if i == 1
            fcuts = [0 fb(i,2)];          mags = [1 0]; devs = [0.001 0.001];
        elseif i == length(fin)
            fcuts = [fb(i,1) fb(i,2)];    mags = [0 1]; devs = [0.001 0.001];
        else
            fcuts = [fb(i,1) fin(i) fin(i) fb(i,2)]; mags = [0 1 0]; devs = [0.001 0.001 0.001];
        end
        [n,Wn,beta,ftype] = kaiserord(fcuts, mags, devs, fs);
        n = n + rem(n,2);  n = min(n, L-2);
        b = fir1(n, Wn, ftype, kaiser(n+1,beta), 'noscale');
        bz = zeros(1,L);
        bz(1, L/2-floor(length(b)/2):L/2+floor(length(b)/2)) = b;
        mfb{i} = [bz(L/2:end) bz(1:L/2-1)];
    end

elseif strcmp('octave', spacing)
    fin = [2.^(log2(f0):1:floor(log2(fs)))];
    Q   = 2;
    fb  = [(fin - fin/(Q))' min((fin + fin/(Q)), fs/2-1)'];

    for i = 1:length(fin)
        clear b bz
        if i == 1
            fcuts = [0 fb(i,2)];          mags = [1 0]; devs = [0.001 0.001];
        elseif i == length(fin)
            fcuts = [fb(i,1) fb(i,2)];    mags = [0 1]; devs = [0.001 0.001];
        else
            fcuts = [fb(i,1) fin(i) fin(i) fb(i,2)]; mags = [0 1 0]; devs = [0.001 0.001 0.001];
        end
        [n,Wn,beta,ftype] = kaiserord(fcuts, mags, devs, fs);
        n = n + rem(n,2);  n = min(n, L-2);
        b = fir1(n, Wn, ftype, kaiser(n+1,beta), 'noscale');
        bz = zeros(1,L);
        bz(1, L/2-floor(length(b)/2):L/2+floor(length(b)/2)) = b;
        mfb{i} = [bz(L/2:end) bz(1:L/2-1)];
    end

elseif strcmp('2xoctave', spacing)
    fin = [2.^(log2(f0):2:floor(log2(fs)))];
    Q   = 1;
    fb  = [(fin - fin/(Q))' min((fin + fin/(Q)), fs/2-1)'];

    for i = 1:length(fin)
        clear b bz
        if i == 1
            fcuts = [0 fb(i,2)];          mags = [1 0]; devs = [0.001 0.001];
        elseif i == length(fin)
            fcuts = [fb(i,1) fb(i,2)];    mags = [0 1]; devs = [0.001 0.001];
        else
            fcuts = [fb(i,1) fin(i) fin(i) fb(i,2)]; mags = [0 1 0]; devs = [0.001 0.001 0.001];
        end
        [n,Wn,beta,ftype] = kaiserord(fcuts, mags, devs, fs);
        n = n + rem(n,2);  n = min(n, L-2);
        b = fir1(n, Wn, ftype, kaiser(n+1,beta), 'noscale');
        bz = zeros(1,L);
        bz(1, L/2-floor(length(b)/2):L/2+floor(length(b)/2)) = b;
        mfb{i} = [bz(L/2:end) bz(1:L/2-1)];
    end

elseif strcmp('halfoctave', spacing)
    fin = [2.^(log2(f0):0.5:floor(log2(fs)))];
    Q   = 2;
    fb  = [(fin - fin/(Q))' min((fin + fin/(Q)), fs/2-1)'];

    for i = 1:length(fin)
        clear b bz
        if i == 1
            fcuts = [0 fb(i,2)];          mags = [1 0]; devs = [0.001 0.001];
        elseif i == length(fin)
            fcuts = [fb(i,1) fb(i,2)];    mags = [0 1]; devs = [0.001 0.001];
        else
            fcuts = [fb(i,1) fin(i) fin(i) fb(i,2)]; mags = [0 1 0]; devs = [0.001 0.001 0.001];
        end
        [n,Wn,beta,ftype] = kaiserord(fcuts, mags, devs, fs);
        n = n + rem(n,2);  n = min(n, L-2);
        b = fir1(n, Wn, ftype, kaiser(n+1,beta), 'noscale');
        bz = zeros(1,L);
        bz(1, L/2-floor(length(b)/2):L/2+floor(length(b)/2)) = b;
        mfb{i} = [bz(L/2:end) bz(1:L/2-1)];
    end

elseif strcmp('linSpace', spacing)
    fin = linspace(f0, fs/2, 10);
    Q   = 2;
    fb  = [(fin - 32)' min((fin + 32), fs/2-1)'];

    for i = 1:length(fin)
        clear b bz
        if i == 1
            fcuts = [0 fb(i,2)];          mags = [1 0]; devs = [0.001 0.001];
        elseif i == length(fin)
            fcuts = [fb(i,1) fb(i,2)];    mags = [0 1]; devs = [0.001 0.001];
        else
            fcuts = [fb(i,1) fin(i) fin(i) fb(i,2)]; mags = [0 1 0]; devs = [0.001 0.001 0.001];
        end
        [n,Wn,beta,ftype] = kaiserord(fcuts, mags, devs, fs);
        n = n + rem(n,2);  n = min(n, L-2);
        b = fir1(n, Wn, ftype, kaiser(n+1,beta), 'noscale');
        bz = zeros(1,L);
        bz(1, L/2-floor(length(b)/2):L/2+floor(length(b)/2)) = b;
        mfb{i} = [bz(L/2:end) bz(1:L/2-1)];
    end

elseif strcmp('Lp5Hz', spacing)
    fin = [5 5];
    Q   = 2;
    fb  = [(fin - fin/(Q))' min((fin + fin/(Q)), fs/2-1)'];

    for i = 1:length(fin)
        clear b bz
        if i == 1
            fcuts = [0 fb(i,2)];       mags = [1 0]; devs = [0.001 0.001];
        elseif i == 2
            fcuts = [fb(i,1) fb(i,2)]; mags = [0 1]; devs = [0.001 0.001];
        end
        [n,Wn,beta,ftype] = kaiserord(fcuts, mags, devs, fs);
        n = n + rem(n,2);  n = min(n, L-2);
        b = fir1(n, Wn, ftype, kaiser(n+1,beta), 'noscale');
        bz = zeros(1,L);
        bz(1, L/2-floor(length(b)/2):L/2+floor(length(b)/2)) = b;
        mfb{i} = [bz(L/2:end) bz(1:L/2-1)];
    end

elseif strcmp('Lp150Hz', spacing)
    fin = [150 150];
    Q   = 2;
    fb  = [(fin - fin/(Q))' min((fin + fin/(Q)), fs/2-1)'];

    for i = 1:length(fin)
        clear b bz
        if i == 1
            fcuts = [0 fb(i,2)];       mags = [1 0]; devs = [0.001 0.001];
        elseif i == 2
            fcuts = [fb(i,1) fb(i,2)]; mags = [0 1]; devs = [0.001 0.001];
        end
        [n,Wn,beta,ftype] = kaiserord(fcuts, mags, devs, fs);
        n = n + rem(n,2);  n = min(n, L-2);
        b = fir1(n, Wn, ftype, kaiser(n+1,beta), 'noscale');
        bz = zeros(1,L);
        bz(1, L/2-floor(length(b)/2):L/2+floor(length(b)/2)) = b;
        mfb{i} = [bz(L/2:end) bz(1:L/2-1)];
    end

else
    disp('boooo!!!!!');
end
