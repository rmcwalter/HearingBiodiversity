function texture_observer_model
% texture_observer_model  Full texture observer model pipeline.
%
% Runs four sequential experiment sections:
%
%   Section 1 - Single-statistic models: for each of five stat types
%     (spec, corr, var, mod_power, atmw) run 100 bootstrap iterations of
%     the observer model, adaptively tuning the internal noise level NP to
%     match the mean human performance.
%
%   Section 2 - Ablation (leave-one-out): run the full model (atmw_v2)
%     100 times with each of the six statistic classes zeroed out in turn.
%
%   Section 3 - All-subsets ablation (kflag=3): run 1000 fixed-NP
%     iterations for each of 63 subsets of the six classes (subsets 1-29
%     in the first loop, 30-63 in the second loop).
%
%   Section 4 - NP calibration: adaptive single-run search for the optimal
%     NP for the full model using 1000 gradient-descent steps.
%
% Requires: mixdiscstats/Y_<k>.mat, N16_online_data.mat

clear all

addpath(genpath('_ltfat'))
addpath(genpath('_minFunc_2012'))
addpath(genpath('_sts'))
mfb_mode = 'halfoctave';
load(['_system/AudSys_Setup_' mfb_mode '.mat'])

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


% -------------------------------------------------------------------------
% Load pre-computed statistics for all stimuli into cell array Z.
% Each stimulus has 3 segments (stored by measure_mixdisc_task_stats).
% Z is indexed as Z{3*(stimulus_index - 1) + segment}, so:
%   Z{1},Z{2},Z{3} = stimulus 1 segments 1-3
%   Z{4},Z{5},Z{6} = stimulus 2 segments 1-3, etc.
% -------------------------------------------------------------------------
clear rsp

for rx = 1
    clearvars -except d rx rsp
    M = [2 3 3];
    N = [1 1 2];
    for m = 1:length(d)
        load(['mixdiscstats/Y_' num2str(m) '.mat'])
        Z{3*(m-1)+1} = Y{1};
        Z{3*(m-1)+2} = Y{2};
        Z{3*(m-1)+3} = Y{3};
    end
end

% -------------------------------------------------------------------------
% Z-score all statistic vectors across the full stimulus set.
% This normalises each statistic class to zero mean and unit variance,
% preventing statistics with larger absolute values from dominating the
% Euclidean distance computation.
%
% The vectors are first concatenated across all stimuli into tall arrays,
% z-scored globally, then written back into Z with the same chunking:
%   Mx(:,1-3): 44 values per stimulus  (one per gammatone channel)
%   Cx:       1936 values (44 x 44 correlation matrix, vectorised)
%   MPx:       836 values (44 channels x 19 mod channels)
%   MCx:      4066 values (non-zero entries of the sparse correlation array)
% -------------------------------------------------------------------------
EM = []; EV = []; EK = []; EC = []; EMP = []; EMC = [];
for k = 1:length(Z)
    k
    EM  = [EM;  Z{k}.Mx(:, 1)];
    EV  = [EV;  Z{k}.Mx(:, 2)];
    EK  = [EK;  Z{k}.Mx(:, 3)];
    EC  = [EC;  reshape(Z{k}.Cx, [], 1)];
    EMP = [EMP; reshape(Z{k}.MPx, [], 1)];
    EMC = [EMC; reshape(nonzeros(Z{k}.MCx), [], 1)];
end

EM  = zscore(EM);  EV  = zscore(EV);  EK  = zscore(EK);
EC  = zscore(EC);  EMP = zscore(EMP); EMC = zscore(EMC);

% Write z-scored values back into Z using fixed chunk sizes per stimulus
for k = 1:length(Z)
    Z{k}.Mx(:, 1) = EM( (k-1)*44+1   : k*44);
    Z{k}.Mx(:, 2) = EV( (k-1)*44+1   : k*44);
    Z{k}.Mx(:, 3) = EK( (k-1)*44+1   : k*44);
    Z{k}.Cx       = EC( (k-1)*1936+1  : k*1936);
    Z{k}.MPx      = EMP((k-1)*836+1   : k*836);
    Z{k}.MCx      = EMC((k-1)*4066+1  : k*4066);
end

%%  Section 1: single-statistic observer models
% Run each model type (and the full ATM) for 100 bootstrap iterations.
% NP is updated each inner iteration with a gradient-sign step: if the
% model over-performs relative to the held-out half of subjects, increase
% NP (more noise → worse performance); if it under-performs, decrease NP.
% The train/test split (r, Lr) changes each outer iteration rx so that
% NP is tuned on one half and evaluated on the other.
clearvars NP_track errX
mt_lab = {'spec_v2','corr_v2','var_v2','mod_power_v2','atmw_v2'};
load('N16_online_data.mat')

for kk = 1:5
    disp(mt_lab{kk})
    mt = mt_lab{kk};
    clearvars -except Z d W NP mt MX_results3 mt_lab

    % Initial NP values hand-tuned to approximately match mean human performance
    if strcmp(mt, 'spec_v2')
        NP = 0.38;  W = [1];
    elseif strcmp(mt, 'corr_v2')
        NP = 0.5;   W = [1];
    elseif strcmp(mt, 'var_v2')
        NP = 0.8;   W = [1];
    elseif strcmp(mt, 'mod_power_v2')
        NP = 0.5;   W = [1];
    elseif strcmp(mt, 'atmw_v2')
        % Weights reflect relative discriminability of each statistic class:
        % [env_mean, env_var, env_skew, env_corr, mod_power, mod_corr]
        NP = 1;     W = [2 0.75 0.5 2 1 0.5];
    end

    % Resume from last saved iteration if a partial run exists
    if exist([mt '.mat'])
        load([mt '.mat'])
        mtL = size(rsp, 1);
    else
        mtL = 1;
    end

    for rx = mtL:100
        disp(rx)

        % Random train/test split across subjects for cross-validated NP tuning
        r  = randperm(size(MX_results3, 1));
        Lr = floor(size(MX_results3, 1) / 2);

        for fn = 1:10   % 10 NP adjustment steps per bootstrap iteration
            pd = noise_and_distance(Z, d, W, NP, mt);
            [rsp_temp, a_out_temp, a_all_temp] = do_trials(pd, d);

            % Gradient-sign step: push NP in the direction that reduces error
            errY = mean(mean(MX_results3(r(1:Lr), :)) - fliplr(rsp_temp));
            if errY > 0
                NP = NP - 0.01;   % model over-performs → add more noise
            else
                NP = NP + 0.01;   % model under-performs → reduce noise
            end
            NP_track(rx, fn) = NP;
            errX(rx, fn) = pdist([mean(MX_results3(r(Lr+1:end), :)); fliplr(rsp_temp)]);
        end
        rsp(rx, :) = rsp_temp;
        a_all{rx}  = a_all_temp;
        a_out{rx}  = a_out_temp;
        save([mt '.mat'], 'NP_track', 'errX', 'rsp', 'a_out', 'a_all')
    end
end

%%  Section 2: leave-one-out ablation (zero each class in turn)
% For each of the 6 statistic classes, set its weight to 0 and run 100
% bootstrap iterations of the full ATM.  Comparing each ablated model
% against the full model reveals which classes drive performance.
clearvars NP_track errX
mt_lab = {'atmw_v2'};
load('N16_online_data.mat')

for kk = 1:6
    disp(mt_lab{1})
    mt = mt_lab{1};

    clearvars -except Z d W NP mt MX_results3 mt_lab kk

    NP = 1;
    W  = [2 0.75 0.5 2 1 0.5];
    W(kk) = 0;   % ablate class kk by zeroing its weight

    for rx = 1:100
        disp(rx)

        r  = randperm(size(MX_results3, 1));
        Lr = floor(size(MX_results3, 1) / 2);
        for fn = 1:10
            pd = noise_and_distance(Z, d, W, NP, mt);
            [rsp_temp, a_out_temp, a_all_temp] = do_trials(pd, d);
            errY = mean(mean(MX_results3(r(1:Lr), :)) - fliplr(rsp_temp));
            if errY > 0
                NP = NP - 0.01;
            else
                NP = NP + 0.01;
            end
            NP_track(rx, fn) = NP;
            errX(rx, fn) = pdist([mean(MX_results3(r(Lr+1:end), :)); fliplr(rsp_temp)]);
        end
        rsp(rx, :) = rsp_temp;
        a_all{rx}  = a_all_temp;
        a_out{rx}  = a_out_temp;
        save([mt '_' num2str(kk) '.mat'], 'NP_track', 'errX', 'rsp', 'a_out', 'a_all')
    end
end

%%  Section 3a: all-subsets ablation, subsets 1-29 (kflag=3, fixed NP)
% Runs 1000 Monte Carlo iterations at a fixed NP (no adaptive tuning) for
% each of the first 29 subsets of {1..6}.  kflag=3 tells noise_and_distance
% to include all classes listed in kk (rather than excluding or isolating).
% NPs = 1.2038 was determined from Section 4 below.
clearvars NP_track errX
mt_lab = {'atmw_v2'};
load('N16_online_data.mat')
kflag = 3;
for kk = 1:7
    disp(mt_lab{1})
    mt = mt_lab{1};
    clearvars -except Z d W NP NPs mt MX_results3 mt_lab kk

    NPs = 1.2038;   % fixed NP calibrated from Section 4
    W   = [2 0.75 0.5 2 1 0.5];

    for rx = 1:1000
        disp(rx)
        NP = NPs;
        for fn = 1
            for sn = 1
                pdX(:, :, sn) = noise_and_distance(Z, d, W, NP, mt, kk, kflag);
            end
            pd = mean(pdX, 3);
            [rsp_temp, a_out_temp, a_all_temp] = do_trials(pd, d);
            errX(rx, fn) = pdist([mean(MX_results3); fliplr(rsp_temp)]);
        end
        rsp(rx, :) = rsp_temp;
        a_all{rx}   = a_all_temp;
        a_out{rx}   = a_out_temp;
    end
    if kflag == 1
        save([mt '_' num2str(kk) 'Y.mat'], 'NP', 'errX', 'rsp', 'a_out', 'a_all')
    elseif kflag == 3
        save([mt '_' num2str(kk) 'X.mat'], 'NP', 'errX', 'rsp', 'a_out', 'a_all')
    else
        save([mt '_' num2str(kk) 'X.mat'], 'NP', 'errX', 'rsp', 'a_out', 'a_all')
    end
end

%%  Section 3b: all-subsets ablation, subsets 1-63
% Build the 63-element lookup table of all non-empty subsets of {1..6}.
% nchoosek generates subsets in size order (size-1 first, size-6 last),
% so kkx(1,:) = [1 0 0 0 0 0] (only class 1) and kkx(63,:) = [1 2 3 4 5 6]
% (all six classes = full model).
kkx = zeros(63, 6);
kk  = 0;
for k = 1:6
    kx = nchoosek(1:6, k);
    ks = size(kx);
    for n = 1:ks(1)
        kk = kk + 1;
        kkx(kk, 1:ks(2)) = kx(n, :);
    end
end

clearvars NP_track errX
mt_lab = {'atmw_v2'};
load('N16_online_data.mat')
kflag = 3;
for kk = 1:63
    disp(mt_lab{1})
    mt = mt_lab{1};
    clearvars -except Z d W NP NPs mt MX_results3 mt_lab kk kkx kflag

    NPs = 1.2038;
    W   = [2 0.75 0.5 2 1 0.5];

    for rx = 1:1000
        disp(rx)
        NP = NPs;
        for fn = 1
            for sn = 1
                % Pass the full subset row kkx(kk,:) to noise_and_distance;
                % kflag=3 means "include all non-zero entries in kkx(kk,:)"
                pdX(:, :, sn) = noise_and_distance(Z, d, W, NP, mt, kkx(kk, :), kflag);
            end
            pd = mean(pdX, 3);
            [rsp_temp, a_out_temp, a_all_temp] = do_trials(pd, d);
            errX(rx, fn) = pdist([mean(MX_results3); fliplr(rsp_temp)]);
        end
        rsp(rx, :) = rsp_temp;
        a_all{rx}   = a_all_temp;
        a_out{rx}   = a_out_temp;
    end
    % Output filename suffix: Y = leave-one-out, Z = all-subsets, X = isolation
    if kflag == 1
        save([mt '_' num2str(kk) 'Y.mat'], 'NP', 'errX', 'rsp', 'a_out', 'a_all')
    elseif kflag == 3
        save([mt '_' num2str(kk) 'Z.mat'], 'NP', 'errX', 'rsp', 'a_out', 'a_all')
    else
        save([mt '_' num2str(kk) 'X.mat'], 'NP', 'errX', 'rsp', 'a_out', 'a_all')
    end
end

%%  Section 4: adaptive NP calibration for the full model
% Performs a 1000-step gradient-sign search to find the NP that makes the
% full ATM match the mean human performance.  Step size NSF shrinks as the
% error decreases (coarse-to-fine schedule), giving fast initial convergence
% followed by fine adjustment.  The converged NPs value is used in Sections
% 3a/3b above.
clearvars NP_track errX
mt_lab = {'atmw_v2'};
load('N16_online_data.mat')

for kk = 1
    disp(mt_lab{1})
    mt = mt_lab{1};
    clearvars -except Z d W NP NPs mt MX_results3 mt_lab kk
    NPs = 0;            % start NP at 0 (no noise) and grow it
    W   = [2 0.75 0.5 2 1 0.5];

    for rx = 1
        NP = NPs;
        for fn = 1:1000

            for sn = 1
                pdX(:, :, sn) = noise_and_distance(Z, d, W, NP(fn), mt, 7);
            end
            pd = mean(pdX, 3);
            [rsp_temp, a_out_temp, a_all_temp] = do_trials(pd, d);
            errY(rx, fn) = mean(mean(MX_results3) - fliplr(rsp_temp));

            % Coarse-to-fine step schedule: shrink NSF as error approaches zero
            if abs(errY(rx, fn)) > 0.01
                NSF = 0.1;
            elseif abs(errY(rx, fn)) > 0.001
                NSF = 0.01;
            elseif abs(errY(rx, fn)) > 0.0001
                NSF = 0.001;
            elseif abs(errY(rx, fn)) > 0.00001
                NSF = 0.0001;
            end

            % Gradient-sign step on NP (scalar optimisation)
            if errY(rx, fn) > 0
                NP(fn+1) = NP(fn) - NSF;   % over-performs → more noise
            else
                NP(fn+1) = NP(fn) + NSF;   % under-performs → less noise
            end

            NP_track(rx, fn) = NP(fn+1)
            errX(rx, fn)     = pdist([mean(MX_results3); fliplr(rsp_temp)])
        end
        NPs        = NP(end);   % save converged NP for use in Section 3
        rsp(rx, :) = rsp_temp;
        a_all{rx}  = a_all_temp;
        a_out{rx}  = a_out_temp;
    end
end
