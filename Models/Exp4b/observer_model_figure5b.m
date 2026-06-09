function observer_model_figure5b
% observer_model_figure5b  Generates Figure 5b: per-condition model comparison.
%
% Plots a side-by-side panel for each of seven models showing proportion
% correct across the three conditions (species / mixture / individual).
% Human data bars (faded) are overlaid with model predictions (markers +
% error bars) for direct comparison.
%
% Models shown (left to right):
%   1 - Auditory Texture Model (full, all six statistic classes)
%   2 - Frequency Spectrum     (envelope mean only)
%   3 - Envelope Coeff. of Var.
%   4 - Envelope Correlation
%   5 - Modulation Power
%   6 - Loudness
%   7 - Pitch (YIN)
%
% A final subplot shows the per-model mean error (16th–84th percentile CI).
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

%% Load human data
clearvars -except A B C rsp
load('N16_online_data.mat')

[i,j] = find(~isnan(MXn));
for k = 1:length(i)
    MXn_temp(k) = MXn(i(k),j(k));
    SXn_temp(k) = SXn(i(k),j(k));
    MXn_std_temp(k) = MXn_std(i(k),j(k));
    SXn_std_temp(k) = SXn_std(i(k),j(k));
end

for k = 1:10
    MXi_temp(k) = MX_ind_mean(k,k);
    MXi_std_temp(k) = MX_ind_se(k,k);
end

[~,Ik] = sort(MXn_temp);

%% Plot per-condition panels for each model
% mof: horizontal offset so model markers sit to the left of human bars
mof = 0.33;
figure
set(gcf,'position',[200 200 1000 350])
c = colororder;
c(8,:) = [0 0 0];
kk = [2 3 1]; % colour index mapping: condition 1=species, 2=mix, 3=individual

AtmRsp = load(['model_original/atmw_v2.mat']);
subplot('position',[0.05 0.2 0.09 0.6])
line([0 4],[0.33 0.33],'linewidth',2,'linestyle','--','color',[0.8 0.8 0.8])
hold on
bar(1,mean(MX_results3(:,1)),'facecolor',c(2,:),'facealpha',0.05,'edgealpha',0)
bar(2,mean(MX_results3(:,2)),'facecolor',c(3,:),'facealpha',0.05,'edgealpha',0)
bar(3,mean(MX_results3(:,3)),'facecolor',c(1,:),'facealpha',0.05,'edgealpha',0)
se = std(MX_results3)/sqrt(length(MX_results3));
for k = 1:3
    lh = line([k k],mean(MX_results3(:,k))+[-se(k) se(k)],'linewidth',2);
    lh.Color=[c(kk(k),:),0.25];

    pc = prctile(AtmRsp.rsp(:,4-k),[2.5 97.5]);
    eb1 = errorbar(k-mof,mean(AtmRsp.rsp(:,4-k)),mean(AtmRsp.rsp(:,4-k))-pc(1),pc(2)-mean(AtmRsp.rsp(:,4-k)));
    eb1.CapSize = 0;
    eb1.LineWidth = 2;
    eb1.Color = c(kk(k),:);
end
plot(1-mof,mean(AtmRsp.rsp(:,3)),'s','MarkerFacecolor',c(2,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',12,'LineWidth',1.5)
plot(2-mof,mean(AtmRsp.rsp(:,2)),'s','MarkerFacecolor',c(3,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',12,'LineWidth',1.5)
plot(3-mof,mean(AtmRsp.rsp(:,1)),'s','MarkerFacecolor',c(1,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',12,'LineWidth',1.5)

set(gca,'YLim',[0.25 1.05],'YTick',[0.33 0.5 0.75 1],'YTickLabel',[0.33 0.5 0.75 1],'FontSize',12)
set(gca,'XTick',[1:3],'XLim',[0 3.75],'XTickLabel',{'Individiuals','Mixtures','Species'},'FontSize',12)
set(gca,'TickDir','out')
ylabel('Proportion Correct')
title([{'Auditory'},{'Texture Model'}],'color',c(8,:))


SpecRsp = load('model_original/spec_v2.mat');
subplot('position',[0.15 0.2 0.09 0.6])
line([0 4],[0.33 0.33],'linewidth',2,'linestyle','--','color',[0.8 0.8 0.8])
hold on
bar(1,mean(MX_results3(:,1)),'facecolor',c(2,:),'facealpha',0.05,'edgealpha',0)
bar(2,mean(MX_results3(:,2)),'facecolor',c(3,:),'facealpha',0.05,'edgealpha',0)
bar(3,mean(MX_results3(:,3)),'facecolor',c(1,:),'facealpha',0.05,'edgealpha',0)
for k = 1:3
    lh = line([k k],mean(MX_results3(:,k))+[-se(k) se(k)],'linewidth',2);
    lh.Color=[c(kk(k),:),0.25];

    pc = prctile(SpecRsp.rsp(:,4-k),[2.5 97.5]);
    eb1 = errorbar(k-mof,mean(SpecRsp.rsp(:,4-k)),mean(SpecRsp.rsp(:,4-k))-pc(1),pc(2)-mean(SpecRsp.rsp(:,4-k)));
    eb1.CapSize = 0;
    eb1.LineWidth = 2;
    eb1.Color = c(kk(k),:);
end
plot(1-mof,mean(SpecRsp.rsp(:,3)),'<','MarkerFacecolor',c(2,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)
plot(2-mof,mean(SpecRsp.rsp(:,2)),'<','MarkerFacecolor',c(3,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)
plot(3-mof,mean(SpecRsp.rsp(:,1)),'<','MarkerFacecolor',c(1,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)
set(gca,'YLim',[0.25 1.05],'YTick',[0.33 0.5 0.75 1],'YTickLabel',[],'FontSize',12)
set(gca,'XTick',[1:3],'XTickLabel',{'Individiuals','Mixtures','Species'},'FontSize',12)
set(gca,'TickDir','out')
title([{'Frequency'},{'Spectrum'}],'color',c(8,:))

VarRsp = load('model_original/var_v2.mat');
subplot('position',[0.25 0.2 0.09 0.6])
line([0 4],[0.33 0.33],'linewidth',2,'linestyle','--','color',[0.8 0.8 0.8])
hold on
bar(1,mean(MX_results3(:,1)),'facecolor',c(2,:),'facealpha',0.05,'edgealpha',0)
bar(2,mean(MX_results3(:,2)),'facecolor',c(3,:),'facealpha',0.05,'edgealpha',0)
bar(3,mean(MX_results3(:,3)),'facecolor',c(1,:),'facealpha',0.05,'edgealpha',0)
for k = 1:3
    lh = line([k k],mean(MX_results3(:,k))+[-se(k) se(k)],'linewidth',2);
    lh.Color=[c(kk(k),:),0.25];

    pc = prctile(VarRsp.rsp(:,4-k),[2.5 97.5]);
    eb1 = errorbar(k-mof,mean(VarRsp.rsp(:,4-k)),mean(VarRsp.rsp(:,4-k))-pc(1),pc(2)-mean(VarRsp.rsp(:,4-k)));
    eb1.CapSize = 0;
    eb1.LineWidth = 2;
    eb1.Color = c(kk(k),:);
end
plot(1-mof,mean(VarRsp.rsp(:,3)),'v','MarkerFacecolor',c(2,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)
plot(2-mof,mean(VarRsp.rsp(:,2)),'v','MarkerFacecolor',c(3,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)
plot(3-mof,mean(VarRsp.rsp(:,1)),'v','MarkerFacecolor',c(1,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)

set(gca,'YLim',[0.25 1.05],'YTick',[0.33 0.5 0.75 1],'YTickLabel',[],'FontSize',12)
set(gca,'XTick',[1:3],'XTickLabel',{'Individiuals','Mixtures','Species'},'FontSize',12)
set(gca,'TickDir','out')
title([{'Envelope'},{'Coeff. of Var.'}],'color',c(8,:))

CorrRsp = load('model_original/corr_v2.mat');
subplot('position',[0.35 0.2 0.09 0.6])
line([0 4],[0.33 0.33],'linewidth',2,'linestyle','--','color',[0.8 0.8 0.8])
hold on
bar(1,mean(MX_results3(:,1)),'facecolor',c(2,:),'facealpha',0.05,'edgealpha',0)
bar(2,mean(MX_results3(:,2)),'facecolor',c(3,:),'facealpha',0.05,'edgealpha',0)
bar(3,mean(MX_results3(:,3)),'facecolor',c(1,:),'facealpha',0.05,'edgealpha',0)
for k = 1:3
    lh = line([k k],mean(MX_results3(:,k))+[-se(k) se(k)],'linewidth',2);
    lh.Color=[c(kk(k),:),0.25];
    pc = prctile(CorrRsp.rsp(:,4-k),[2.5 97.5]);
    eb1 = errorbar(k-mof,mean(CorrRsp.rsp(:,4-k)),mean(CorrRsp.rsp(:,4-k))-pc(1),pc(2)-mean(CorrRsp.rsp(:,4-k)));
    eb1.CapSize = 0;
    eb1.LineWidth = 2;
    eb1.Color = c(kk(k),:);
end
plot(1-mof,mean(CorrRsp.rsp(:,3)),'>','MarkerFacecolor',c(2,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)
plot(2-mof,mean(CorrRsp.rsp(:,2)),'>','MarkerFacecolor',c(3,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)
plot(3-mof,mean(CorrRsp.rsp(:,1)),'>','MarkerFacecolor',c(1,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)

set(gca,'YLim',[0.25 1.05],'YTick',[0.33 0.5 0.75 1],'YTickLabel',[],'FontSize',12)
set(gca,'XTick',[1:3],'XTickLabel',{'Individiuals','Mixtures','Species'},'FontSize',12)
set(gca,'TickDir','out')
title([{'Envelope'};{'Correlation'}],'color',c(8,:))

MPRsp = load('model_original/mod_power_v2.mat');
subplot('position',[0.45 0.2 0.09 0.6])
line([0 4],[0.33 0.33],'linewidth',2,'linestyle','--','color',[0.8 0.8 0.8])
hold on
bar(1,mean(MX_results3(:,1)),'facecolor',c(2,:),'facealpha',0.05,'edgealpha',0)
bar(2,mean(MX_results3(:,2)),'facecolor',c(3,:),'facealpha',0.05,'edgealpha',0)
bar(3,mean(MX_results3(:,3)),'facecolor',c(1,:),'facealpha',0.05,'edgealpha',0)
for k = 1:3
    lh = line([k k],mean(MX_results3(:,k))+[-se(k) se(k)],'linewidth',2);
    lh.Color=[c(kk(k),:),0.25];
    pc = prctile(MPRsp.rsp(:,4-k),[2.5 97.5]);
    eb1 = errorbar(k-mof,mean(MPRsp.rsp(:,4-k)),mean(MPRsp.rsp(:,4-k))-pc(1),pc(2)-mean(MPRsp.rsp(:,4-k)));
    eb1.CapSize = 0;
    eb1.LineWidth = 2;
    eb1.Color = c(kk(k),:);
end
plot(1-mof,mean(MPRsp.rsp(:,3)),'^','MarkerFacecolor',c(2,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)
plot(2-mof,mean(MPRsp.rsp(:,2)),'^','MarkerFacecolor',c(3,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)
plot(3-mof,mean(MPRsp.rsp(:,1)),'^','MarkerFacecolor',c(1,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)

set(gca,'YLim',[0.25 1.05],'YTick',[0.33 0.5 0.75 1],'YTickLabel',[],'FontSize',12)
set(gca,'XTick',[1:3],'XTickLabel',{'Individiuals','Mixtures','Species'},'FontSize',12)
set(gca,'TickDir','out')
title([{'Modulation'};{'Power'}],'color',c(8,:))

LoudRsp = load('model_original/loudness.mat');
subplot('position',[0.55 0.2 0.09 0.6])
line([0 4],[0.33 0.33],'linewidth',2,'linestyle','--','color',[0.8 0.8 0.8])
hold on
bar(1,mean(MX_results3(:,1)),'facecolor',c(2,:),'facealpha',0.05,'edgealpha',0)
bar(2,mean(MX_results3(:,2)),'facecolor',c(3,:),'facealpha',0.05,'edgealpha',0)
bar(3,mean(MX_results3(:,3)),'facecolor',c(1,:),'facealpha',0.05,'edgealpha',0)
for k = 1:3
    lh = line([k k],mean(MX_results3(:,k))+[-se(k) se(k)],'linewidth',2);
    lh.Color=[c(kk(k),:),0.25];
    pc = prctile(LoudRsp.rsp(:,4-k),[2.5 97.5]);
    eb1 = errorbar(k-mof,mean(LoudRsp.rsp(:,4-k)),mean(LoudRsp.rsp(:,4-k))-pc(1),pc(2)-mean(LoudRsp.rsp(:,4-k)));
    eb1.CapSize = 0;
    eb1.LineWidth = 2;
    eb1.Color = c(kk(k),:);
end
plot(1-mof,mean(LoudRsp.rsp(:,3)),'o','MarkerFacecolor',c(2,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)
plot(2-mof,mean(LoudRsp.rsp(:,2)),'o','MarkerFacecolor',c(3,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)
plot(3-mof,mean(LoudRsp.rsp(:,1)),'o','MarkerFacecolor',c(1,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)

set(gca,'YLim',[0.25 1.05],'YTick',[0.33 0.5 0.75 1],'YTickLabel',[],'FontSize',12)
set(gca,'XTick',[1:3],'XTickLabel',{'Individiuals','Mixtures','Species'},'FontSize',12)
set(gca,'TickDir','out')
title([{'Loudness'}],'color',c(8,:))

YinRsp = load('model_original/yin.mat');
subplot('position',[0.65 0.2 0.09 0.6])
line([0 4],[0.33 0.33],'linewidth',2,'linestyle','--','color',[0.8 0.8 0.8])
hold on
bar(1,mean(MX_results3(:,1)),'facecolor',c(2,:),'facealpha',0.05,'edgealpha',0)
bar(2,mean(MX_results3(:,2)),'facecolor',c(3,:),'facealpha',0.05,'edgealpha',0)
bar(3,mean(MX_results3(:,3)),'facecolor',c(1,:),'facealpha',0.05,'edgealpha',0)
for k = 1:3
    lh = line([k k],mean(MX_results3(:,k))+[-se(k) se(k)],'linewidth',2);
    lh.Color=[c(kk(k),:),0.25];
    pc = prctile(YinRsp.rsp(:,4-k),[2.5 97.5]);
    eb1 = errorbar(k-mof,mean(YinRsp.rsp(:,4-k)),mean(YinRsp.rsp(:,4-k))-pc(1),pc(2)-mean(YinRsp.rsp(:,4-k)));
    eb1.CapSize = 0;
    eb1.LineWidth = 2;
    eb1.Color = c(kk(k),:);
end
plot(1-mof,mean(YinRsp.rsp(:,3)),'d','MarkerFacecolor',c(2,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)
plot(2-mof,mean(YinRsp.rsp(:,2)),'d','MarkerFacecolor',c(3,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)
plot(3-mof,mean(YinRsp.rsp(:,1)),'d','MarkerFacecolor',c(1,:),'MarkerEdgeColor',[0.9 0.9 0.9],'MarkerSize',10,'LineWidth',1.5)
set(gca,'YLim',[0.25 1.05],'YTick',[0.33 0.5 0.75 1],'YTickLabel',[],'FontSize',12)
set(gca,'XTick',[1:3],'XTickLabel',{'Individiuals','Mixtures','Species'},'FontSize',12)
set(gca,'TickDir','out')
title({'Pitch'},'color',c(8,:))

%% Model error bar chart (16th-84th percentile CIs from errX)
subplot('position',[0.8 0.2 0.15 0.6])
hold on
bar(1,mean(AtmRsp.errX(:,end)),'facecolor',c(8,:),'facealpha',0.25,'edgealpha',0)
bar(2,mean(SpecRsp.errX(:,end)),'facecolor',c(8,:),'facealpha',0.25,'edgealpha',0)
bar(3,mean(VarRsp.errX(:,end)),'facecolor',c(8,:),'facealpha',0.25,'edgealpha',0)
bar(4,mean(CorrRsp.errX(:,end)),'facecolor',c(8,:),'facealpha',0.25,'edgealpha',0)
bar(5,mean(MPRsp.errX(:,end)),'facecolor',c(8,:),'facealpha',0.25,'edgealpha',0)
bar(6,mean(LoudRsp.errX(:,end)),'facecolor',c(8,:),'facealpha',0.25,'edgealpha',0)
bar(7,mean(YinRsp.errX(:,end)),'facecolor',c(8,:),'facealpha',0.25,'edgealpha',0)
for k = 1:7
    if k == 1
        p1(:,k) = prctile(AtmRsp.errX(:,end),[16 84]);
    elseif k == 2
        p1(:,k) = prctile(SpecRsp.errX(:,end),[16 84]);
    elseif k == 3
        p1(:,k) = prctile(VarRsp.errX(:,end),[16 84]);
    elseif k == 4
        p1(:,k) = prctile(CorrRsp.errX(:,end),[16 84]);
    elseif k == 5
        p1(:,k) = prctile(MPRsp.errX(:,end),[16 84]);
    elseif k == 6
        p1(:,k) = prctile(LoudRsp.errX(:,end),[16 84]);
    elseif k == 7
        p1(:,k) = prctile(YinRsp.errX(:,end),[16 84]);
    end
    lh = line([k k],p1(:,k),'linewidth',2);
    lh.Color=[c(8,:),0.25];
end

set(gca,'YLim',[0 0.2],'YTick',[0:0.1:0.5],'YTickLabel',[0:0.1:0.5],'FontSize',12)
set(gca,'XTick',[1:7],'XTickLabel',{'Aud. Tex.','Freq. Spec.','Env. Var.','Env. Corr.','Mod. Pow.','Loud.','Pitch'},'FontSize',12)
ylabel('Error')
set(gca,'TickDir','out')
title('Model Error')
