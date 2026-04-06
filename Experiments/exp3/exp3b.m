function analyze_data_v2
% Analyze species vs. exemplar discrimination data for Experiment 3b.
% Subjects performed an oddity task at 2 durations (0.05 s and 2 s) under
% two conditions: discriminating between species, and discriminating between
% exemplars of the same species.
% Results are saved to Exp2b.mat and Exp2b.csv.


%% Plot: proportion correct by task type and duration

clear all
load('Exp3b.mat')
figure

set(gcf,'position',[200 200 500 400])
c = colororder;
hold on

% --- Species discrimination (blue circles) ---
% x positions 1 and 2 = short (0.05 s) and long (2 s) durations
plot([0.95 2.05],udsm1,'o','linewidth',0.5,'MarkerFaceColor',[0.8 0.8 1],'MarkerEdgeColor',[1 1 1])
patch([1:2 2:-1:1],[udm1([1 2])'+se1([1 2])' fliplr(udm1([1 2])'-se1([1 2])')],c(1,:),'FaceAlpha',0.05,'EdgeAlpha',0)
plot(udm1([1 2]),'linewidth',3,'color',c(1,:))
p(1) = plot(udm1([1 2]),'o','linewidth',1.5,'MarkerSize',12,'MarkerFacecolor',c(1,:),'MarkerEdgeColor',[0.9 0.9 0.9]);
set(gca,'XLim',[0.5 2.5],'YLim',[0.3 1])
text(2.25,0.95,['n = ' num2str(length(ts1))],'fontsize',16)

% --- Exemplar discrimination (red diamonds) ---
c = colororder;
hold on
plot([0.925 2.075],udsm2,'d','linewidth',0.5,'MarkerFaceColor',[1 0.8 0.8],'MarkerEdgeColor',[1 1 1])
patch([1:2 2:-1:1],[udm2([1 2])'+se2([1 2])' fliplr(udm2([1 2])'-se2([1 2])')],c(2,:),'FaceAlpha',0.05,'EdgeAlpha',0)
plot(udm2([1 2]),'linewidth',3,'color',c(2,:))
p(2) = plot(udm2([1 2]),'d','linewidth',1.5,'MarkerSize',12,'MarkerFacecolor',c(2,:),'MarkerEdgeColor',[0.9 0.9 0.9]);

% --- Axes, chance line, and labels ---
set(gca,'XLim',[0.5 2.5],'YLim',[0.3 1])
set(gca,'XTick',[1 2],'XTickLabel',{'.05','2'})
line([0 3],[0.33 0.33],'color',[0.6 0.6 0.6],'linestyle','-.') % chance level for 3-AFC
text(2.25,0.35,'chance','color',[0.6 0.6 0.6], 'fontsize',16)
ylabel('Proportion correct')
xlabel('Duration (s)')
legend(p,{'Species discrimination','Exemplar discrimination'},'box','off','location','northwest')
set(gca,'fontsize',18)

%% Paired t-tests: effect of duration within each task type

% Species discrimination: short vs. long duration
[H,P1,CI,STATS1] = ttest(udsm1(2,:)',udsm1(1,:)','tail','both')
% Exemplar discrimination: short vs. long duration
[H,P1,CI,STATS1] = ttest(udsm2(1,:)',udsm2(2,:)','tail','both')



