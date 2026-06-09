function x_sub = Resample_Envelope(de_sub, ef_sub, fs, fs_d, compression, fcc)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Resample_Envelope  Reconstructs complex subband signals by upsampling
% the envelope and recombining with the fine-structure.
%
% Inputs:   de_sub      downsampled subband envelope (channels x time_d)
%           ef_sub      subband fine-structure (channels x time)
%           fs          sample frequency (Hz)
%           fs_d        subband envelope sample frequency (Hz)
%           compression per-channel compression exponents
%           fcc         gammatone filterbank center frequencies (unused)
%
% Output:   x_sub       complex subband signal (channels x time)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for k = 1:size(de_sub, 1)
    e_sub(k,:) = resample(de_sub(k,:), fs, fs_d).^(1/compression(k));
end
x_sub = ef_sub .* e_sub;
