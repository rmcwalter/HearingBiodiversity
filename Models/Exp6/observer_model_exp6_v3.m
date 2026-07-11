function observer_model_exp6_v3
% OBSERVER_MODEL_EXP6_V3  Top-level driver for the Exp6 observer model.
%
% Section 1: runs the oddity-task model (RUN_MODEL_V2) 10 times on the
%   pre-computed, z-scored texture statistics for both background
%   conditions - geophony ("a", loaded from _statz_geo2/) and biophony
%   ("b", loaded from _statz_bio2/) - saving per-run model responses to
%   rspZ3ay/ and rspZ3by/ respectively. The internal-noise vector
%   [1 1 2 1 8 5]./1.5 sets the relative noise on the 6 statistic
%   channels (mean, variance, kurtosis, envelope-correlation,
%   modulation-power, modulation-correlation).
% Section 2: aggregates the model's per-condition accuracy (rsp_temp)
%   across the 10 runs, loads matched human behavioral data
%   (Exp6a.mat/Exp6b.mat), and plots model vs. human proportion-correct
%   for each chorus-size/background condition.

%%

clear all
warning off
addpath(genpath('../Supporting_files/_ltfat'))
addpath(genpath('../Supporting_files/_minFunc_2012'))
addpath(genpath('../Model_base/_sts'))
mfb_mode = 'halfoctave';
load(['../Model_base/_system/AudSys_Setup_' mfb_mode '.mat'])

% Load all 50 blocks of z-scored geophony-background statistics
% (63 trials each) and their matching stimulus file listings.
for n = 1:50
    load(['_statz_geo2/Z' num2str(n) '.mat'])

    dn((n-1)*63+1:n*63) = dir(['geobio_stim2aY/' num2str(n) '/*.wav']);
    for k = 1:189
        Z{(n-1)*189+k} = ZZ{k};
    end
end

if exist('rspZ3ay')
    rmdir('rspZ3ay', 's')
end

% Run the oddity-task observer model 10 times (independent noise draws
% per run) on the geophony-background stimuli.
for kk = 1:10%:10%size(NP,1)
    run_model_v2(dn,Z,[1 1 2 1 8 5]./1.5,'rspZ3ay',kk,[1 1 1 1 1 1]);
end
%

% Load all 50 blocks of z-scored biophony-background statistics
% (63 trials each) and their matching stimulus file listings.
for n = 1:50
    load(['_statz_bio2/Z' num2str(n) '.mat'])

    dn((n-1)*63+1:n*63) = dir(['geobio_stim2bY/' num2str(n) '/*.wav']);
    for k = 1:189
        Z{(n-1)*189+k} = ZZ{k};
    end
end

if exist('rspZ3by')
    rmdir('rspZ3by', 's')
end

% Run the oddity-task observer model 10 times on the
% biophony-background stimuli.
for kk = 1:10%:10%size(NP,1)
    run_model_v2(dn,Z,[1 1 2 1 8 5]./1.5,'rspZ3by',kk,[1 1 1 1 1 1]);
end

%% Geophony-background: aggregate model output and compare to human data

clear all

% Average model proportion-correct per condition across the 10 runs.
d = dir('rspZ3ay/*.mat');
for k = 1:length(d)
    load([d(k).folder '/' d(k).name])
    rsp_t(:,k) = rsp_temp;
end

model_udm = mean(rsp_t,2)';
model_udm_sd = std(rsp_t,[],2)';

load('Exp6a.mat')

% Human behavioral data: isolated chorus sizes, chorus+background mixes,
% and background-alone conditions, one column per subject.
udsm = [MX_iso';MX_mix';MX_bg];
udm = mean(udsm,2);
se = std(udsm,[],2)/sqrt(size(udsm,2));

% Bar chart: human proportion-correct (bars + black error bars) with
% model proportion-correct overlaid as grey squares/error bars.
% Bars 1-3 = isolated chorus sizes (1,8,32); bars 5-7 = chorus+geophony
% background mixes; bar 8 = background alone. model_udm is indexed
% [5:7 2:4 1] to reorder its (iso1,iso8,iso32,mix1,mix8,mix32,bg)
% layout to match this bar ordering.
figure
c = colororder;
hold on

bar(1:3,udm([1:3]),'facecolor',c(1,:));
bar(5,udm([4]),'facecolor',c(3,:),'facealpha',0.5);
bar(6,udm([5]),'facecolor',c(3,:),'facealpha',0.5);
bar(7,udm([6]),'facecolor',c(3,:),'facealpha',0.5);
bar(8,udm([7]),'facecolor',c(3,:),'facealpha',1);
e = errorbar([1:3 5:8],udm,se,'color','k');
e.CapSize = 0;
e.LineWidth = 2;
e.LineStyle = 'none';

e = errorbar([1:3 5:8]+0.25,model_udm([5:7 2:4 1]),model_udm_sd([5:7 2:4 1]),'color',[0.5 0.5 0.5]);
e.CapSize = 0;
e.LineWidth = 2;
e.LineStyle = 'none';
plot([1:3]+0.25,model_udm(5:7),'s','MarkerFaceColor',[0.8 0.8 0.8],'MarkerEdgeColor',[0.5 0.5 0.5],'LineWidth',1.5,'MarkerSize',12)
plot([5:7]+0.25,model_udm(2:4),'s','MarkerFaceColor',[0.8 0.8 0.8],'MarkerEdgeColor',[0.5 0.5 0.5],'LineWidth',1.5,'MarkerSize',12)
plot([8]+0.25,model_udm(1),'s','MarkerFaceColor',[0.8 0.8 0.8],'MarkerEdgeColor',[0.5 0.5 0.5],'LineWidth',1.5,'MarkerSize',12)
plot(1,.95,'s','MarkerFaceColor',[0.8 0.8 0.8],'MarkerEdgeColor',[0.5 0.5 0.5],'LineWidth',1.5,'MarkerSize',12)
text(1.25,0.95,'Observer Model','FontSize',12)

line([2 8.5],[udm(2) udm(2)],'color','k','linestyle',':')
line([-0.2 9.2],[0.33 0.33],'color','k','linestyle','-.','color',[0.6 0.6 0.6],'linewidth',2)
text(8.5,0.35,'chance','color',[0.6 0.6 0.6])
set(gca,'XTick',[1:3 5:8],'XTickLabel',{'1','8','32','1+bg','8+bg','32+bg','bg'},'fontsize',14)
set(gca,'YLim',[0.3 1])
xlabel('Chorus size')
ylabel('Proportion correct','FontSize',16)
% title('Exemplar discrimination with geophony background','fontsize',16)
text(8,0.95,['n = ' num2str(size(udsm,2))],'fontsize',14)
set(gca,'TickDir','out');


%% Biophony-background: aggregate model output and compare to human data
clear all

% Average model proportion-correct per condition across the 10 runs.
d = dir('rspZ3by/*.mat');
for k = 1:length(d)
    load([d(k).folder '/' d(k).name])
    rsp_t(:,k) = rsp_temp;
end

model_udm = mean(rsp_t,2)';
model_udm_sd = std(rsp_t,[],2)';

load('Exp6b.mat')
% Human behavioral data: isolated chorus sizes, chorus+background mixes,
% and background-alone conditions, one column per subject.
udsm = [MX_iso';MX_mix';MX_bg];
udm = mean(udsm,2);
se = std(udsm,[],2)/sqrt(size(udsm,2));

% Same bar-chart layout as the geophony plot above, but for the
% biophony-background condition.
figure
c = colororder;
hold on

bar(1:3,udm([1:3]),'facecolor',c(1,:));
bar(5,udm([4]),'facecolor',c(2,:),'facealpha',0.5);
bar(6,udm([5]),'facecolor',c(2,:),'facealpha',0.5);
bar(7,udm([6]),'facecolor',c(2,:),'facealpha',0.5);
bar(8,udm([7]),'facecolor',c(2,:),'facealpha',1);
e = errorbar([1:3 5:8],udm,se,'color','k');
e.CapSize = 0;
e.LineWidth = 2;
e.LineStyle = 'none';

e = errorbar([1:3 5:8]+0.25,model_udm([5:7 2:4 1]),model_udm_sd([5:7 2:4 1]),'color',[0.5 0.5 0.5]);
e.CapSize = 0;
e.LineWidth = 2;
e.LineStyle = 'none';
plot([1:3]+0.25,model_udm(5:7),'s','MarkerFaceColor',[0.8 0.8 0.8],'MarkerEdgeColor',[0.5 0.5 0.5],'LineWidth',1.5,'MarkerSize',12)
plot([5:7]+0.25,model_udm(2:4),'s','MarkerFaceColor',[0.8 0.8 0.8],'MarkerEdgeColor',[0.5 0.5 0.5],'LineWidth',1.5,'MarkerSize',12)
plot([8]+0.25,model_udm(1),'s','MarkerFaceColor',[0.8 0.8 0.8],'MarkerEdgeColor',[0.5 0.5 0.5],'LineWidth',1.5,'MarkerSize',12)
plot(1,.95,'s','MarkerFaceColor',[0.8 0.8 0.8],'MarkerEdgeColor',[0.5 0.5 0.5],'LineWidth',1.5,'MarkerSize',12)
text(1.25,0.95,'Observer Model','FontSize',12)

line([2 8.5],[udm(2) udm(2)],'color','k','linestyle',':')
line([-0.2 9.2],[0.33 0.33],'color','k','linestyle','-.','color',[0.6 0.6 0.6],'linewidth',2)
text(8.5,0.35,'chance','color',[0.6 0.6 0.6])
set(gca,'XTick',[1:3 5:8],'XTickLabel',{'1','8','32','1+bg','8+bg','32+bg','bg'},'fontsize',14)
set(gca,'YLim',[0.3 1])
xlabel('Chorus size')
ylabel('Proportion correct','FontSize',16)
title('Exemplar discrimination with biophony background','fontsize',16)
text(8,0.95,['n = ' num2str(size(udsm,2))],'fontsize',14)
set(gca,'TickDir','out');