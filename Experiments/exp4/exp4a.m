function exp4a
% exp4a - Experiment 4a: Mixture Discrimination Task
%
% Loads participant accuracy data from Exp4a.mat for three discrimination
% conditions across 5 chorus sizes (2, 4, 8, 16, 32 species):
%   - Different Species (spe): target is a different species
%   - Mixture (mix): target is a different mixture of species
%   - Same Species (ind): target is a different individual of the same species
%
% Plots mean proportion correct with SEM shading, then runs a
% repeated-measures ANOVA for each condition across chorus sizes.

clear all
load('Exp4a.mat')

% Compute mean proportion correct across participants for each condition
MXspe_m = mean(MX_results_spe);
MXmix_m = mean(MX_results_mix);
MXind_m = mean(MX_results_ind);

%%
% Compute standard error of the mean for each condition
MXspe_se = std(MX_results_spe)/sqrt(size(MX_results_spe,1));
MXmix_se = std(MX_results_mix)/sqrt(size(MX_results_spe,1));
MXind_se = std(MX_results_ind)/sqrt(size(MX_results_spe,1));

%%
c = colororder;
figure
set(gcf,'position',[200 200 1000 600])
subplot('position',[0.05 0.1 0.2 0.8])
hold on

% Draw chance-level reference line (1/3 for 3-AFC task)
line([0 6],[0.33 0.33],'linewidth',2,'linestyle',':','color',[0.8 0.8 0.8])
text(0.1,0.35,'chance','color',[0.8 0.8 0.8],'fontsize',14)

% Shaded SEM bands for each condition
patch([1:5 5:-1:1],[MXspe_m+MXspe_se fliplr(MXspe_m-MXspe_se)],c(1,:),'FaceAlpha',0.2,'EdgeAlpha',0)
patch([1:5 5:-1:1],[MXmix_m+MXmix_se fliplr(MXmix_m-MXmix_se)],c(3,:),'FaceAlpha',0.2,'EdgeAlpha',0)
patch([1:5 5:-1:1],[MXind_m+MXind_se fliplr(MXind_m-MXind_se)],c(2,:),'FaceAlpha',0.2,'EdgeAlpha',0)

% Mean performance lines for each condition
plot([1:5],MXspe_m,'o-','color',c(1,:),'MarkerFaceColor',c(1,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',12,'LineWidth',2)
plot([1:5],MXmix_m,'o-','color',c(3,:),'MarkerFaceColor',c(3,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',12,'LineWidth',2)
plot([1:5],MXind_m,'o-','color',c(2,:),'MarkerFaceColor',c(2,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',12,'LineWidth',2)
set(gca,'Xlim',[0 6],'YLim',[0.25 1],'FontSize',12)
set(gca,'XTick',[1:5],'XTickLabel',[2 4 8 16 32],'FontSize',12)
ylabel('Proportion Correct','FontSize',14)
xlabel('Chorus size','FontSize',14)
title('Mixture Discrimination Task')

%% Species discrimination condition
% Repeated-measures ANOVA testing effect of chorus size on accuracy

data = array2table([MX_results_spe], 'VariableNames', {'C1','C2','C3','C4','C5'});
withinDesign = table([1 2 3 4 5]', 'VariableNames', {'MixType'});
rmModel = fitrm(data, 'C1-C5~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);

%% Mixture discrimination condition
% Repeated-measures ANOVA testing effect of chorus size on accuracy

data = array2table([MX_results_mix], 'VariableNames', {'C1','C2','C3','C4','C5'});
withinDesign = table([1 2 3 4 5]', 'VariableNames', {'MixType'});
rmModel = fitrm(data, 'C1-C5~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);

%% Individuals discrimination condition
% Repeated-measures ANOVA testing effect of chorus size on accuracy

data = array2table([MX_results_ind], 'VariableNames', {'C1','C2','C3','C4','C5'});
withinDesign = table([1 2 3 4 5]', 'VariableNames', {'MixType'});
rmModel = fitrm(data, 'C1-C5~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
