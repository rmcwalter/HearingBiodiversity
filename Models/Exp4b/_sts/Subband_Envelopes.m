function [de_sub, ef_sub] = Subband_Envelopes(x_sub, fs, fs_d, compression, env_type, fcc)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subband_Envelopes applies peripheral compression and extracts the
% envelope from the fine-structure subband signal x_sub.
%
% Inputs:   x_sub           subband signal matrix (channels x samples)
%           fs              sample frequency (Hz)
%           fs_d            envelope downsample frequency (Hz)
%           compression     per-channel compression exponents
%           env_type        envelope extraction method ('hilbert')
%           fcc             gammatone filterbank center frequencies
%
% Outputs:  de_sub          downsampled subband envelope
%           ef_sub          subband fine-structure (phase) signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

b     = fir1(17, fs_d/(fs));
e_sub = zeros(size(x_sub));

if strcmp('hilbert', env_type)
    for k = 1:size(x_sub, 1)
        % Apply compression to real and imaginary parts independently,
        % then lowpass-filter and downsample the envelope
        e_sub(k,:)  = fftfilt(b, abs(sign(real(x_sub(k,:))).*abs(real(x_sub(k,:))).^(compression(k)) + ...
                                    sqrt(-1)*sign(imag(x_sub(k,:))).*abs(imag(x_sub(k,:))).^(compression(k))));
        de_sub(k,:) = resample(e_sub(k,:), fs_d, fs);
        e_sub(k,:)  = resample(de_sub(k,:), fs, fs_d).^(1/compression(k));
    end
elseif strcmp('hilbertX', env_type)
    b = fir1(17, 200/(fs/2));
    for k = 1:size(x_sub, 1)
        e_sub(k,:)  = fftfilt(b, abs(x_sub(k,:)).^compression(k));
        de_sub(k,:) = resample(e_sub(k,:), 400, fs);
        e_sub(k,:)  = resample(de_sub(k,:), fs, 400).^(1/compression(k));
    end
end

ef_sub = x_sub ./ e_sub;
