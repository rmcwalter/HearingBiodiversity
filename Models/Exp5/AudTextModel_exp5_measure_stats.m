function observer_model_v3
% AudTextModel_exp5_measure_stats
% Computes and z-scores auditory texture statistics for all Exp5 stimuli.
%
% Each WAV file contains a 3-interval discrimination trial (7s total):
%   Interval 1: 0   - 2.0 s
%   Interval 2: 2.5 - 4.5 s
%   Interval 3: 5.0 - 7.0 s
%
% Statistics extracted per interval (via Meas_SynthStats):
%   Mx(:,1)  - Envelope mean          (36 subbands)
%   Mx(:,2)  - Envelope coeff. of variation
%   Mx(:,3)  - Envelope skewness
%   Cx       - Envelope correlation    (36x36 = 1296 values)
%   MPx      - Modulation power        (684 values)
%   MCx      - Modulation correlation  (3306 non-zero values)
%
% Two sections below run the same pipeline for:
%   Section 1 - Standard exp5 stimuli     -> _statz/Z<n>.mat
%   Section 2 - Oracle (ideal) stimuli    -> _statzo/Z<n>.mat
%
% Output files (per section):
%   _stats[o]/Z<kk>.mat   - raw stats for each trial file (struct Y{1..3})
%   _stat[z/zo]/Z<n>.mat  - z-scored stats, grouped 1050 trials per subject file

%%  SECTION 1: Standard Exp5 stimuli

clear all

addpath(genpath('../Supporting_files/_ltfat'))
addpath(genpath('../Supporting_files/_minFunc_2012'))
addpath(genpath('../Model_base/_sts'))
mfb_mode = 'halfoctave';
load(['../Model_base/_system/AudSys_Setup_' mfb_mode '.mat'])

% Collect all WAV files for 50 subjects
for k = 1:50
    dt{k} = dir(['/Volumes/SD512/macaulay_orig/McWalter ML Request/exp8/_discrimination_task_8a_S' num2str(k,'%02.f') '/*.wav']);
end

% Concatenate into a single flat list d
for k = 1:50
    if k == 1
        d = dt{k};
    else
        d = [d;dt{k}];
    end
end

% --- Compute raw statistics for every trial file ---
warning off
mkdir('_stats')
for kk = 1:length(d)
    kk
    clearvars y fs Y dey_sub eyf_sub y_sub deym_sub

    [y fs] = audioread([d(kk).folder '/' d(kk).name]);

    % Interval 1: samples 1 to 2s
    y_sub = ufilterbank(y(1:2*fs),g,1)';
    [dey_sub eyf_sub] = Subband_Envelopes(y_sub,fs,fs_d,compression,'hilbert',fcc);
    deym_sub = mfilterbank(dey_sub,mfb);
    Y{1} = Meas_SynthStats(dey_sub,deym_sub,mfb_mode);

    % Interval 2: samples 2.5s to 4.5s (0.5s silence gap between intervals)
    y_sub = ufilterbank(y(2.5*fs+1:4.5*fs),g,1)';
    [dey_sub eyf_sub] = Subband_Envelopes(y_sub,fs,fs_d,compression,'hilbert',fcc);
    deym_sub = mfilterbank(dey_sub,mfb);
    Y{2} = Meas_SynthStats(dey_sub,deym_sub,mfb_mode);

    % Interval 3: samples 5s to 7s
    y_sub = ufilterbank(y(5*fs+1:7*fs),g,1)';
    [dey_sub eyf_sub] = Subband_Envelopes(y_sub,fs,fs_d,compression,'hilbert',fcc);
    deym_sub = mfilterbank(dey_sub,mfb);
    Y{3} = Meas_SynthStats(dey_sub,deym_sub,mfb_mode);

    save(['_stats/Z' num2str(kk) '.mat'],'Y')

end

% --- Reload all raw stats and flatten into single cell array Z ---
% Each trial contributes 3 entries: Z{3*(m-1)+1..3}
clearvars -except d
clear rsp

for rx = 1
    clearvars -except d rx rsp

    M = [2 3 3];
    N = [1 1 2];
    for m = 1:length(d)
        m
        load(['_stats/Z' num2str(m) '.mat'])
        Z{3*(m-1)+1} = Y{1};
        Z{3*(m-1)+2} = Y{2};
        Z{3*(m-1)+3} = Y{3};
    end
end

% --- Z-score each statistic class across all trials ---
% Pooling across all subjects/stimuli before z-scoring ensures a common
% scale for the distance computation in the observer model.
EM = [];
EV = [];
EK = [];
EC = [];
EMP = [];
EMC = [];
for k = 1:length(Z)
    k
    EM  = [EM;Z{k}.Mx(:,1)];          % envelope mean        (36 per interval)
    EV  = [EV;Z{k}.Mx(:,2)];          % envelope CV
    EK  = [EK;Z{k}.Mx(:,3)];          % envelope skewness
    EC  = [EC;reshape(Z{k}.Cx,[],1)]; % envelope correlation (1296 per interval)
    EMP = [EMP;reshape(Z{k}.MPx,[],1)]; % modulation power   (684 per interval)
    EMC = [EMC;reshape(nonzeros(Z{k}.MCx),[],1)]; % modulation correlation (3306 non-zero)
end

EM  = zscore(EM);
EV  = zscore(EV);
EK  = zscore(EK);
EC  = zscore(EC);
EMP = zscore(EMP);
EMC = zscore(EMC);

% Write z-scored values back into each Z entry
for k = 1:length(Z)

    k
    Z{k}.Mx(:,1) = EM((k-1)*36+1:k*36);
    Z{k}.Mx(:,2) = EV((k-1)*36+1:k*36);
    Z{k}.Mx(:,3) = EK((k-1)*36+1:k*36);
    Z{k}.Cx      = EC((k-1)*1296+1:k*1296);
    Z{k}.MPx     = EMP((k-1)*684+1:k*684);
    Z{k}.MCx     = EMC((k-1)*3306+1:k*3306);
end

% --- Save per-subject batches (1050 intervals = 350 trials × 3 intervals) ---
mkdir('_statz')
for n = 1:50
    clearvars ZZ
    for k = 1:1050
        ZZ{k} = Z{(n-1)*1050+k};
    end
    save(['_statz/Z' num2str(n) '.mat'],'ZZ')
end


%%  SECTION 2: Oracle (ideal) stimuli
% Same pipeline as Section 1, but using oracle stimuli where the target
% interval is always perfectly discriminable. Results saved to _statzo/.

clear all

addpath(genpath('_ltfat'))
addpath(genpath('_minFunc_2012'))
addpath(genpath('_sts'))
mfb_mode = 'halfoctave';
AudSys_Setup(mfb_mode);
load(['_system/AudSys_Setup_' mfb_mode '.mat'])

for k = 1:50
    dt{k} = dir(['/Volumes/SD512/macaulay_orig/McWalter ML Request/exp8oracle/_discrimination_task_8a_S' num2str(k,'%02.f') '/*.wav']);
end

for k = 1:50
    if k == 1
        d = dt{k};
    else
        d = [d;dt{k}];
    end
end


warning off
mkdir('_statso')
for kk = 1:length(d)
    kk
    clearvars y fs Y dey_sub eyf_sub y_sub deym_sub

    [y fs] = audioread([d(kk).folder '/' d(kk).name]);

    % Interval 1
    y_sub = ufilterbank(y(1:2*fs),g,1)';
    [dey_sub eyf_sub] = Subband_Envelopes(y_sub,fs,fs_d,compression,'hilbert',fcc);
    deym_sub = mfilterbank(dey_sub,mfb);
    Y{1} = Meas_SynthStats(dey_sub,deym_sub,mfb_mode);

    % Interval 2
    y_sub = ufilterbank(y(2.5*fs+1:4.5*fs),g,1)';
    [dey_sub eyf_sub] = Subband_Envelopes(y_sub,fs,fs_d,compression,'hilbert',fcc);
    deym_sub = mfilterbank(dey_sub,mfb);
    Y{2} = Meas_SynthStats(dey_sub,deym_sub,mfb_mode);

    % Interval 3
    y_sub = ufilterbank(y(5*fs+1:7*fs),g,1)';
    [dey_sub eyf_sub] = Subband_Envelopes(y_sub,fs,fs_d,compression,'hilbert',fcc);
    deym_sub = mfilterbank(dey_sub,mfb);
    Y{3} = Meas_SynthStats(dey_sub,deym_sub,mfb_mode);

    save(['_statso/Z' num2str(kk) '.mat'],'Y')

end

% Reload and flatten into Z
clearvars -except d
clear rsp

for rx = 1
    clearvars -except d rx rsp

    M = [2 3 3];
    N = [1 1 2];
    for m = 1:length(d)
        m
        load(['_statso/Z' num2str(m) '.mat'])
        Z{3*(m-1)+1} = Y{1};
        Z{3*(m-1)+2} = Y{2};
        Z{3*(m-1)+3} = Y{3};
    end
end

% Collect and z-score all statistics
EM = [];
EV = [];
EK = [];
EC = [];
EMP = [];
EMC = [];
for k = 1:length(Z)
    k
    EM  = [EM;Z{k}.Mx(:,1)];
    EV  = [EV;Z{k}.Mx(:,2)];
    EK  = [EK;Z{k}.Mx(:,3)];
    EC  = [EC;reshape(Z{k}.Cx,[],1)];
    EMP = [EMP;reshape(Z{k}.MPx,[],1)];
    EMC = [EMC;reshape(nonzeros(Z{k}.MCx),[],1)];
end

EM  = zscore(EM);
EV  = zscore(EV);
EK  = zscore(EK);
EC  = zscore(EC);
EMP = zscore(EMP);
EMC = zscore(EMC);

% Write z-scored values back into Z
for k = 1:length(Z)

    k
    Z{k}.Mx(:,1) = EM((k-1)*36+1:k*36);
    Z{k}.Mx(:,2) = EV((k-1)*36+1:k*36);
    Z{k}.Mx(:,3) = EK((k-1)*36+1:k*36);
    Z{k}.Cx      = EC((k-1)*1296+1:k*1296);
    Z{k}.MPx     = EMP((k-1)*684+1:k*684);
    Z{k}.MCx     = EMC((k-1)*3306+1:k*3306);
end

% Save per-subject batches
mkdir('_statzo')
for n = 1:50
    clearvars ZZ
    for k = 1:1050
        ZZ{k} = Z{(n-1)*1050+k};
    end
    save(['_statzo/Z' num2str(n) '.mat'],'ZZ')
end
