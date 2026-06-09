function observer_model_figure5d
% observer_model_figure5d  Generates Figure 5d: scatter plots of model
% vs human proportion correct for seven models across three conditions.
%
% For each of seven models (full auditory texture + six individual statistic
% classes), the script reconstructs per-pair model accuracy from saved
% results, then plots model performance against human performance as scatter
% plots, reporting R^2 and p-values for each model.
%
% Conditions:
%   Species discrimination  (A) - 10x10 source pairs
%   Mixture discrimination  (B) - 10x18 mix pairs
%   Individual discrimination (C) - 10 diagonal pairs
%
% Requires: N16_online_data.mat, model_original/*.mat

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


%% Per-model scatter plots (combined across conditions)
for mk = 1:7
    if mk == 1
        load('model_original/atmw_v2.mat')
        mkr_style = 'square';
    elseif mk == 2
        load('model_original/spec_v2.mat')
        mkr_style = '<';
    elseif mk == 3
        load('model_original/var_v2.mat')
        mkr_style = 'v';
    elseif mk == 4
        load('model_original/corr_v2.mat')
        mkr_style = '>';
    elseif mk == 5
        load('model_original/mod_power_v2.mat')
        mkr_style = '^';
    elseif mk == 6
        load('model_original/loudness.mat')
        mkr_style = 'o';
    elseif mk == 7
        load('model_original/yin.mat')
        mkr_style = 'diamond';
    end

    % Reconstruct species-discrimination accuracy matrix A (10x10 pairs)
    A_out = zeros(10, 10, length(a_out));
    for nk = 1:length(a_out)
        A = zeros(10, 10, 5);
        for n = 1:5
            kk = 0;
            Ax = a_all{nk}{1}((n-1)*90+1:n*90);
            for k = 1:10
                for j = 1:10
                    if j ~= k
                        kk = kk + 1;
                        A(k, j, n) = Ax(kk);
                    end
                end
            end
        end
        A_out(:, :, nk) = mean(A, 3);
    end
    A = mean(A_out, 3);
    A = (tril(A)' + triu(A)) / 2;
    A = nonzeros(A);

    % Reconstruct mixture-discrimination accuracy matrix B (10x10 pairs)
    B_out = zeros(10, 10, length(a_out));
    for nk = 1:length(a_out)
        By = zeros(10, 10, 5);
        for n = 1:5
            B = zeros(10, 20);
            kk = 0;
            Bx = a_all{nk}{2}((n-1)*180+1:n*180);
            for k = 1:10
                for j = 1:18
                    kk = kk + 1;
                    kx = str2num(d(450+kk).name(6:7));
                    jx = str2num(d(450+kk).name(12:13));
                    B(kx, jx) = Bx(kk);
                end
            end
            By(:, :, n) = (B(:, 1:10) + B(:, 11:20)) / 2;
        end
        B_out(:, :, nk) = mean(By, 3);
    end
    B = mean(B_out, 3);
    B = (tril(B)' + triu(B)) / 2;
    B = nonzeros(B);

    % Reconstruct individual-discrimination accuracy vector C (10 diagonals)
    C_out = zeros(10, length(a_out));
    for nk = 1:length(a_out)
        C = zeros(3, 10, 5);
        for n = 1:5
            Cx = a_all{nk}{3}((n-1)*30+1:n*30);
            for k = 1:length(Cx)
                kk = mod(k-1, 3) + 1;
                nn = floor((k-1)/3) + 1;
                C(kk, nn, n) = Cx(k);
            end
        end
        C_out(:, nk) = mean(mean(C, 1), 3);
    end
    C = mean(C_out, 2);

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

    % Compute correlations per condition and pooled
    [c1, p1] = corrcoef(A, SXn_temp);  c1 = c1(2); p1 = p1(2);
    [c2, p2] = corrcoef(B, MXn_temp);  c2 = c2(2); p2 = p2(2);
    [c3, p3] = corrcoef(C', MXi_temp); c3 = c3(2); p3 = p3(2);
    ABC = [A' B' C'];
    SMM = [SXn_temp MXn_temp MXi_temp];
    [c4, p4] = corrcoef(ABC, SMM);
    c4 = c4(2); p4 = p4(2);

    figure(1)
    set(gcf, 'position', [200 200 400 800])
    c = colororder;
    if sum(mk == [1 3 5 7])
        subplot('position', [0.2 0.9-(mk)*0.11 0.35 0.175])
    else
        subplot('position', [0.6 0.9-(mk-1)*0.11 0.35 0.175])
    end
    hold on
    lh = line([0 1], [0 1], 'color', [0.8 0.8 0.8], 'linestyle', '--', 'linewidth', 1.25);
    lh.Color = [0.8, 0.8, 0.8, 0.2];
    lh = line([0 0.75], [1 1]./3, 'color', [0.8 0.8 0.8], 'linestyle', '--', 'linewidth', 1.25);
    lh.Color = [0.8, 0.8, 0.8, 0.2];
    lh = line([1 1]./3, [0 1.05], 'color', [0.8 0.8 0.8], 'linestyle', '--', 'linewidth', 1.25);
    lh.Color = [0.8, 0.8, 0.8, 0.2];

    scatter(A, SXn_temp, 100, 'filled', mkr_style, 'MarkerEdgeColor', [0.9 0.9 0.9], 'MarkerFaceColor', c(1,:), 'LineWidth', 1.5, 'MarkerFaceAlpha', 0.5)
    scatter(B, MXn_temp, 100, 'filled', mkr_style, 'MarkerEdgeColor', [0.9 0.9 0.9], 'MarkerFaceColor', c(3,:), 'LineWidth', 1.5, 'MarkerFaceAlpha', 0.5)
    scatter(C, MXi_temp, 100, 'filled', mkr_style, 'MarkerEdgeColor', [0.9 0.9 0.9], 'MarkerFaceColor', c(2,:), 'LineWidth', 1.5, 'MarkerFaceAlpha', 0.5)

    if sum(mk == [1 3 5 7])
        set(gca, 'YLim', [0.25 1.05], 'YTick', [0.33 0.5:0.25:1], 'fontsize', 12)
        if mk == 1
            ylabel([{'Human'}; {'Proportion Correct'}], 'FontSize', 14)
        end
    else
        set(gca, 'YLim', [0.25 1.05], 'YTick', [0.33 0.5:0.25:1], 'YTickLabel', [], 'fontsize', 12)
    end
    if sum(mk == [7 6])
        set(gca, 'XLim', [0.25 1.05], 'XTick', [0.33 0.5:0.25:1], 'fontsize', 12)
        if mk == 7
            xlabel([{'Model - Proportion Correct'}], 'FontSize', 14)
        end
    else
        set(gca, 'XLim', [0.25 1.05], 'XTick', [0.25:0.25:1], 'XTickLabel', [], 'fontsize', 12)
    end
    set(gca, 'TickDir', 'out');
    text(0.8, 0.375, ['R^2 = ' num2str(c4.^2, '%1.2f')])
    if p4 < 0.001
        text(0.8, 0.3, ['p < 0.001'])
    else
        text(0.8, 0.3, ['p = ' num2str(p4, '%1.2f')])
    end
    c(8, :) = [0 0 0];
    model_names = {'Auditory Texture','Frequency Spectrum','Env. Coeff. of Var.',...
                   'Env. Correlation','Modulation Power','Loudness','Pitch'};
    title(model_names{mk}, 'color', c(8, :))
end


%% Per-condition scatter plots (species / mixture / individual separately)
for mk = 1:7
    if mk == 1
        load('model_original/atmw_v2.mat')
        mkr_style = 'square';
    elseif mk == 2
        load('model_original/spec_v2.mat')
        mkr_style = '<';
    elseif mk == 3
        load('model_original/var_v2.mat')
        mkr_style = 'v';
    elseif mk == 4
        load('model_original/corr_v2.mat')
        mkr_style = '>';
    elseif mk == 5
        load('model_original/mod_power_v2.mat')
        mkr_style = '^';
    elseif mk == 6
        load('model_original/loudness.mat')
        mkr_style = 'o';
    elseif mk == 7
        load('model_original/yin.mat')
        mkr_style = 'diamond';
    end

    clearvars -except d rsp a_out a_all mk mkr_style

    % Reconstruct A, B, C (same logic as above)
    A_out = zeros(10, 10, length(a_out));
    for nk = 1:length(a_out)
        A = zeros(10, 10, 5);
        for n = 1:5
            kk = 0;
            Ax = a_all{nk}{1}((n-1)*90+1:n*90);
            for k = 1:10
                for j = 1:10
                    if j ~= k
                        kk = kk + 1;
                        A(k, j, n) = Ax(kk);
                    end
                end
            end
        end
        A_out(:, :, nk) = mean(A, 3);
    end
    A = mean(A_out, 3);
    A = (tril(A)' + triu(A)) / 2;
    A = nonzeros(A);

    B_out = zeros(10, 10, length(a_out));
    for nk = 1:length(a_out)
        By = zeros(10, 10, 5);
        for n = 1:5
            B = zeros(10, 20);
            kk = 0;
            Bx = a_all{nk}{2}((n-1)*180+1:n*180);
            for k = 1:10
                for j = 1:18
                    kk = kk + 1;
                    kx = str2num(d(450+kk).name(6:7));
                    jx = str2num(d(450+kk).name(12:13));
                    B(kx, jx) = Bx(kk);
                end
            end
            By(:, :, n) = (B(:, 1:10) + B(:, 11:20)) / 2;
        end
        B_out(:, :, nk) = mean(By, 3);
    end
    B = mean(B_out, 3);
    B = (tril(B)' + triu(B)) / 2;
    B = nonzeros(B);

    C_out = zeros(10, length(a_out));
    for nk = 1:length(a_out)
        C = zeros(3, 10, 5);
        for n = 1:5
            Cx = a_all{nk}{3}((n-1)*30+1:n*30);
            for k = 1:length(Cx)
                kk = mod(k-1, 3) + 1;
                nn = floor((k-1)/3) + 1;
                C(kk, nn, n) = Cx(k);
            end
        end
        C_out(:, nk) = mean(mean(C, 1), 3);
    end
    C = mean(C_out, 2);

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

    [c1, p1] = corrcoef(A, SXn_temp);  c1 = c1(2); p1 = p1(2);
    [c2, p2] = corrcoef(B, MXn_temp);  c2 = c2(2); p2 = p2(2);
    [c3, p3] = corrcoef(C', MXi_temp); c3 = c3(2); p3 = p3(2);

    c = colororder;
    figure(1)
    set(gcf, 'position', [200 200 600 900])
    hold on

    % Species column
    subplot('position', [0.2 0.975-(mk)*0.13 0.2 0.125])
    hold on
    lh = line([0 1], [0 1], 'color', [0.8 0.8 0.8], 'linestyle', '--', 'linewidth', 1.25);
    lh.Color = [0.8, 0.8, 0.8, 0.2];
    lh = line([0 0.75], [1 1]./3, 'color', [0.8 0.8 0.8], 'linestyle', '--', 'linewidth', 1.25);
    lh.Color = [0.8, 0.8, 0.8, 0.2];
    lh = line([1 1]./3, [0 1.05], 'color', [0.8 0.8 0.8], 'linestyle', '--', 'linewidth', 1.25);
    lh.Color = [0.8, 0.8, 0.8, 0.2];
    scatter(A, SXn_temp, 100, 'filled', mkr_style, 'MarkerEdgeColor', [0.9 0.9 0.9], 'MarkerFaceColor', c(1,:), 'LineWidth', 1.5, 'MarkerFaceAlpha', 0.5)
    set(gca, 'XLim', [0.25 1.05], 'XTick', [0.33 0.5:0.25:1], 'XTickLabel', [], 'fontsize', 12)
    set(gca, 'TickDir', 'out');
    text(1, 0.375, ['R^2 = ' num2str(c1.^2, '%1.2f')], 'horizontalalignment', 'right')
    if mk == 4
        ylabel([{'Human - Proportion Correct'}], 'FontSize', 14)
        set(gca, 'YLim', [0.25 1.05], 'YTick', [0.33 0.5:0.25:1], 'fontsize', 12)
    else
        set(gca, 'YLim', [0.25 1.05], 'YTick', [0.33 0.5:0.25:1], 'YTickLabel', [], 'fontsize', 12)
    end
    if p1 < 0.001
        text(1, 0.3, ['p < 0.001'], 'horizontalalignment', 'right')
    else
        text(1, 0.3, ['p = ' num2str(p1, '%1.2f')], 'horizontalalignment', 'right')
    end
    if mk == 1
        title([{'Species'}], 'Color', c(1,:), 'FontSize', 14)
    end

    % Mixture column
    subplot('position', [0.42 0.975-(mk)*0.13 0.2 0.125])
    hold on
    lh = line([0 1], [0 1], 'color', [0.8 0.8 0.8], 'linestyle', '--', 'linewidth', 1.25);
    lh.Color = [0.8, 0.8, 0.8, 0.2];
    lh = line([0 0.75], [1 1]./3, 'color', [0.8 0.8 0.8], 'linestyle', '--', 'linewidth', 1.25);
    lh.Color = [0.8, 0.8, 0.8, 0.2];
    lh = line([1 1]./3, [0 1.05], 'color', [0.8 0.8 0.8], 'linestyle', '--', 'linewidth', 1.25);
    lh.Color = [0.8, 0.8, 0.8, 0.2];
    scatter(B, MXn_temp, 100, 'filled', mkr_style, 'MarkerEdgeColor', [0.9 0.9 0.9], 'MarkerFaceColor', c(3,:), 'LineWidth', 1.5, 'MarkerFaceAlpha', 0.5)
    set(gca, 'YLim', [0.25 1.05], 'YTick', [0.33 0.5:0.25:1], 'YTickLabel', [], 'fontsize', 12)
    if mk == 7
        xlabel([{'Model - Proportion Correct'}], 'FontSize', 14)
        set(gca, 'XLim', [0.25 1.05], 'XTick', [0.33 0.5:0.25:1], 'fontsize', 12)
    else
        set(gca, 'XLim', [0.25 1.05], 'XTick', [0.33 0.5:0.25:1], 'XTickLabel', [], 'fontsize', 12)
    end
    set(gca, 'TickDir', 'out');
    text(1, 0.375, ['R^2 = ' num2str(c2.^2, '%1.2f')], 'horizontalalignment', 'right')
    if p2 < 0.001
        text(1, 0.3, ['p < 0.001'], 'horizontalalignment', 'right')
    else
        text(1, 0.3, ['p = ' num2str(p2, '%1.2f')], 'horizontalalignment', 'right')
    end
    if mk == 1
        title([{'Mixture'}], 'Color', c(3,:), 'FontSize', 14)
    end

    % Individual column
    subplot('position', [0.64 0.975-(mk)*0.13 0.2 0.125])
    hold on
    lh = line([0 1], [0 1], 'color', [0.8 0.8 0.8], 'linestyle', '--', 'linewidth', 1.25);
    lh.Color = [0.8, 0.8, 0.8, 0.2];
    lh = line([0 0.75], [1 1]./3, 'color', [0.8 0.8 0.8], 'linestyle', '--', 'linewidth', 1.25);
    lh.Color = [0.8, 0.8, 0.8, 0.2];
    lh = line([1 1]./3, [0 1.05], 'color', [0.8 0.8 0.8], 'linestyle', '--', 'linewidth', 1.25);
    lh.Color = [0.8, 0.8, 0.8, 0.2];
    scatter(C, MXi_temp, 100, 'filled', mkr_style, 'MarkerEdgeColor', [0.9 0.9 0.9], 'MarkerFaceColor', c(2,:), 'LineWidth', 1.5, 'MarkerFaceAlpha', 0.5)
    set(gca, 'XLim', [0.25 1.05], 'XTick', [0.33 0.5:0.25:1], 'XTickLabel', [], 'fontsize', 12)
    set(gca, 'YLim', [0.25 1.05], 'YTick', [0.33 0.5:0.25:1], 'YTickLabel', [], 'fontsize', 12)
    set(gca, 'TickDir', 'out');
    text(1, 0.375, ['R^2 = ' num2str(c3.^2, '%1.2f')], 'horizontalalignment', 'right')
    text(1, 0.3, ['p = ' num2str(p3, '%1.2f')], 'horizontalalignment', 'right')
    if mk == 1
        title([{'Individuals'}], 'Color', c(2,:), 'FontSize', 14)
    end
    c(8, :) = [0 0 0];
    model_labels = {{'Auditory','Texture'}, {'Frequency','Spectrum'}, ...
                    {'Envelope','Coeff. of Var.'}, {'Envelope','Correlation'}, ...
                    {'Modulation','Power'}, {'Loudness'}, {'Pitch'}};
    text(1.3, 0.625, model_labels{mk}, 'HorizontalAlignment', 'center', ...
         'VerticalAlignment', 'middle', 'color', c(8,:), 'FontSize', 12)
end
