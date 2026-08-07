function AudTextModel_exp5_measure_stats
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
    dt{k} = dir(['../../Stimuli/exp8/_discrimination_task_8a_S' num2str(k,'%02.f') '/*.wav']);
end

% Concatenate into a single flat list d
for k = 1:50
    if k == 1
        d = dt{k};
    else
        d = [d;dt{k}];
    end
end

save('exp5_stim_name.mat','d')
%%
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

%%  SECTION 2: Oracle (ideal) stimuli
% Same pipeline as Section 1, but using oracle stimuli where the target
% interval is always perfectly discriminable. Results saved to _statzo/.

clear all

addpath(genpath('../Supporting_files/_ltfat'))
addpath(genpath('../Supporting_files/_minFunc_2012'))
addpath(genpath('../Model_base/_sts'))
mfb_mode = 'halfoctave';
load(['../Model_base/_system/AudSys_Setup_' mfb_mode '.mat'])

for k = 1:50
    dt{k} = dir(['../../Stimuli/exp8oracle/_discrimination_task_8a_S' num2str(k,'%02.f') '/*.wav']);
end

for k = 1:50
    if k == 1
        do = dt{k};
    else
        do = [do;dt{k}];
    end
end

save('exp5oracle_stim_name.mat','do')
%%
warning off
mkdir('_statso')
for kk = 1:length(do)
    kk
    clearvars y fs Y dey_sub eyf_sub y_sub deym_sub

    [y fs] = audioread([do(kk).folder '/' do(kk).name]);

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

%%
% Reload and flatten into Z
clear all

load('exp5_stim_name_v2.mat')
load('exp5oracle_stim_name_v2.mat')

for rx = 1
    clearvars -except d do rx rsp

    for m = 1:length(d)
        m
        load(['_stats/Z' num2str(m) '.mat'])
        Z{3*(m-1)+1} = Y{1};
        Z{3*(m-1)+2} = Y{2};
        Z{3*(m-1)+3} = Y{3};
    end
    Z_len = length(Z);
    for m = 1:length(do)
        m
        load(['_statso/Z' num2str(m) '.mat'])
        Z{3*(m-1)+1+Z_len} = Y{1};
        Z{3*(m-1)+2+Z_len} = Y{2};
        Z{3*(m-1)+3+Z_len} = Y{3};
    end
end

%
% Collect and z-score all statistics
EM = zeros(length(Z{1}.Mx(:,1))*length(Z),1);
EV = zeros(length(Z{1}.Mx(:,2))*length(Z),1);
EK = zeros(length(Z{1}.Mx(:,3))*length(Z),1);
EC = zeros(length(reshape(Z{1}.Cx,[],1))*length(Z),1);
EMP = zeros(length(reshape(Z{1}.MPx,[],1))*length(Z),1);
EMC = zeros(length(reshape(nonzeros(Z{1}.MCx),[],1))*length(Z),1);
for k = 1:length(Z)
    k
    EM((k-1)*36+1:k*36)  = [Z{k}.Mx(:,1)];
    EV((k-1)*36+1:k*36)  = [Z{k}.Mx(:,2)];
    EK((k-1)*36+1:k*36)  = [Z{k}.Mx(:,3)];
    EC((k-1)*1296+1:k*1296)  = [reshape(Z{k}.Cx,[],1)];
    EMP((k-1)*684+1:k*684) = [reshape(Z{k}.MPx,[],1)];
    EMC((k-1)*3306+1:k*3306) = [reshape(nonzeros(Z{k}.MCx),[],1)];
end

EM  = zscore(EM);
EV  = zscore(EV);
EK  = zscore(EK);
EC  = zscore(EC);
EMP = zscore(EMP);
EMC = zscore(EMC);

% Save per-subject batches
mkdir('_statz')
mkdir('_statzo')
clearvars Z
for n = 1:100
    clearvars ZZ
    ofs = (n-1)*1050;
    for k = 1:1050
        Z.Mx(:,1) = EM((ofs+k-1)*36+1:(ofs+k)*36);
        Z.Mx(:,2) = EV((ofs+k-1)*36+1:(ofs+k)*36);
        Z.Mx(:,3) = EK((ofs+k-1)*36+1:(ofs+k)*36);
        Z.Cx      = EC((ofs+k-1)*1296+1:(ofs+k)*1296);
        Z.MPx     = EMP((ofs+k-1)*684+1:(ofs+k)*684);
        Z.MCx     = EMC((ofs+k-1)*3306+1:(ofs+k)*3306);
        ZZ{k} = Z;
    end
    if n < 51
        save(['_statz/Z' num2str(n) '.mat'],'ZZ')
    else
        save(['_statzo/Z' num2str(n-50) '.mat'],'ZZ')
    end
end
