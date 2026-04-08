function exp1b

%% Analyze data for Experiment 1b
% Loads preprocessed data and plots mean proportion correct (± SEM) across
% stimulus conditions. Also runs repeated-measures ANOVAs and a t-test to
% assess statistical significance within each condition group.
% Mirrors exp1a but uses square markers and a slightly different color scheme,
% reflecting a different stimulus set or recording condition.

%%
load('Exp1b.mat')
% Expected variables in Exp1b.mat:
%   v   - cell array; v{n} is a (conditions x subjects) matrix of proportion correct
%   vm  - cell array; vm{n} is the per-condition mean across subjects for group n
%   xL  - cell array; xL{n} contains the x-axis positions for group n
%   d   - subject data array (used only for computing n = length(d))

%% --- Left subplot: main condition groups ---
figure(1)
c = colororder;
c = c([3:6 2 1],:);        % Select and reorder colors: one per condition group
dx = [0.8 0.9 0.8];       % Dark marker edge color (slightly darker than exp1a)
set(gcf,'position',[100 100 1000 400])

% Left panel occupies 50% of figure width
subplot('position',[0.1 0.1 0.5 0.8])
hold on

% Define x-axis positions for each condition group
xL{1} = 1:5;    % Group 1: 5 conditions
xL{2} = 7:10;   % Group 2: 4 conditions
xL{3} = 12:14;  % Group 3: 3 conditions
xL{4} = 16:17;  % Group 4: 2 conditions
xL{5} = 19;     % Group 5: 1 condition
xL{6} = 21:26;  % Group 6: 6 conditions (plotted separately in right subplot)
% xL{7} = 28:33;
dof = 0.1;   % Offset for group 5 markers (unused placeholder)

% Plot each condition group (groups 1-5; group 6 goes in the right subplot)
for n = 1:length(xL)-1
    % Standard error of the mean across subjects for each condition in group n
    se = std(v{n},[],2)/sqrt(length(d))
    if n < 5
        % Groups 1-4: plot shaded SEM band, mean line, and square markers
        patch([xL{n} fliplr(xL{n})],[vm{n}'+se' fliplr(vm{n}'-se')],c(n,:),'FaceAlpha',0.2,'EdgeAlpha',0)
        plot(xL{n},vm{n},'-','Color',c(n,:),'linewidth',2)
        plot(xL{n},vm{n},'s','MarkerFaceColor',c(n,:),'MarkerEdgeColor',dx,'MarkerSize',10,'linewidth',1.5)
    else
        % Group 5 (single-condition): offset patch right by 0.05-0.25 to avoid overlap
        patch([xL{n}+0.25 fliplr(xL{n})+0.25 fliplr(xL{n})+0.05 xL{n}+0.05],[vm{n}'+se' fliplr(vm{n}'-se') fliplr(vm{n}'-se') vm{n}'+se'],c(n,:),'FaceAlpha',0.2,'EdgeAlpha',0)
        plot(xL{n}+0.125,vm{n},'-','Color',c(n,:),'linewidth',2)
        plot(xL{n}+0.125,vm{n},'s','MarkerFaceColor',c(n,:),'MarkerEdgeColor',dx,'MarkerSize',10,'linewidth',1.5)
    end
end

%% --- Right subplot: exemplar-count group (N = 1, 2, 4, 8, 16, 32) ---
subplot('position',[0.7 0.1 0.2 0.8])
hold on

% Reassign xL{6} to sequential positions 1-6 for the right subplot
xL{6} = 1:6;
se = std(v{6},[],2)/sqrt(length(d));    % SEM for the exemplar-count group

% Plot shaded SEM band, mean line, and square markers (uses color index 6)
patch([xL{6} fliplr(xL{6})],[vm{6}'+se' fliplr(vm{6}'-se')],c(6,:),'FaceAlpha',0.2,'EdgeAlpha',0)
plot(xL{6},vm{6},'-','Color',c(6,:),'linewidth',2)
plot(xL{6},vm{6},'s','MarkerFaceColor',c(6,:),'MarkerEdgeColor',dx,'MarkerSize',10,'linewidth',1.5)

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
