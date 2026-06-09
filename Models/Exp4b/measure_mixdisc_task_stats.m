function measure_mixdisc_task_stats
% measure_mixdisc_task_stats  Computes auditory texture statistics for all
% mix-discrimination task stimuli and saves them to mixdiscstats/.
%
% Reads wav files from mixdiscstim/ (src_disc, mix_disc, and ind_disc
% conditions), extracts subband envelopes via a gammatone filterbank,
% applies a modulation filterbank, and saves the resulting statistics
% struct Y for each stimulus.
%
% Requires AudSys_Setup_halfoctave_fs48k.mat in _system/.
% Output: mixdiscstats/Y_<k>.mat for each stimulus k.

clear all

addpath(genpath('_ltfat'))
addpath(genpath('_minFunc_2012'))
addpath(genpath('_sts'))
mfb_mode = 'halfoctave';
load(['_system/AudSys_Setup_' mfb_mode '_fs48k.mat'])

d = [dir('mixdiscstim/src_disc_1/*.wav');...
     dir('mixdiscstim/src_disc_2/*.wav');...
     dir('mixdiscstim/src_disc_3/*.wav');...
     dir('mixdiscstim/src_disc_4/*.wav');...
     dir('mixdiscstim/src_disc_5/*.wav');...
     dir('mixdiscstim/mix_disc_1/*.wav');...
     dir('mixdiscstim/mix_disc_2/*.wav');...
     dir('mixdiscstim/mix_disc_3/*.wav');...
     dir('mixdiscstim/mix_disc_4/*.wav');...
     dir('mixdiscstim/mix_disc_5/*.wav');...
     dir('mixdiscstim/ind_disc_1/*.wav');...
     dir('mixdiscstim/ind_disc_2/*.wav');...
     dir('mixdiscstim/ind_disc_3/*.wav');...
     dir('mixdiscstim/ind_disc_4/*.wav');...
     dir('mixdiscstim/ind_disc_5/*.wav')];


mkdir('mixdiscstats')
warning off
for kk = 1:length(d)
    disp(kk)
    clearvars y fs Y

    [y fs] = audioread([d(kk).folder '/' d(kk).name]);

    % Extract three 2-second segments: at 0 s, 2.4 s, and 4.8 s offsets
    y1(:, 1) = y(1:2*fs);
    y1(:, 2) = y(2.4*fs+1:4.4*fs);
    y1(:, 3) = y(4.8*fs+1:6.8*fs);
    for n = 1:3
        y_sub = ufilterbank(y1(:, n), g, 1)';
        [dey_sub eyf_sub] = Subband_Envelopes(y_sub, fs, fs_d, compression, 'hilbert', fcc);
        deym_sub = mfilterbank(dey_sub, mfb);

        Y{n} = Meas_SynthStats(dey_sub, deym_sub, mfb_mode);
    end
    save(['mixdiscstats/Y_' num2str(kk) '.mat'], 'Y')

end
