function Observer_model_exp5
% Observer_model_exp5
% Runs the auditory texture observer model for Experiment 5 and plots the
% results against human psychophysical data.
%
% The experiment is a 3-interval oddity task: listeners hear three 2-second
% bird chorus segments and must identify the "odd one out" (the interval
% containing a different exemplar). Chorus sizes vary across conditions:
%   x-axis label  chorus composition
%   1             solo bird
%   8             8-bird chorus
%   32            32-bird chorus
%   8+1           8-bird + 1 target (target is solo)
%   8+1*          8-bird + 1 target (oracle version)
%   8+8           8-bird + 8-bird target
%   8+8*          8-bird + 8-bird target (oracle version)
%
% Section 1 - Run model on standard stimuli  -> exp5_model/
% Section 2 - Run model on oracle stimuli    -> exp5_model_oracle/
% Section 3 - Load results and plot against human data (expv8_N27.mat)

%%  SECTION 1: Standard stimuli

clear all

addpath(genpath('../Supporting_files/_ltfat'))
addpath(genpath('../Supporting_files/_minFunc_2012'))
addpath(genpath('../Model_base/_sts'))
mfb_mode = 'halfoctave';
load(['../Model_base/_system/AudSys_Setup_' mfb_mode '.mat'])

% Load stimulus file list (variable d: dir struct of WAV files)
load('exp5_stim_name.mat')

% Reassemble the full Z cell array from per-subject files (50 × 1050 = 52500)
for n = 1:50
    load(['_statz/Z' num2str(n) '.mat'])
    for k = 1:1050
        Z{(n-1)*1050+k} = ZZ{k};
    end
end

% Run the observer model with noise parameters [1 1 2 1 8 5] for each stat class:
%   NP(1) - envelope mean noise
%   NP(2) - envelope CV noise
%   NP(3) - envelope skewness noise
%   NP(4) - envelope correlation noise
%   NP(5) - modulation power noise
%   NP(6) - modulation correlation noise
for kk = 1:100
    % run_model2(d,Z,NP(kk,:),kk);
    run_model(d,Z,[1 1 2 1 8 5],0.9,kk,'exp5_model');
end

%  SECTION 2: Oracle stimuli
% Same model run with noise parameters scaled down by 1.275 to account for
% the higher discriminability of oracle target intervals.

clear all

addpath(genpath('../Supporting_files/_ltfat'))
addpath(genpath('../Supporting_files/_minFunc_2012'))
addpath(genpath('../Model_base/_sts'))
mfb_mode = 'halfoctave';
load(['../Model_base/_system/AudSys_Setup_' mfb_mode '.mat'])

load('exp5oracle_stim_name.mat')

for n = 1:50
    load(['_statzo/Z' num2str(n) '.mat'])
    for k = 1:1050
        Z{(n-1)*1050+k} = ZZ{k};
    end
end

for kk = 1:100
    run_model(do,Z,[1 1 2 1 8 5],0.8,kk,'exp5_model_oracle');
end

%%  SECTION 3: Load model outputs and plot against human data

clear all

% --- Standard model predictions ---
d = dir(['exp5_model/*.mat']);

% Average model responses across runs (rows) and repetitions (3rd dim of rsp)
for k = 1:length(d)
    load([d(k).folder '/' d(k).name]);
    rspXX(k,:) = mean(mean(rsp,3));  % mean over repetitions -> (runs x conditions)
end

rspX = mean(rspXX,3);  % mean over runs

% Bootstrap CI: 2.5th and 97.5th percentiles across runs -> error bars
rspX_pct = mean(prctile(rspXX,[2.5 97.5]),3);
rspX_sd  = (rspX_pct(2,:)-rspX_pct(1,:))/2;

% --- Human data ---
% udsm: (subjects x conditions) proportion correct matrix
load('expv8_N27.mat')
if size(udsm,1) == 1
    udm = mean(udsm,1);
else
    udm = mean(udsm,2);
end
se   = std(udsm,[],2)/sqrt(size(udsm,2));
udX  = mean(udsm,2)';

% Compute model fit error (sum of absolute deviations on first 7 conditions)
for k = 1:length(d)
    ErrX(k) = sum(abs(rspX(k,[1:7])-udX([1:7])));
end

rspX = mean(rspX);  % collapse to single mean prediction

% --- Plot human bars + model predictions ---
figure
c = colororder;
hold on

% Human bars: conditions mapped to x positions [1 2 3 5 6 7 8]
% Varying alpha encodes chorus type (denser chorus -> lower alpha)
bar(1:3,udm([1 2 7]),'facecolor',c(1,:),'facealpha',1/4,'edgealpha',0);
bar(5,udm([3]),'facecolor',c(1,:),'facealpha',0.75/4,'edgealpha',0);
bar(6,udm([4]),'facecolor',c(1,:),'facealpha',0.5/4,'edgealpha',0);
bar(7,udm([5]),'facecolor',c(1,:),'facealpha',0.5/4,'edgealpha',0);
bar(8,udm([6]),'facecolor',c(1,:),'facealpha',0.25/4,'edgealpha',0);
e = errorbar([1:3 5:8],udm([1 2 7 3 4 5 6]),se,'color',[0.75 0.75 0.75]);
e.CapSize = 0;
e.LineWidth = 2;
e.LineStyle = 'none';

% Reference lines
line([2 8.5],[udm(2) udm(2)],'color','k','linestyle',':')
line([-0.2 9.2],[0.33 0.33],'color','k','linestyle','-.','color',[0.6 0.6 0.6],'linewidth',2)
text(8.5,0.35,'chance','color',[0.6 0.6 0.6])
set(gca,'XTick',[1:3 5:8],'XTickLabel',{'1','8','32','8+1','8+1*','8+8','8+8*'},'fontsize',14)
set(gca,'YLim',[0.3 1])
xlabel('Chorus size')
ylabel('Proportion correct','FontSize',16)
title('Exemplar discrimination with simultaneous chorus','fontsize',16)
text(8,0.95,['n = ' num2str(size(udsm,2))],'fontsize',14)
set(gca,'TickDir','out');

% Standard model predictions (squares, offset left by 0.25)
e = errorbar([1:3 5:8]-0.25,rspX([1 2 7 3 4 5 6]),rspX_sd,'color',c(1,:));
e.CapSize = 0;
e.LineWidth = 2;
e.LineStyle = 'none';

plot([1:3 5:8]-0.25,rspX([1 2 7 3 4 5 6]),'s','MarkerFaceColor',[0.85 0.85 0.85],...
    'MarkerEdgeColor',c(1,:),'MarkerSize',10,'linewidth',1)

% --- Overlay oracle model predictions (circles, offset right by 0.25) ---
% Oracle predictions only cover the mixed-chorus conditions (x positions 5-8)
clearvars RspX Rsp XX rspX_sd rspXX
d = dir(['exp5_model_oracle/*.mat']);

for k = 1:length(d)
    load([d(k).folder '/' d(k).name]);
    rspXX(:,:,k) = mean(rsp,3);
end

rspX     = mean(mean(rspXX,3));
rspX_pct = mean(prctile(rspXX,[2.5 97.5]),3);
rspX_sd  = (rspX_pct(2,:)-rspX_pct(1,:))/2;

e = errorbar([5:8]+0.25,rspX([3 4 5 6]),rspX_sd([3 4 5 6]),'color',c(1,:));
e.CapSize = 0;
e.LineWidth = 2;
e.LineStyle = 'none';

plot([5:8]+0.25,rspX([3 4 5 6]),'o','MarkerFaceColor',[0.85 0.85 0.85],...
    'MarkerEdgeColor',c(1,:),'MarkerSize',8,'linewidth',1)


% e = errorbar([1:3]+0.25,rspX([1 2 7]),rspX_sd([1 2 7]),'color',c(1,:));
% e.CapSize = 0;
% e.LineWidth = 2;
% e.LineStyle = 'none';
% plot([1:3]+0.25,rspX([1 2 7]),'o','MarkerFaceColor',[0.85 0.85 0.85],...
    % 'MarkerEdgeColor',c(1,:),'MarkerSize',6,'linewidth',1)
