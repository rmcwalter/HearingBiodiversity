function fig4e
% fig4e  Scatter plots of acoustic distance vs. behavioural discrimination
%        for six acoustic features (Figure 4e).
%
%        For each feature, pairwise Euclidean distances between bird species
%        are plotted against the proportion-correct discrimination scores
%        obtained from the online listening experiment (N=23 participants).
%        Pearson correlation (R^2, p-value) is annotated on each subplot.
%
%        Acoustic features (derived from the Sound Texture Synthesis framework):
%
%          1. Frequency Spectrum (spec_v2)
%             Mean power in each auditory frequency subband (gammatone filterbank,
%             ERB spacing). Captures the long-term spectral shape —
%             i.e. which frequency regions carry the most energy in each species'
%             song. Corresponds to Mx(:,1) in the STS statistics.
%
%          2. Envelope Coefficient of Variation (var_v2)
%             Variance normalised by the squared mean (var/mean^2) of the Hilbert
%             subband envelope over time, computed per frequency channel.
%             Reflects amplitude modulation depth within each channel — species
%             with more pronounced on/off patterning score higher.
%             Corresponds to Mx(:,2) in the STS statistics.
%
%          3. Envelope Correlation (corr_v2)
%             Pearson correlations between all pairs of subband envelopes.
%             Measures spectro-temporal coherence: how similarly different
%             frequency channels fluctuate together (e.g. broadband vs.
%             narrowband calls). Corresponds to Cx in the STS statistics.
%
%          4. Modulation Power (mod_power_v2)
%             Power in each modulation-frequency band of the modulation
%             filterbank, normalised by the envelope variance of the
%             corresponding subband. Captures temporal rate structure —
%             the dominant rhythmic/AM rate (slow trills vs. fast calls).
%             Corresponds to MPx in the STS statistics.
%
%          5. Loudness (loudness_v2)
%             Overall perceived loudness computed using the model of
%             Chalupper & Fastl (2002), which applies auditory filtering and
%             specific loudness integration to give a time-varying loudness
%             in sones. A coarse measure of signal level independent of
%             spectral shape.
%
%          6. Pitch (yin_v2)
%             Fundamental frequency (F0) estimated using the YIN software
%             package (de Cheveigné & Kawahara, 2002). YIN finds the lag
%             that minimises the autocorrelation difference function to give
%             a robust F0 estimate. Distinguishes tonal/harmonic species
%             (e.g. Song Thrush) from noisy/broadband singers (e.g. Crow).

%%
clear all
load('Exp4b.mat')   % loads MXn, SXn, MXn_std, SXn_std, MX_ind_mean, MX_ind_se

% Find all valid (non-NaN) species pairs in the behavioural data matrix
[i,j] = find(~isnan(MXn));

% Extract the valid entries into flat vectors for later sorting
for k = 1:length(i)
    % Mixture condition
    MXn_temp(k)     = MXn(i(k),j(k));       % mean proportion correct
    MXn_std_temp(k) = MXn_std(i(k),j(k));   % std of proportion correct

    % Different Species condition
    SXn_temp(k)     = SXn(i(k),j(k));       % mean proportion correct
    SXn_std_temp(k) = SXn_std(i(k),j(k));   % std of proportion correct

    % Same Species condition
    MXi_temp(k)     = MX_ind_mean(i(k),j(k)); % mean proportion correct
    MXi_std_temp(k) = MX_ind_se(i(k),j(k));   % std of proportion correct
end

% Sort pairs by mean proportion correct (ascending) — used for colouring
[~,Ik] = sort(MXn_temp);

%%

% Names of the acoustic feature distance files (each _dist.mat holds matrix B:
% a flat vector of pairwise species distances for that feature).
%   spec_v2       — frequency spectrum    (mean subband envelope power, Mx(:,1))
%   var_v2        — envelope CoV          (subband envelope variance/mean^2, Mx(:,2))
%   corr_v2       — envelope correlation  (inter-subband envelope correlations, Cx)
%   mod_power_v2  — modulation power      (AM rate power per subband, MPx)
%   loudness_v2   — loudness              (Chalupper & Fastl 2002 loudness model, sones)
%   yin_v2        — pitch                 (YIN software package, de Cheveigné & Kawahara 2002)
Nx = {'spec_v2','var_v2','corr_v2','mod_power_v2','loudness_v2','yin_v2'};

% Subplot titles corresponding to each feature (displayed above each panel)
tl = {[{'Frequency Spectrum'}],...
    [{'Env. Coeff. of Var.'}],...
    [{'Env. Correlation'}],...
    [{'Modulation Power'}],...
    [{'Loudness'}],...
    [{'Pitch'}]};

for N = 1:4%length(Nx)
    % Reset temporary variables, keeping only shared data needed across iterations
    clearvars -except Nx MXn SXn MXn_std SXn_std MX_results3 N tl
    [i,j] = find(~isnan(MXn));   % re-identify valid pairs after clearvars

    % Load pairwise acoustic distances for this feature.
    % Each *_dist.mat contains B: a flat vector of Euclidean distances between
    % species pairs, computed from z-scored STS statistics (see measure_bird_stats.m).
    load(['dist3/' Nx{N} '_dist.mat']);
    pdX_temp = B;   % flat vector of pairwise distances for this feature

    % Extract behavioural scores for the same valid pairs
    for k = 1:length(i)
        MXn_temp(k)     = MXn(i(k),j(k));
        SXn_temp(k)     = SXn(i(k),j(k));
        MXn_std_temp(k) = MXn_std(i(k),j(k));
        SXn_std_temp(k) = SXn_std(i(k),j(k));
        % pdX_temp(k) = pdX(i(k),j(k),:);
    end

    % Sort indices by behavioural score and by acoustic distance
    [~,Ik]  = sort(MXn_temp);   % ascending proportion correct
    [~,Ik2] = sort(pdX_temp);   % ascending acoustic distance

    % Species labels (not currently plotted, kept for reference)
    sl = {'Crow','Chaffinch','Chiffchaff','Firecrest','Dunnock','Eur. Blackbird',...
        'Eur. Bluetit','Eur. Jay','Song Thrush','Willow Warbler'};

    % Build two colourmaps (45 steps each) from white to the 3rd/1st default colours
    % Marker colour encodes proportion correct (low=pale, high=saturated)
    c = colororder;
    cmap  = [linspace(1,c(3,1),45)' linspace(1,c(3,2),45)' linspace(1,c(3,3),45)'];
    cmap2 = [linspace(1,c(1,1),45)' linspace(1,c(1,2),45)' linspace(1,c(1,3),45)'];
    % figure
    % set(gcf,'position',[200 200 300 300])

    % Normalize acoustic distances to [0, 1] for cross-feature comparability
    pdX_temp = pdX_temp - min(pdX_temp);
    pdX_temp = pdX_temp / max(pdX_temp);

    % --- Subplot layout ---
    % Odd-numbered features go in the left column; even in the right column
    figure(2)
    set(gcf,'position',[200 200 400 800])
    if sum(N == [1 3 5 7])
        subplot('position',[0.2 0.9-(N)*0.11 0.35 0.175])
    else
        subplot('position',[0.6 0.9-(N-1)*0.11 0.35 0.175])
    end
    hold on

    % Plot each pair as a circle; colour encodes proportion correct
    for k = 1:size(cmap,1)
        plot(pdX_temp(Ik2(k)), MXn_temp(Ik2(k)), 'o', ...
            'MarkerFaceColor', cmap(round(MXn_temp(Ik2(k))*45), :), ...
            'MarkerEdgeColor', [0.9 0.9 0.9], 'MarkerSize', 8, 'LineWidth', 1)
    end
    set(gca,'XLim',[-0.05 1.05],'XTick',[0:0.25:1])

    % Axis formatting: left column gets Y tick labels; bottom-left gets X label
    if N == 1
        set(gca,'YLim',[0.3 1.0333],'YTick',[0.33 .5:.25:1],'YTickLabel',[0.33 .5:.25:1],'fontsize',10)
        set(gca,'XTick',[0:0.25:1],'XTickLabel',[])
        ylabel('Proportion Correct','fontsize',12)
    elseif N == 3
        set(gca,'YLim',[0.3 1.0333],'YTick',[0.33 .5:.25:1],'YTickLabel',[0.33 .5:.25:1],'fontsize',10)
        set(gca,'XTick',[0:0.25:1],'XTickLabel',[])
    elseif N == 5   % bottom of left column — add X axis label
        set(gca,'YLim',[0.3 1.0333],'YTick',[0.33 .5:.25:1],'YTickLabel',[0.33 .5:.25:1],'fontsize',10)
        xlabel('Normalized Euclidean Distance','fontsize',12)
    elseif N == 6   % bottom of right column — no Y tick labels
        set(gca,'YLim',[0.3 1.0333],'YTick',[0.33 .5:.25:1],'YTickLabel',[],'fontsize',10)
    else            % remaining right-column subplots — no labels on either axis
        set(gca,'YLim',[0.3 1.0333],'YTick',[0.33 .5:.25:1],'YTickLabel',[],'fontsize',10)
        set(gca,'XTick',[0:0.25:1],'XTickLabel',[])
    end
    set(gca,'TickDir','out');
    title(tl{N},'fontsize',12)

    % Compute Pearson correlation between normalized distance and proportion correct
    [cc p] = corrcoef(pdX_temp, MXn_temp);
    [cc(2) p(2)]   % display to command window for inspection

    % Annotate subplot with R^2 and p-value
    if p(2) < 0.001
        text(0.975,0.425,[{['R^2 = ' num2str(cc(2)^2,'%1.2f')]};{'p < 0.001'}],'fontsize',10,'HorizontalAlignment','right')
    else
        text(0.975,0.425,[{['R^2 = ' num2str(cc(2)^2,'%1.2f')]};{['p = ' num2str(p(2),'%1.3f')]}],'fontsize',10,'HorizontalAlignment','right')
    end

    % Reference lines: diagonal (chance-to-perfect), horizontal chance (1/3), vertical origin
    lh = line([0 1],[0.33 1],'color',[0.8 0.8 0.8],'linestyle','--','linewidth',1.25);
    lh.Color = [0.8,0.8,0.8,0.2];
    lh = line([0 0.75],[1 1]./3,'color',[0.8 0.8 0.8],'linestyle','--','linewidth',1.25);
    lh.Color = [0.8,0.8,0.8,0.2];
    lh = line([0 0],[0.33 1.05],'color',[0.8 0.8 0.8],'linestyle','--','linewidth',1.25);
    lh.Color = [0.8,0.8,0.8,0.2];

    % saveas(gcf,['scatterplot_' num2str(Nx) '.pdf'])
    % close all

end

