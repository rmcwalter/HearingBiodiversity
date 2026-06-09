function texture_distance_model
% texture_distance_model  Computes pairwise texture-statistic distances
% between chorus recordings for Figure 4 analysis.
%
% Processes chorus sounds at three size conditions (8, 16, and mix bird
% choruses).  For each recording the first 3 seconds are analysed with
% a gammatone filterbank + modulation filterbank pipeline and the resulting
% statistics struct Y is saved to _stats_dist_new3/.
%
% After all statistics are saved the script loads the mix-condition results
% and computes four pairwise Euclidean distance matrices (species vs species):
%   spec_v3_dist.mat      - envelope mean (frequency spectrum)
%   var_v3_dist.mat       - envelope coefficient of variation
%   corr_v3_dist.mat      - envelope correlation
%   mod_power_v3_dist.mat - modulation power
%
% Requires AudSys_Setup_halfoctave_fs48k.mat in _system/.

clear all

addpath(genpath('_ltfat'))
addpath(genpath('_minFunc_2012'))
addpath(genpath('_sts'))
mfb_mode = 'halfoctave';
load(['_system/AudSys_Setup_' mfb_mode '_fs48k.mat'])

%% Compute statistics for 8-bird choruses
d = [dir('../../sounds/chorus/8/*.wav')];

mkdir('_stats_dist_new3')
for kk = 1:length(d)
    disp(kk)
    [x, fs] = audioread([d(kk).folder '/' d(kk).name]);
    y1 = zeros(3*fs, 1);
    y1(:, 1) = x(1:3*fs, 1);
    y_sub = ufilterbank(y1, g, 1)';
    [dey_sub eyf_sub] = Subband_Envelopes(y_sub, fs, fs_d, compression, 'hilbert', fcc);
    deym_sub = mfilterbank(dey_sub, mfb);

    Y = Meas_SynthStats(dey_sub, deym_sub, mfb_mode);
    save(['_stats_dist_new3/Y_8_' num2str(kk) '.mat'], 'Y')
end

%% Compute statistics for 16-bird choruses
d = [dir('../../sounds/chorus/16/*.wav')];

mkdir('_stats_dist_new3')
for kk = 1:length(d)
    disp(kk)
    [x, fs] = audioread([d(kk).folder '/' d(kk).name]);
    y1 = zeros(3*fs, 1);
    y1(:, 1) = x(1:3*fs, 1);
    y_sub = ufilterbank(y1, g, 1)';
    [dey_sub eyf_sub] = Subband_Envelopes(y_sub, fs, fs_d, compression, 'hilbert', fcc);
    deym_sub = mfilterbank(dey_sub, mfb);

    Y = Meas_SynthStats(dey_sub, deym_sub, mfb_mode);
    save(['_stats_dist_new3/Y_16_' num2str(kk) '.mat'], 'Y')
end

%% Compute statistics for mixed-species choruses
d = [dir('../../sounds/chorus/mix/*.wav')];

mkdir('_stats_dist_new3')
for kk = 1:length(d)
    disp(kk)
    [x, fs] = audioread([d(kk).folder '/' d(kk).name]);
    y1 = zeros(3*fs, 1);
    y1(:, 1) = x(1:3*fs, 1);
    y_sub = ufilterbank(y1, g, 1)';
    [dey_sub eyf_sub] = Subband_Envelopes(y_sub, fs, fs_d, compression, 'hilbert', fcc);
    deym_sub = mfilterbank(dey_sub, mfb);

    Y = Meas_SynthStats(dey_sub, deym_sub, mfb_mode);
    save(['_stats_dist_new3/Y_mix_' num2str(kk) '.mat'], 'Y')
end

%% Load mix-condition statistics and assemble feature matrices
% Xm: envelope mean; Xv: env. coeff. of variation; Xc: env. correlation
% Xmp: modulation power  (10 species x features x 100 samples)

clear all

for k = 1:10
    for n = 1:100
        load(['_stats_dist_new3/Y_mix_' num2str((k-1)*100+n) '.mat'])
        Xm(k, :, n)  = Y.Mx(:, 1);
        Xv(k, :, n)  = Y.Mx(:, 2);
        Xc(k, :, n)  = reshape(Y.Cx(:, :), [], 1);
        Xmp(k, :, n) = reshape(Y.MPx(:, :), [], 1);
    end
end

%% Pairwise distances: envelope mean (frequency spectrum)
for m = 1:100
    for k = 1:10
        for n = 1:10
            P(k, n, m) = pdist2(Xm(k, :, m), Xm(n, :, m));
        end
    end
end
P = mean(P, 3);
B = tril(P)';
B = nonzeros(B);
save('spec_v3_dist.mat', 'B')

%% Pairwise distances: envelope coefficient of variation
for m = 1:100
    for k = 1:10
        for n = 1:10
            P(k, n, m) = pdist2(Xv(k, :, m), Xv(n, :, m));
        end
    end
end
P = mean(P, 3);
B = tril(P)';
B = nonzeros(B);
save('var_v3_dist.mat', 'B')

%% Pairwise distances: envelope correlation
for m = 1:100
    for k = 1:10
        for n = 1:10
            P(k, n, m) = pdist2(Xc(k, :, m), Xc(n, :, m));
        end
    end
end
P = mean(P, 3);
B = tril(P)';
B = nonzeros(B);
save('corr_v3_dist.mat', 'B')

%% Pairwise distances: modulation power
for m = 1:100
    for k = 1:10
        for n = 1:10
            P(k, n, m) = pdist2(Xmp(k, :, m), Xmp(n, :, m));
        end
    end
end
P = mean(P, 3);
B = tril(P)';
B = nonzeros(B);
save('mod_power_v3_dist.mat', 'B')
