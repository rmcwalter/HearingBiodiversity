function prolific_spemix_data_analysis_v4
% EXP6B  Exemplar discrimination with biophony background (Experiment 6b).
%   Loads subject data, plots mean proportion correct across chorus sizes
%   (isolated and mixed with biophony background), and runs repeated
%   measures ANOVAs to test the effect of chorus size.
%
%   Data variables loaded from Exp6b.mat:
%     MX_iso  - subjects x chorus sizes (1,8,32), isolated (no background)
%     MX_mix  - subjects x chorus sizes (1,8,32), mixed with biophony
%     MX_bg   - 1 x subjects, background-only condition

%%  --- Load data and compute summary statistics ---

clear all
load('Exp6b.mat')

% Stack conditions: rows = [iso@C1, iso@C8, iso@C32, mix@C1, mix@C8, mix@C32, bg-only]
% Each column is one subject
udsm = [MX_iso';MX_mix';MX_bg];
udm = mean(udsm,2);                          % condition means (across subjects)
se  = std(udsm,[],2)/sqrt(size(udsm,2));     % standard error


%%  --- Bar chart of proportion correct ---

figure
c = colororder;
hold on

% Isolated-chorus bars (positions 1-3)
bar(1:3,udm([1:3]),'facecolor',c(1,:));

% Mixed-with-background bars (positions 5-7 = semi-transparent; 8 = bg-only, opaque)
bar(5,udm([4]),'facecolor',c(2,:),'facealpha',0.5);
bar(6,udm([5]),'facecolor',c(2,:),'facealpha',0.5);
bar(7,udm([6]),'facecolor',c(2,:),'facealpha',0.5);
bar(8,udm([7]),'facecolor',c(2,:),'facealpha',1);   % background-only condition

% Error bars (standard error, no caps)
e = errorbar([1:3 5:8],udm,se,'color','k');
e.CapSize = 0;
e.LineWidth = 2;
e.LineStyle = 'none';

% Dotted reference line at iso chorus-size-8 performance
line([2 8.5],[udm(2) udm(2)],'color','k','linestyle',':')

% Dashed chance line (1/3 for 3-AFC)
line([-0.2 9.2],[0.33 0.33],'color','k','linestyle','-.','color',[0.6 0.6 0.6],'linewidth',2)
text(8.5,0.35,'chance','color',[0.6 0.6 0.6])

set(gca,'XTick',[1:3 5:8],'XTickLabel',{'1','8','32','1+bg','8+bg','32+bg','bg'},'fontsize',14)
set(gca,'YLim',[0.3 1])
xlabel('Chorus size')
ylabel('Proportion correct','FontSize',16)
title('Exemplar discrimination with biophony background','fontsize',16)
text(8,0.95,['n = ' num2str(size(udsm,2))],'fontsize',14)
set(gca,'TickDir','out');


%%  --- Exploratory one-way ANOVA (isolated condition) ---

clc
% One-way ANOVA across chorus sizes for isolated stimuli
% anova(MX_iso)
% anova(MX_mix)   % (commented out: same test for mixed condition)

% Paired t-tests between mixed and isolated at each chorus size (unused):
[H,P1,CI,STATS] = ttest(MX_mix(:,1),MX_iso(:,1),'tail','both');
[H,P2,CI,STATS] = ttest(MX_mix(:,2),MX_iso(:,2),'tail','both');
[H,P3,CI,STATS] = ttest(MX_mix(:,3),MX_iso(:,3),'tail','both');
% [P16 P2 P3]

% anova([MX_mix(:,3) MX_iso(:,3) MX_bg'])   % alternative: stimulus-type ANOVA at C32


%%  --- rmANOVA: effect of chorus size (isolated condition) ---

% Test whether performance varies across chorus sizes 1, 8, 32 (no background)
data = array2table(MX_iso, 'VariableNames', {'C1', 'C2', 'C3'});
% Within-subjects factor: chorus size (3 levels)
withinDesign = table([1 2 3]', 'VariableNames', {'ChorusSize'});
% Fit the repeated measures model
rmModel = fitrm(data, 'C1-C3~1', 'WithinDesign', withinDesign);
% Perform the repeated measures ANOVA
rmANOVA = ranova(rmModel);
% Display the results
disp(rmANOVA);