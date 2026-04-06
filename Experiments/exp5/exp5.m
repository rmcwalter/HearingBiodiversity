% Experiment 5: Exemplar discrimination with simultaneous chorus
% Analyses proportion correct across 7 chorus conditions (rows of udsm):
%   Row 1: chorus size 1
%   Row 2: chorus size 8
%   Row 3: chorus size 8+1  (simultaneous, different exemplar)
%   Row 4: chorus size 8+1* (simultaneous, same exemplar)
%   Row 5: chorus size 8+8  (simultaneous, different exemplar)
%   Row 6: chorus size 8+8* (simultaneous, same exemplar)
%   Row 7: chorus size 32
function exp5

%% Load data and compute descriptive statistics

load('Exp5.mat')
% Average across subjects (udsm: conditions x subjects)
if size(udsm,1) == 1
    udm = mean(udsm,1);
else
    udm = mean(udsm,2);
end
% Standard error of the mean across subjects
se = std(udsm,[],2)/sqrt(size(udsm,2));

%% Plot bar chart of mean proportion correct per chorus condition

figure
c = colororder;
hold on

% Decreasing alpha encodes increasing simultaneous-chorus complexity
bar(1:3,udm([1 2 7]),'facecolor',c(1,:));            % pure chorus sizes: 1, 8, 32
bar(5,udm([3]),'facecolor',c(1,:),'facealpha',0.75); % 8+1 (different exemplar)
bar(6,udm([4]),'facecolor',c(1,:),'facealpha',0.5);  % 8+1* (same exemplar)
bar(7,udm([5]),'facecolor',c(1,:),'facealpha',0.5);  % 8+8 (different exemplar)
bar(8,udm([6]),'facecolor',c(1,:),'facealpha',0.25); % 8+8* (same exemplar)
e = errorbar([1:3 5:8],udm([1 2 7 3 4 5 6]),se,'color','k');
e.CapSize = 0;
e.LineWidth = 2;
e.LineStyle = 'none';
% Horizontal dotted reference line at the chorus-size-8 mean
line([2 8.5],[udm(2) udm(2)],'color','k','linestyle',':')
% Chance-level reference line (1/3 for 3-alternative forced choice)
line([0 9],[0.33 0.33],'color','k','linestyle',':','color',[0.6 0.6 0.6],'linewidth',2)
text(8.5,0.35,'chance','color',[0.6 0.6 0.6])
set(gca,'XTick',[1:3 5:8],'XTickLabel',{'1','8','32','8+1','8+1*','8+8','8+8*'})
set(gca,'YLim',[0.3 1])
xlabel('Chorus size')
ylabel('Proportion correct')
title('Exemplar discrimination with simultaneous chorus')
text(8,0.95,['n = ' num2str(size(udsm,2))],'fontsize',12)

%% Repeated-measures ANOVA: pure chorus sizes (1, 8, 32)

% Test whether performance differs across the three unmixed chorus sizes
data = array2table([udsm([1 2 7],:)'], 'VariableNames', {'C1', 'C2', 'C3'});
% Create a within-subjects design table indicating the measurements are repeated
withinDesign = table([1 2 3]', 'VariableNames', {'MixType'});
% Fit the repeated measures model
rmModel = fitrm(data, 'C1-C3~1', 'WithinDesign', withinDesign);
% Perform the repeated measures ANOVA
rmANOVA = ranova(rmModel);
% Display the results
disp(rmANOVA);

%% Post-hoc comparisons: pure chorus sizes (1, 8, 32) — Bonferroni correction

% Pairwise comparisons between chorus sizes 1, 8, and 32
data = array2table([udsm([1 2 7],:)'], 'VariableNames', {'C1', 'C2', 'C3'});
% Create a within-subjects design table indicating the measurements are repeated
withinDesign = table([1 2 3]', 'VariableNames', {'MixType'});
% Fit the repeated measures model
rmModel = fitrm(data, 'C1-C3~1', 'WithinDesign', withinDesign);

tbl = multcompare(rmModel,"MixType",'ComparisonType','bonferroni')

%% Post-hoc comparisons: effect of adding 1 distractor (8, 8+1, 8+1*)

% Test whether adding a simultaneous different or same exemplar to an 8-bird
% chorus affects performance
data = array2table([udsm([2 3 4],:)'], 'VariableNames', {'C1', 'C2', 'C3'});
% Create a within-subjects design table indicating the measurements are repeated
withinDesign = table([1 2 3]', 'VariableNames', {'MixType'});
% Fit the repeated measures model
rmModel = fitrm(data, 'C1-C3~1', 'WithinDesign', withinDesign);

tbl = multcompare(rmModel,"MixType",'ComparisonType','tukey-kramer')

%% Post-hoc comparisons: effect of adding 8 distractors (8, 8+8, 8+8*)

% Test whether adding a simultaneous 8-bird chorus affects performance
data = array2table([udsm([2 5 6],:)'], 'VariableNames', {'C1', 'C2', 'C3'});
% Create a within-subjects design table indicating the measurements are repeated
withinDesign = table([1 2 3]', 'VariableNames', {'MixType'});
% Fit the repeated measures model
rmModel = fitrm(data, 'C1-C3~1', 'WithinDesign', withinDesign);

tbl = multcompare(rmModel,"MixType",'ComparisonType','tukey-kramer')

%% Post-hoc comparisons: all simultaneous-chorus conditions (8+1, 8+1*, 8+8, 8+8*)

% Compare all four conditions in which a simultaneous chorus was added
data = array2table([udsm([3 4 5 6],:)'], 'VariableNames', {'C1', 'C2', 'C3', 'C4'});
% Create a within-subjects design table indicating the measurements are repeated
withinDesign = table([1 2 3 4]', 'VariableNames', {'MixType'});
% Fit the repeated measures model
rmModel = fitrm(data, 'C1-C4~1', 'WithinDesign', withinDesign);

tbl = multcompare(rmModel,"MixType",'ComparisonType','tukey-kramer')

%% Post-hoc comparisons: 8-bird baseline + all simultaneous conditions (8, 8+1, 8+1*, 8+8, 8+8*)

% Pairwise comparisons across five conditions anchored at chorus size 8
data = array2table([udsm(2:6,:)'], 'VariableNames', {'C1', 'C2', 'C3', 'C4', 'C5'});
% Create a within-subjects design table indicating the measurements are repeated
withinDesign = table([1:5]', 'VariableNames', {'MixType'});
% Fit the repeated measures model
rmModel = fitrm(data, 'C1-C5~1', 'WithinDesign', withinDesign);
% rmANOVA = ranova(rmModel)
multcompare(rmModel,"MixType",'ComparisonType','bonferroni')
% [results,~,~,gnames] = multcompare(rmModel,"MixType",'ComparisonType','tukey-kramer')

%% Repeated-measures ANOVA: all 7 conditions

% Omnibus test across all chorus conditions
data = array2table([udsm(:,:)'], 'VariableNames', {'C1', 'C2', 'C3', 'C4','C5','C6','C7'});
% Create a within-subjects design table indicating the measurements are repeated
withinDesign = table([1:7]', 'VariableNames', {'MixType'});
% Fit the repeated measures model
rmModel = fitrm(data, 'C1-C7~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel)
% tbl = multcompare(rmModel,"MixType",'ComparisonType','tukey-kramer')
% multcompare(rmModel,"MixType",'ComparisonType','tukey-kramer')

%% Jackknife (leave-one-out) t-tests: same vs. different exemplar comparisons
% Repeatedly draw leave-one-out subsamples (100 iterations) to assess
% robustness of paired differences: 8+1 vs 8+1* and 8+8 vs 8+8*
for k = 1:100
    I(:,k) = randperm(size(udsm,2));
    % Compare 8+1 (row 3) vs 8+1* (row 4), leaving one subject out each iteration
    [H,P1(k),CI,STATS] = ttest(udsm(3,I(1:end-1,k))',udsm(4,I(1:end-1,k))','tail','both');
    % Compare 8+8 (row 5) vs 8+8* (row 6), leaving one subject out each iteration
    [H,P2(k),CI,STATS] = ttest(udsm(5,I(1:end-1,k))',udsm(6,I(1:end-1,k))','tail','both');
end

%% One-way ANOVA with post-hoc comparisons: 8-bird conditions (8, 8+1, 8+1*, 8+8, 8+8*)

% Between-label ANOVA treating each chorus condition as a group
[~,~,stats] = anova1(udsm(2:6,:)',{'8','8+1','8+1*','8+8','8+8*'});
[results,means,~,gnames] = multcompare(stats);