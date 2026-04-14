function texture_distance_model_v2
% TEXTURE_DISTANCE_MODEL_V2
% Computes pairwise distances between sound texture statistics for chorus
% recordings. Statistics are extracted per sound file and then distances
% are computed across four feature types: spectral mean, variance,
% subband correlation, and modulation power.

%% --- Setup: load auditory system and toolboxes ---

clear all

addpath(genpath('_ltfat'))        % Large Time-Frequency Analysis toolbox
addpath(genpath('_minFunc_2012')) % Optimization toolbox (used by synthesis)
addpath(genpath('_sts'))          % Sound texture synthesis toolbox

mfb_mode = 'halfoctave';
% Load pre-configured auditory system: filterbank (g), downsampled rate
% (fs_d), compression parameters, centre frequencies (fcc), and
% modulation filterbank (mfb)
load(['_system/AudSys_Setup_' mfb_mode '_fs48k.mat'])

%% --- Extract texture statistics for each sound file ---

% Find all WAV files in the chorus/8 directory
d = [dir('../../../sounds/chorus/8/*.wav')];

mkdir('_stats_dist2')
for kk = 1:length(d)
    disp(kk)
    [x, fs] = audioread([d(kk).folder '/' d(kk).name]);

    % Trim/pad to exactly 3 seconds (mono)
    y1 = zeros(3*fs,1);
    y1(:,1) = x(1:3*fs,1);

    % Apply auditory filterbank to get subband signals (channels x time)
    y_sub = ufilterbank(y1,g,1)';

    % Extract subband envelopes using Hilbert transform
    [dey_sub eyf_sub] = Subband_Envelopes(y_sub,fs,fs_d,compression,'hilbert',fcc);

    % Apply modulation filterbank to subband envelopes
    deym_sub = mfilterbank(dey_sub,mfb);

    % Compute texture statistics: spectral mean/variance (Mx),
    % subband correlations (Cx), and modulation power (MPx)
    Y = Meas_SynthStats(dey_sub,deym_sub,mfb_mode);
    save(['_stats_dist2/Y_8_' num2str(kk) '.mat'],'Y')
end

%% --- Aggregate statistics across files into feature matrices ---

clear all

% Xm:  spectral mean features      (10 classes x features x 100 samples)
% Xv:  spectral variance features  (10 classes x features x 100 samples)
% Xc:  subband correlation features (10 classes x features x 100 samples)
% Xmp: modulation power features   (10 classes x features x 100 samples)
for k = 1:10        % sound class index
    for n = 1:100   % sample index within class
        load(['_stats_dist2/Y_8_' num2str((k-1)*100+n) '.mat'])
        Xm(k,:,n)  = Y.Mx(:,1);              % spectral mean
        Xv(k,:,n)  = Y.Mx(:,2);              % spectral variance
        Xc(k,:,n)  = reshape(Y.Cx(:,:),[],1);  % subband correlations (vectorised)
        Xmp(k,:,n) = reshape(Y.MPx(:,:),[],1); % modulation power (vectorised)
    end
end

%% --- Pairwise distances: spectral mean ---

clearvars P B
% Compute pairwise Euclidean distances between all 10 classes for each of
% the 100 samples, then average across samples
for m = 1:100
    for k = 1:10
        for n = 1:10
            P(k,n,m) = pdist2(Xm(k,:,m),Xm(n,:,m));
        end
    end
end

P = mean(P,3); % average distance matrix across samples

% Extract lower triangle (unique pairs) as a vector
B = tril(P)';
B = nonzeros(B);

save('spec_v2_dist.mat','B')

%% --- Pairwise distances: spectral variance ---

clearvars P B
for m = 1:100
    for k = 1:10
        for n = 1:10
            P(k,n,m) = pdist2(Xv(k,:,m),Xv(n,:,m));
        end
    end
end

P = mean(P,3);

B = tril(P)';
B = nonzeros(B);

save('var_v2_dist.mat','B')

%% --- Pairwise distances: subband correlation ---

clearvars P B
for m = 1:100
    for k = 1:10
        for n = 1:10
            P(k,n,m) = pdist2(Xc(k,:,m),Xc(n,:,m));
        end
    end
end

P = mean(P,3);

B = tril(P)';
B = nonzeros(B);

save('corr_v2_dist.mat','B')

%% --- Pairwise distances: modulation power ---

clearvars P B
for m = 1:100
    for k = 1:10
        for n = 1:10
            P(k,n,m) = pdist2(Xmp(k,:,m),Xmp(n,:,m));
        end
    end
end

P = mean(P,3);

B = tril(P)';
B = nonzeros(B);

save('mod_power_v2_dist.mat','B')