function [mfb fin] = FIR_Mod_FB(fs,L,spacing,f0)
% FIR_MOD_FB  Generate a modulation filterbank as an array of FIR bandpass filters.
%
% Filters are designed using the Kaiser window method (kaiserord + fir1) and
% zero-padded to length L with a circular shift so that the peak is centred.
%
% Inputs:
%   fs      - sample frequency of the envelope signal (Hz)
%   L       - filter length / DFT size (samples)
%   spacing - frequency spacing of modulation channels:
%               'log20'    - 20 log-spaced channels from f0 to fs/2
%               'octave'   - octave-spaced channels
%               '2xoctave' - every 2 octaves
%               'halfoctave' - half-octave spacing
%               'linSpace' - 10 linearly-spaced channels
%               'Lp5Hz'    - single lowpass channel at 5 Hz
%               'Lp150Hz'  - single lowpass channel at 150 Hz
%   f0      - lowest modulation frequency (Hz)
%
% Outputs:
%   mfb - cell array of FIR filter coefficient vectors (one per channel)
%   fin - vector of modulation centre frequencies (Hz)

if strcmp('log20',spacing)
    % Pseudo 2nd order IIR (but FIR) bandpass filters with Kaiser window
    fin = logspace(log10(f0),log10(fs/2),20);
    Q = 2;
    fb = [(fin - fin/(Q))' min((fin + fin/(Q)),fs/2-1)'];

    for i = 1:length(fin)
        clear b bz
        if i == 1
            fcuts = [0 fb(i,2)];
            mags = [1 0];
            devs = [0.001 0.001];
        elseif i == length(fin)
            fcuts = [fb(i,1) fb(i,2)];
            mags = [0 1];
            devs = [0.001 0.001];
        else
            fcuts = [fb(i,1) fin(i) fin(i) fb(i,2)];
            mags = [0 1 0];
            devs = [0.001 0.001 0.001];
        end
        [n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs,fs);
        n = n + rem(n,2);
        n = min(n,L-2);
        b = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');
        bz = zeros(1,L);
        bz(1,L/2-floor(length(b)/2):L/2+floor(length(b)/2)) = b;
        mfb{i} =  [bz(L/2:end) bz(1:L/2-1)];
    end
elseif strcmp('octave',spacing)
    % Pseudo 2nd order IIR (but FIR) bandpass filters with Kaiser window
    fin = [2.^(log2(f0):1:floor(log2(fs)))];
    Q = 2;
    fb = [(fin - fin/(Q))' min((fin + fin/(Q)),fs/2-1)'];

    for i = 1:length(fin)
        clear b bz
        if i == 1
            fcuts = [0 fb(i,2)];
            mags = [1 0];
            devs = [0.001 0.001];
        elseif i == length(fin)
            fcuts = [fb(i,1) fb(i,2)];
            mags = [0 1];
            devs = [0.001 0.001];
        else
            fcuts = [fb(i,1) fin(i) fin(i) fb(i,2)];
            mags = [0 1 0];
            devs = [0.001 0.001 0.001];
        end
        [n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs,fs);
        n = n + rem(n,2);
        n = min(n,L-2);
        b = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');
        bz = zeros(1,L);
        bz(1,L/2-floor(length(b)/2):L/2+floor(length(b)/2)) = b;
        mfb{i} =  [bz(L/2:end) bz(1:L/2-1)];
    end
elseif strcmp('2xoctave',spacing)
    % Pseudo 2nd order IIR (but FIR) bandpass filters with Kaiser window
    fin = [2.^(log2(f0):2:floor(log2(fs)))];
    Q = 1;
    fb = [(fin - fin/(Q))' min((fin + fin/(Q)),fs/2-1)'];

    for i = 1:length(fin)
        clear b bz
        if i == 1
            fcuts = [0 fb(i,2)];
            mags = [1 0];
            devs = [0.001 0.001];
        elseif i == length(fin)
            fcuts = [fb(i,1) fb(i,2)];
            mags = [0 1];
            devs = [0.001 0.001];
        else
            fcuts = [fb(i,1) fin(i) fin(i) fb(i,2)];
            mags = [0 1 0];
            devs = [0.001 0.001 0.001];
        end
        [n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs,fs);
        n = n + rem(n,2);
        n = min(n,L-2);
        b = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');
        bz = zeros(1,L);
        bz(1,L/2-floor(length(b)/2):L/2+floor(length(b)/2)) = b;
        mfb{i} =  [bz(L/2:end) bz(1:L/2-1)];
    end
elseif strcmp('halfoctave',spacing)
    % Pseudo 2nd order IIR (but FIR) bandpass filters with Kaiser window
    fin = [2.^(log2(f0):0.5:floor(log2(fs)))];
    Q = 2;
    fb = [(fin - fin/(Q))' min((fin + fin/(Q)),fs/2-1)'];

    for i = 1:length(fin)
        clear b bz
        if i == 1
            fcuts = [0 fb(i,2)];
            mags = [1 0];
            devs = [0.001 0.001];
        elseif i == length(fin)
            fcuts = [fb(i,1) fb(i,2)];
            mags = [0 1];
            devs = [0.001 0.001];
        else
            fcuts = [fb(i,1) fin(i) fin(i) fb(i,2)];
            mags = [0 1 0];
            devs = [0.001 0.001 0.001];
        end
        [n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs,fs);
        n = n + rem(n,2);
        n = min(n,L-2);
        b = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');
        bz = zeros(1,L);
        bz(1,L/2-floor(length(b)/2):L/2+floor(length(b)/2)) = b;
        mfb{i} =  [bz(L/2:end) bz(1:L/2-1)];
    end
elseif strcmp('linSpace',spacing)
    % Pseudo 2nd order IIR (but FIR) bandpass filters with Kaiser window
    fin = linspace(f0,fs/2,10);
    Q = 2;
    fb = [(fin - 32)' min((fin + 32),fs/2-1)'];

    for i = 1:length(fin)
        clear b bz
        if i == 1
            fcuts = [0 fb(i,2)];
            mags = [1 0];
            devs = [0.001 0.001];
        elseif i == length(fin)
            fcuts = [fb(i,1) fb(i,2)];
            mags = [0 1];
            devs = [0.001 0.001];
        else
            fcuts = [fb(i,1) fin(i) fin(i) fb(i,2)];
            mags = [0 1 0];
            devs = [0.001 0.001 0.001];
        end
        [n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs,fs);
        n = n + rem(n,2);
        n = min(n,L-2);
        b = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');
        bz = zeros(1,L);
        bz(1,L/2-floor(length(b)/2):L/2+floor(length(b)/2)) = b;
        mfb{i} =  [bz(L/2:end) bz(1:L/2-1)];
    end
elseif strcmp('Lp5Hz',spacing)
    % Pseudo 2nd order IIR (but FIR) bandpass filters with Kaiser window
    fin = [5 5];
    Q = 2;
    fb = [(fin - fin/(Q))' min((fin + fin/(Q)),fs/2-1)'];

    for i = 1:length(fin)
        clear b bz
        if i == 1
            fcuts = [0 fb(i,2)];
            mags = [1 0];
            devs = [0.001 0.001];
        elseif i == 2
            fcuts = [fb(i,1) fb(i,2)];
            mags = [0 1];
            devs = [0.001 0.001];
        end
        [n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs,fs);
        n = n + rem(n,2);
        n = min(n,L-2);
        b = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');
        bz = zeros(1,L);
        bz(1,L/2-floor(length(b)/2):L/2+floor(length(b)/2)) = b;
        mfb{i} =  [bz(L/2:end) bz(1:L/2-1)];
    end
elseif strcmp('Lp150Hz',spacing)
    % Pseudo 2nd order IIR (but FIR) bandpass filters with Kaiser window
    fin = [150 150];
    Q = 2;
    fb = [(fin - fin/(Q))' min((fin + fin/(Q)),fs/2-1)'];

    for i = 1:length(fin)
        clear b bz
        if i == 1
            fcuts = [0 fb(i,2)];
            mags = [1 0];
            devs = [0.001 0.001];
        elseif i == 2
            fcuts = [fb(i,1) fb(i,2)];
            mags = [0 1];
            devs = [0.001 0.001];
        end
        [n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs,fs);
        n = n + rem(n,2);
        n = min(n,L-2);
        b = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');
        bz = zeros(1,L);
        bz(1,L/2-floor(length(b)/2):L/2+floor(length(b)/2)) = b;
        mfb{i} =  [bz(L/2:end) bz(1:L/2-1)];
    end
else
    disp('boooo!!!!!');
end
