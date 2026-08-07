function w = make_window(L,Lr,fs)

% make a raised cosine window
%
% Inputs:
% L is the duration of the window in seconds
% Lr is the duration of the ramp in seconds
% fs is the sample rate
%
% Output:
% w is the window
%

w = ones(round(L*fs),1);
w(1:Lr*fs,1) = (cos(linspace(-pi,0,Lr*fs))+1)/2;
w(end-Lr*fs+1:end,1) = (cos(linspace(0,pi,Lr*fs))+1)/2;
