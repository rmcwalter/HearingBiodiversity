function analyze_data_v2
% Analyze chorus size discrimination data for Experiment 3a.
% Subjects heard birdsong choruses of 3 sizes (1, 8, 32 individuals) at
% 2 durations (0.05 s and 2 s) and performed an oddity discrimination task.
% Results are saved to Exp2a.mat and Exp2a.csv.

%% Plot: proportion correct by duration and chorus size

clear all
load('Exp3a.mat')

figure
set(gcf,'position',[200 200 500 400])
c = colororder;
c = c([3 6 2],:)   % select 3 colours for the 3 chorus sizes
hold on

% --- Individual subject data points (jittered slightly in x for visibility) ---
% Rows 1,4 = chorus size 1; rows 2,5 = chorus size 8; rows 3,6 = chorus size 32
% x positions 1 and 2 correspond to short (0.05 s) and long (2 s) durations
plot([0.9 2.1],udsm([1 4],:),'o','linewidth',0.5,'MarkerFaceColor',c(3,:),'MarkerEdgeColor',[1 1 1])
plot([0.93 2.07],udsm([2 5],:),'s','linewidth',0.5,'MarkerFaceColor',c(3,:),'MarkerEdgeColor',[1 1 1])
plot([0.96 2.04],udsm([3 6],:),'d','linewidth',0.5,'MarkerFaceColor',c(3,:),'MarkerEdgeColor',[1 1 1])

% --- Shaded ±1 SE bands around the group mean for each chorus size ---
patch([1:2 2:-1:1],[udm([1 4])'+se([1 4])' fliplr(udm([1 4])'-se([1 4])')],c(3,:),'FaceAlpha',0.2,'EdgeAlpha',0)
patch([1:2 2:-1:1],[udm([2 5])'+se([2 5])' fliplr(udm([2 5])'-se([2 5])')],c(3,:),'FaceAlpha',0.2,'EdgeAlpha',0)
patch([1:2 2:-1:1],[udm([3 6])'+se([3 6])' fliplr(udm([3 6])'-se([3 6])')],c(3,:),'FaceAlpha',0.2,'EdgeAlpha',0)

% --- Group mean lines (one per chorus size) ---
p(1) = plot([1:2],udm([1 4]),'o-.','linewidth',1.5,'MarkerSize',12,'MarkerFacecolor',c(3,:),'color',c(3,:),'MarkerEdgeColor',[0.9 0.9 0.9])
p(2) = plot([1:2],udm([2 5]),'s:','linewidth',1.5,'MarkerSize',12,'MarkerFacecolor',c(3,:),'color',c(3,:),'MarkerEdgeColor',[0.9 0.9 0.9])
p(3) = plot([1:2],udm([3 6]),'d--','linewidth',1.5,'MarkerSize',12,'MarkerFacecolor',c(3,:),'color',c(3,:),'MarkerEdgeColor',[0.9 0.9 0.9])

% --- Axes, chance line, and labels ---
set(gca,'XLim',[0.5 2.5],'YLim',[0.3 1])
set(gca,'XTick',[1 2],'XTickLabel',{'.05','2'})
line([0 3],[0.33 0.33],'color',[0.6 0.6 0.6],'linestyle','-.') % chance level for 3-AFC
text(2.25,0.35,'chance','color',[0.6 0.6 0.6],'fontsize',14)
ylabel('Proportion correct')
xlabel('Duration (s)')
l = legend(p,{'1','8','32'},'box','off','location','northwest','fontsize',14);
set(l,'position',[0.1 0.2 0.2 0.15]);
text(0.55,0.525,'Chorus size','fontsize',14)
text(2.25,0.9,['n = ' num2str(size(udsm,2))],'fontsize',14)
set(gca,'fontsize',16)


%% Repeated-measures ANOVA: effect of chorus size at the long duration (2 s)

% Rows 4–6 of udsm correspond to chorus sizes 1, 8, 32 at the 2 s duration
data = array2table([udsm([4:6],:)'], 'VariableNames', {'C1', 'C2', 'C3'});
% Create a within-subjects design table indicating the measurements are repeated
withinDesign = table([1 2 3]', 'VariableNames', {'MixType'});
% Fit the repeated measures model
rmModel = fitrm(data, 'C1-C3~1', 'WithinDesign', withinDesign);
% Perform the repeated measures ANOVA
rmANOVA = ranova(rmModel);
% Display the results
disp(rmANOVA);

%% Paired t-tests: short vs. long duration for each chorus size

[H,P1,CI,STATS1] = ttest(udsm(1,:)',udsm(4,:)','tail','both');  % chorus size 1
[H,P2,CI,STATS2] = ttest(udsm(2,:)',udsm(5,:)','tail','both');  % chorus size 8
[H,P3,CI,STATS3] = ttest(udsm(3,:)',udsm(6,:)','tail','both');  % chorus size 32
[P1 P2 P3]                                          % p-values
[STATS1.tstat STATS2.tstat STATS3.tstat]            % t-statistics