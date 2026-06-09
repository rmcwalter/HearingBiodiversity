function observer_model_suppinfo_figure4
% observer_model_suppinfo_figure4  Generates supplementary info Figure 4: model ablation study.
%
% Section 1: Loads pre-computed ablation results (model_ablation/atmw_v2_<n>Z.mat)
% for all 63 subsets of the six statistic classes and plots a bar chart of
% mean squared error (MSE) against human data, with confidence intervals.
%
% Section 2: Plots per-condition performance (species / mixture / individual)
% for seven selected models: each of the six isolated statistic classes plus
% the full auditory texture model (all six combined).
%
% Statistics classes:
%   1 - Envelope Mean       4 - Envelope Correlation
%   2 - Envelope Coeff. of Variation   5 - Modulation Power
%   3 - Envelope Skewness   6 - Modulation Correlation
%
% Requires: N16_online_data.mat, model_ablation/atmw_v2_<n>Z.mat

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


%% Load human data and sort by mixture discrimination performance
clearvars -except A B C rsp
load('N16_online_data.mat')

[i, j] = find(~isnan(MXn));
for k = 1:length(i)
    MXn_temp(k) = MXn(i(k), j(k));
    SXn_temp(k) = SXn(i(k), j(k));
    MXn_std_temp(k) = MXn_std(i(k), j(k));
    SXn_std_temp(k) = SXn_std(i(k), j(k));
end

for k = 1:10
    MXi_temp(k) = MX_ind_mean(k, k);
    MXi_std_temp(k) = MX_ind_se(k, k);
end

[~, Ik] = sort(MXn_temp);

%% Build the 63-element lookup table of all non-empty subsets of 6 classes
kkx = zeros(63, 6);
kk = 0;
for k = 1:6
    kx = nchoosek(1:6, k);
    ks = size(kx);
    for n = 1:ks(1)
        kk = kk + 1;
        kkx(kk, 1:ks(2)) = kx(n, :);
    end
end

%% Plot MSE bar chart for all 63 ablation models
for n = 1:63
    AtmRsp = load(['model_ablation/atmw_v2_' num2str(n) 'Z.mat']);
    Atm_err(n) = mean(sum(sqrt([mean(MX_results3)-fliplr(AtmRsp.rsp)].^2), 2));
    Atm_ci(n, :) = prctile(sum(sqrt([mean(MX_results3)-fliplr(AtmRsp.rsp)].^2), 2), [2.5 97.5]);
end
A = Atm_err;

figure
set(gcf, 'position', [200 200 1200 800])
subplot('position', [0.1 0.6 0.8 0.35])
hold on
b = bar(A);
b.EdgeAlpha = 0;
b.FaceColor = [0.5 0.5 0.5];
for k = 1:63
    line([k k], Atm_ci(k, :), 'color', [0.75 0.75 0.75], 'linewidth', 2)
end
set(gca, 'YLim', [0 1])
set(gca, 'XTick', [1:63], 'XTickLabel', [])
set(gca, 'TickDir', 'out')
for k = 1:63
    I = find(kkx(k, :) ~= 0);
    text(k+0.25, -0.05, num2str(kkx(k, I)), 'horizontalalignment', 'right', 'Rotation', 45)
end
ylabel('Mean Squared Error', 'FontSize', 14)
text(52, 0.875, 'Statistics Classes', 'horizontalalignment', 'left', 'fontweight', 'bold')
text(52, 0.8,   '1 - Envelope Mean',              'horizontalalignment', 'left')
text(52, 0.75,  '2 - Envelope Coeff. of Variation','horizontalalignment', 'left')
text(52, 0.7,   '3 - Envelope Skewness',           'horizontalalignment', 'left')
text(52, 0.65,  '4 - Envelope Correlation',        'horizontalalignment', 'left')
text(52, 0.6,   '5 - Modulation Power',            'horizontalalignment', 'left')
text(52, 0.55,  '6 - Modulation Correlation',      'horizontalalignment', 'left')
text(32, -0.2, 'Statistics Class Included in Model', 'horizontalalignment', 'center', 'FontSize', 14)

%% Plot per-condition performance for seven key models
% Models shown: isolated classes 1-6 plus the full model (index 63)
mof = 0.33;
c = colororder;
c(8, :) = [0 0 0];
kk = [2 3 1];
tt = {'Env. Mean','Env. Var.','Env. Skew','Env. Corr.','Mod. Power','Mod. Corr.','Full Model'};
NN = [1 7 14 25 45 61 63];

for n = 1:7
    AtmRsp = load(['model_ablation/atmw_v2_' num2str(NN(n)) 'Z.mat']);
    subplot('position', [0+n*0.115 0.1 0.09 0.3])
    line([0 4], [0.33 0.33], 'linewidth', 2, 'linestyle', '--', 'color', [0.8 0.8 0.8])
    hold on
    bar(1, mean(MX_results3(:, 1)), 'facecolor', c(2, :), 'facealpha', 0.05, 'edgealpha', 0)
    bar(2, mean(MX_results3(:, 2)), 'facecolor', c(3, :), 'facealpha', 0.05, 'edgealpha', 0)
    bar(3, mean(MX_results3(:, 3)), 'facecolor', c(1, :), 'facealpha', 0.05, 'edgealpha', 0)
    se = std(MX_results3)/sqrt(length(MX_results3));
    for k = 1:3
        lh = line([k k], mean(MX_results3(:, k))+[-se(k) se(k)], 'linewidth', 2);
        lh.Color = [c(kk(k), :), 0.25];

        pc = prctile(AtmRsp.rsp(:, 4-k), [2.5 97.5]);
        eb1 = errorbar(k-mof, mean(AtmRsp.rsp(:, 4-k)), mean(AtmRsp.rsp(:, 4-k))-pc(1), pc(2)-mean(AtmRsp.rsp(:, 4-k)));
        eb1.CapSize = 0;
        eb1.LineWidth = 2;
        eb1.Color = c(kk(k), :);
    end
    plot(1-mof, mean(AtmRsp.rsp(:, 3)), 's', 'MarkerFacecolor', c(2,:), 'MarkerEdgeColor', [0.9 0.9 0.9], 'MarkerSize', 12, 'LineWidth', 1.5)
    plot(2-mof, mean(AtmRsp.rsp(:, 2)), 's', 'MarkerFacecolor', c(3,:), 'MarkerEdgeColor', [0.9 0.9 0.9], 'MarkerSize', 12, 'LineWidth', 1.5)
    plot(3-mof, mean(AtmRsp.rsp(:, 1)), 's', 'MarkerFacecolor', c(1,:), 'MarkerEdgeColor', [0.9 0.9 0.9], 'MarkerSize', 12, 'LineWidth', 1.5)

    if n == 1
        set(gca, 'YLim', [0.25 1.05], 'YTick', [0.33 0.5 0.75 1], 'YTickLabel', [0.33 0.5 0.75 1], 'FontSize', 12)
    else
        set(gca, 'YLim', [0.25 1.05], 'YTick', [0.33 0.5 0.75 1], 'YTickLabel', [], 'FontSize', 12)
    end
    set(gca, 'XTick', [1:3], 'XLim', [0 3.75], 'XTickLabel', {'Individiuals','Mixtures','Species'}, 'FontSize', 12)
    set(gca, 'TickDir', 'out')
    if n == 1
        ylabel('Proportion Correct')
    end
    I = find(kkx(NN(n), :) ~= 0);
    title([num2str(kkx(NN(n), I))], 'color', c(8, :))
end
