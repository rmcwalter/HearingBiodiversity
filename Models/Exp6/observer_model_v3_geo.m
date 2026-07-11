function observer_model_v3_geo
% OBSERVER_MODEL_V3_GEO  Compute McDermott/Simoncelli-style sound-texture
% statistics for the geophony-background stimulus set (Exp6, condition "a")
% and package them for use by RUN_MODEL_V2.
%
% Pipeline:
%   1) For every trial wav (3 intervals concatenated per trial), extract
%      subband envelopes and their marginal/modulation statistics for
%      each of the 3 intervals separately -> saved per-file in _stats_geo2/.
%   2) Pool all stimuli, z-score each statistic type across the whole
%      corpus (so distances in RUN_MODEL_V2 are computed in comparable
%      units), then re-chunk back into per-block files in _statz_geo2/
%      (each block/run of 50 wav files corresponds to one subject-like
%      set of 63 trials x 3 intervals = 189 stat structs).

%%

clear all
warning off
addpath(genpath('../Supporting_files/_ltfat'))       % filterbank/Gabor toolbox
addpath(genpath('../Supporting_files/_minFunc_2012')) % optimization toolbox (used elsewhere in _sts)
addpath(genpath('../Model_base/_sts'))                % sound-texture stats functions
mfb_mode = 'halfoctave';
load(['../Model_base/_system/AudSys_Setup_' mfb_mode '.mat'])  % loads g, mfb, fs_d, compression, fcc (auditory + modulation filterbank setup)

% Gather all stimulus wavs across the 50 stimulus folders (63 trials each)
for k = 1:50
    d((k-1)*63+1:k*63) = dir(['geobio_stim2aY/' num2str(k) '/*.wav']);
end


warning off
mkdir('_stats_geo2')
for kk = 1:length(d)
    kk
    clearvars y fs Y dey_sub eyf_sub y_sub deym_sub

    [y fs] = audioread([d(kk).folder '/' d(kk).name]);

    % Each trial wav contains 3 intervals (with gaps); extract subband
    % envelopes and synthesis statistics (mean/var/kurtosis, envelope
    % correlations, modulation power/correlations) for each interval.
    y_sub = ufilterbank(y(1:2*fs),g,1)';
    [dey_sub eyf_sub] = Subband_Envelopes(y_sub,fs,fs_d,compression,'hilbert',fcc);
    deym_sub = mfilterbank(dey_sub,mfb);
    Y{1} = Meas_SynthStats(dey_sub,deym_sub,mfb_mode);

    y_sub = ufilterbank(y(2.5*fs+1:4.5*fs),g,1)';
    [dey_sub eyf_sub] = Subband_Envelopes(y_sub,fs,fs_d,compression,'hilbert',fcc);
    deym_sub = mfilterbank(dey_sub,mfb);
    Y{2} = Meas_SynthStats(dey_sub,deym_sub,mfb_mode);

    y_sub = ufilterbank(y(5*fs+1:7*fs),g,1)';
    [dey_sub eyf_sub] = Subband_Envelopes(y_sub,fs,fs_d,compression,'hilbert',fcc);
    deym_sub = mfilterbank(dey_sub,mfb);
    Y{3} = Meas_SynthStats(dey_sub,deym_sub,mfb_mode);

    save(['_stats_geo2/Z' num2str(kk) '.mat'],'Y')

end

clearvars -except d
clear rsp

% Reload per-file stats and flatten into one cell array Z, ordered
% interval-by-interval (3 entries per trial) across all trials.
for rx = 1
    clearvars -except d rx rsp

    M = [2 3 3];
    N = [1 1 2];
    for m = 1:length(d)
        m
        load(['_stats_geo2/Z' num2str(m) '.mat'])
        Z{3*(m-1)+1} = Y{1};
        Z{3*(m-1)+2} = Y{2};
        Z{3*(m-1)+3} = Y{3};
    end
end

% Pool each statistic type (marginal moments EM/EV/EK, envelope
% correlations EC, modulation power EMP, modulation correlations EMC)
% across all intervals/trials so they can be z-scored jointly below.
%
EM = [];
EV = [];
EK = [];
EC = [];
EMP = [];
EMC = [];
for k = 1:length(Z)
    k
    EM = [EM;Z{k}.Mx(:,1)];
    EV = [EV;Z{k}.Mx(:,2)];
    EK = [EK;Z{k}.Mx(:,3)];
    EC = [EC;reshape(nonzeros(Z{k}.Cx),[],1)];
    EMP = [EMP;reshape(nonzeros(Z{k}.MPx),[],1)];
    EMC = [EMC;reshape(nonzeros(Z{k}.MCx),[],1)];
end


% Corpus-wide z-scoring so every statistic dimension is on a comparable
% scale before distances are computed in RUN_MODEL_V2.
EM = zscore(EM);
EV = zscore(EV);
EK = zscore(EK);
EC = zscore(EC);
EMP = zscore(EMP);
EMC = zscore(EMC);

% Per-interval vector length of each stat type (used to slice the
% pooled/z-scored vectors back out per interval below).
L(1) = length(Z{1}.Mx(:,1));
L(2) = length(Z{1}.Mx(:,2));
L(3) = length(Z{1}.Mx(:,3));
L(4) = length(reshape(nonzeros(Z{k}.Cx),[],1));
L(5) = length(reshape(nonzeros(Z{k}.MPx),[],1));
L(6) = length(reshape(nonzeros(Z{k}.MCx),[],1));


% Write the z-scored statistics back into each interval's struct.
for k = 1:length(Z)
    k
    Z{k}.Mx(:,1) = EM((k-1)*L(1)+1:k*L(1));
    Z{k}.Mx(:,2) = EV((k-1)*L(2)+1:k*L(2));
    Z{k}.Mx(:,3) = EK((k-1)*L(3)+1:k*L(3));
    Z{k}.Cx = EC((k-1)*L(4)+1:k*L(4));
    Z{k}.MPx = EMP((k-1)*L(5)+1:k*L(5));
    Z{k}.MCx = EMC((k-1)*L(6)+1:k*L(6));
end

% Re-chunk back into per-block files of 189 interval-stat structs
% (63 trials x 3 intervals), matching the original 50 stimulus folders,
% for consumption by RUN_MODEL_V2 via observer_model_exp6_v3.
mkdir('_statz_geo2')
for n = 1:50
    clearvars ZZ
    for k = 1:189
        ZZ{k} = Z{(n-1)*189+k};
    end
    save(['_statz_geo2/Z' num2str(n) '.mat'],'ZZ')
end