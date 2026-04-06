function exp1a

%% Analyze data for Experiment 1a
% Loads preprocessed data and plots mean proportion correct (± SEM) across
% stimulus conditions. Also runs repeated-measures ANOVAs and a t-test to
% assess statistical significance within each condition group.
%%
clear all
load('Exp1a.mat')
% Expected variables in Exp1a.mat:
%   v   - cell array; v{n} is a (conditions x subjects) matrix of proportion correct
%   vm  - cell array; vm{n} is the per-condition mean across subjects for group n
%   xL  - cell array; xL{n} contains the x-axis positions for group n
%   d   - subject data array (used only for computing n = length(d))
%   N2  - condition labels displayed below the x-axis

%% --- Left subplot: main condition groups ---
figure(1)
c = colororder;
c = c([3:6 2 2],:);        % Select and reorder colors: one per condition group
dx = [0.95 0.95 0.95];    % Near-white marker edge color
set(gcf,'position',[100 100 1000 400])

% Left panel occupies 50% of figure width
subplot('position',[0.1 0.1 0.5 0.8])
hold on

% Plot each condition group (groups 1-5; group 6 goes in the right subplot)
for n = 1:length(xL)-1
    % Standard error of the mean across subjects for each condition in group n
    se = std(v{n},[],2)/sqrt(length(d));

    if n < 5
        % Groups 1-4: plot shaded SEM band, mean line, and circular markers
        patch([xL{n} fliplr(xL{n})],[vm{n}'+se' fliplr(vm{n}'-se')],c(n,:),'FaceAlpha',0.2,'EdgeAlpha',0)
        plot(xL{n},vm{n},'-','Color',c(n,:),'linewidth',2)
        plot(xL{n},vm{n},'o','MarkerFaceColor',c(n,:),'MarkerEdgeColor',dx,'MarkerSize',10,'linewidth',1.5)
    else
        % Group 5 (single-condition): offset patch left by 0.05–0.25 to avoid overlap
        patch([xL{n}-0.25 fliplr(xL{n})-0.25 fliplr(xL{n})-0.05 xL{n}-0.05],[vm{n}'+se' fliplr(vm{n}'-se') fliplr(vm{n}'-se') vm{n}'+se'],c(n,:),'FaceAlpha',0.2,'EdgeAlpha',0)
        plot(xL{n}-0.125,vm{n},'-','Color',c(n,:),'linewidth',2)
        plot(xL{n}-0.125,vm{n},'o','MarkerFaceColor',c(n,:),'MarkerEdgeColor',dx,'MarkerSize',10,'linewidth',1.5)
    end
end

% x-tick positions corresponding to individual conditions across all groups
xl = [1:5 7:10 12:14 16:17 19];
set(gca,'YLim',[0.15 1.05],'XLim',[0 20],'fontsize',14)
set(gca,'XTick',xl,'XTickLabel',[])   % Suppress default tick labels; use N2 instead
line([0 20],[.33 .33],'color','k','linestyle',':')   % Chance level (1/3 for 3-AFC)

% Display N2 (number of subjects / trials) below each tick mark
% text(-1,0.12,'N1')
text(-1,0.11,'N2','fontsize',14)
for k = 1:length(xl)
%     text(xl(k),0.12,num2str(N1(k)),'HorizontalAlignment','Center')
    text(xl(k),0.11,num2str(N2(k)),'HorizontalAlignment','Center','fontsize',14)
end
% text(23.5,1.1,{'Target different';'species than standard'},'HorizontalAlignment','center')
% text(23.5,1.1,{'Target different';'recording than standard'},'HorizontalAlignment','center')
ylabel('Proportion Correct')
text(19,1,['n = ' num2str(length(d))],'HorizontalAlignment','right','FontSize',16)

%% --- Right subplot: exemplar-count group (N = 1, 2, 4, 8, 16, 32) ---
subplot('position',[0.7 0.1 0.2 0.8])
hold on

% Reassign xL{6} to sequential positions 1-6 for the right subplot
xL{6} = 1:6;
se = std(v{6},[],2)/sqrt(length(d));    % SEM for the exemplar-count group

% Plot shaded SEM band, mean line, and circular markers
patch([xL{6} fliplr(xL{6})],[vm{6}'+se' fliplr(vm{6}'-se')],c(5,:),'FaceAlpha',0.2,'EdgeAlpha',0)
plot(xL{6},vm{6},'-','Color',c(5,:),'linewidth',2)
plot(xL{6},vm{6},'o','MarkerFaceColor',c(5,:),'MarkerEdgeColor',dx,'MarkerSize',10,'linewidth',1.5)

xl = [1:6];
N1 = [1 2 4 8 16 32];   % Number of exemplars per condition (x-axis labels)
N2 = [1 2 4 8 16 32];
set(gca,'YLim',[0.15 1.05],'XLim',[0 7],'fontsize',14)
set(gca,'XTick',xl,'XTickLabel',N1)
line([0 7],[.33 .33],'color','k','linestyle',':')   % Chance level (1/3 for 3-AFC)
% text(-1,0.12,'N1')
% text(-1,0.11,'N2')
% for k = 1:length(xl)
%     text(xl(k),0.12,num2str(N1(k)),'HorizontalAlignment','Center')
    % text(xl(k),0.11,num2str(N2(k)),'HorizontalAlignment','Center')
% end
% text(23.5,1.1,{'Target different';'species than standard'},'HorizontalAlignment','center')
% text(23.5,1.1,{'Target different';'recording than standard'},'HorizontalAlignment','center')
ylabel('Proportion Correct')
text(6,1,['n = ' num2str(length(d))],'HorizontalAlignment','right','FontSize',16)

%% --- Repeated-measures ANOVA: Group 1 (5 conditions) ---
clc
% Test whether proportion correct differs across the 5 conditions in group 1
data = array2table([v{1}'], 'VariableNames', {'C1', 'C2', 'C3', 'C4', 'C5'});
% Create a within-subjects design table indicating the measurements are repeated
withinDesign = table([1 2 3 4 5]', 'VariableNames', {'MixType'});
% Fit the repeated measures model
rmModel = fitrm(data, 'C1-C5~1', 'WithinDesign', withinDesign);
% Perform the repeated measures ANOVA
rmANOVA = ranova(rmModel);
% Display the results
disp(rmANOVA);

%% --- Repeated-measures ANOVA: Group 2 (4 conditions) ---
clc
% Test whether proportion correct differs across the 4 conditions in group 2
data = array2table([v{2}'], 'VariableNames', {'C1', 'C2', 'C3', 'C4'});
% Create a within-subjects design table indicating the measurements are repeated
withinDesign = table([1 2 3 4]', 'VariableNames', {'MixType'});
% Fit the repeated measures model
rmModel = fitrm(data, 'C1-C4~1', 'WithinDesign', withinDesign);
% Perform the repeated measures ANOVA
rmANOVA = ranova(rmModel);
% Display the results
disp(rmANOVA);

%% --- Repeated-measures ANOVA: Group 3 (3 conditions) ---
clc
% Test whether proportion correct differs across the 3 conditions in group 3
data = array2table([v{3}'], 'VariableNames', {'C1', 'C2', 'C3'});
% Create a within-subjects design table indicating the measurements are repeated
withinDesign = table([1 2 3]', 'VariableNames', {'MixType'});
% Fit the repeated measures model
rmModel = fitrm(data, 'C1-C3~1', 'WithinDesign', withinDesign);
% Perform the repeated measures ANOVA
rmANOVA = ranova(rmModel);
% Display the results
disp(rmANOVA);

%% --- Repeated-measures ANOVA: Group 4 (2 conditions) ---
clc
% Test whether proportion correct differs between the 2 conditions in group 4
data = array2table([v{4}'], 'VariableNames', {'C1', 'C2'});
% Create a within-subjects design table indicating the measurements are repeated
withinDesign = table([1 2]', 'VariableNames', {'MixType'});
% Fit the repeated measures model
rmModel = fitrm(data, 'C1-C2~1', 'WithinDesign', withinDesign);
% Perform the repeated measures ANOVA
rmANOVA = ranova(rmModel);
% Display the results
disp(rmANOVA);

%% --- One-sample t-test: Group 5 (single condition) vs. chance (0.5) ---
clc
% Test whether performance in group 5 (single condition) differs from 0.5 chance
[H,P1,CI,STATS1] = ttest(v{5},0.5,'tail','both')

%% --- Repeated-measures ANOVA: Group 6 (exemplar-count, 6 levels) ---
clc
% Test whether proportion correct differs across the 6 exemplar-count levels
data = array2table([v{6}'], 'VariableNames', {'C1', 'C2', 'C3', 'C4', 'C5','C6'});
% Create a within-subjects design table indicating the measurements are repeated
withinDesign = table([1 2 3 4 5 6]', 'VariableNames', {'MixType'});
% Fit the repeated measures model
rmModel = fitrm(data, 'C1-C6~1', 'WithinDesign', withinDesign);
% Perform the repeated measures ANOVA
rmANOVA = ranova(rmModel);
% Display the results
disp(rmANOVA);
