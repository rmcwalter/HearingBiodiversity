function texture_stats_distance_for_task1b_v2
% Compute texture-statistic distances for Experiment 1b (sound families 12-22)
% and simulate the 3-AFC discrimination task.
%
% Pipeline:
%   1. Measure auditory texture statistics for each sound file and save to X2.mat
%   2. Z-score statistics across sounds and compute pairwise distances (p2_v2.mat)
%   3. Simulate the 3-AFC task and reshape performance by N1/N2 condition
%   4. Plot model predictions against human data (loaded from v1b.mat)
%
% Requires libraries and system files from ../Model_base/.

%%

clear all
% Add shared libraries from Model_base
addpath(genpath('../Supporting_files/_ltfat'))        % auditory filterbank toolbox
addpath(genpath('../Supporting_files/_minFunc_2012')) % optimisation routines
addpath(genpath('../Model_base/_sts'))                % sound texture synthesis functions

% Set up the auditory model filterbank and load the resulting workspace variables:
%   g          - filterbank filters
%   fs_d       - downsampled envelope sample rate
%   compression - compression exponent applied to envelopes
%   fcc        - subband centre frequencies
%   mfb        - modulation filterbank
mfb_mode = 'halfoctave';
% AudSys_Setup(mfb_mode);
load('../Model_base/_system/AudSys_Setup_halfoctave.mat')

% Find the sound file directories (one sub-directory per sound family)
ds = dir('_sounds/_dis*');

for k = 1:11
    d = dir([ds(k+11).folder '/' ds(k+11).name '/*.wav']);
    dsn{k} = d;
end
save('dsn1b.mat','dsn');

%%
% Measure auditory texture statistics for each sound, for 3 non-overlapping
% 2-second segments per file (indexed by m). Results are stored in cell array X
% with dimensions {sound_family, file_ID, segment}.
%
% Statistics stored per cell (fields of Meas_SynthStats output):
%   .Px  - envelope power per subband
%   .Mx  - envelope marginal moments [mean, variance, skewness, kurtosis]
%   .Vx  - envelope variance
%   .Cx  - envelope cross-correlation matrix (subband pairs)
%   .MPx - modulation power
%   .MVx - modulation variance
%   .MCx - modulation cross-correlation (subband x modulation band pairs)
for k = 12:22  % process sound families 12-22 (task 1b); change limit to length(ds) for all
    d = dir([ds(k).folder '/' ds(k).name '/*.wav']);
    for ID = 1:length(d)
        [y_p fs] = audioread([d(ID).folder '/' d(ID).name]);
        disp([k ID])
        for m = 1:3
            % Extract a 2-second segment starting at offset (m-1)*2.5 s
            y_sub = ufilterbank(y_p(2*(m-1)*fs+1+(m-1)*fs/2:(m-1)*fs/2+2*m*fs,1),g,1)';
            [dey_sub eyf_sub] = Subband_Envelopes(y_sub,fs,fs_d,compression,'hilbert',fcc);
            deym_sub = mfilterbank(dey_sub,mfb);
            X{k-11,ID,m} = Meas_SynthStats(dey_sub,deym_sub,mfb_mode);
        end
    end
end

%%
% Save statistics to disk — use v7.3 format for large cell arrays
save('X2_v2.mat','X','-v7.3')

%%
% --- Distance computation (can be run independently by loading X2.mat) ---
clear all
load X2_v2.mat

%%
ds = dir('_sounds/_dis*');

% Unpack each statistics class into a 4-D array (feature x sound_family x file x segment)
% so that zscore operates across sounds simultaneously
for n = 1:size(X,1)
    for m = 1:size(X,2)
        for k = 1:size(X,3)
            Z1(:,n,m,k) = X{n,m,k}.Mx(:,1); % envelope mean per subband
            Z2(:,n,m,k) = X{n,m,k}.Mx(:,2); % envelope variance per subband
            Z3(:,n,m,k) = X{n,m,k}.Mx(:,3); % envelope skewness per subband
            Z4(:,n,m,k) = nonzeros(X{n,m,k}.Cx);  % subband envelope correlations
            Z5(:,n,m,k) = nonzeros(X{n,m,k}.MPx); % modulation power
            Z6(:,n,m,k) = nonzeros(X{n,m,k}.MCx); % modulation cross-correlations
        end
    end
end

% Z-score each statistics class across the sound dimension so that all
% features contribute equally to the distance metric
Z1 = zscore(Z1);
Z2 = zscore(Z2);
Z3 = zscore(Z3);
Z4 = zscore(Z4);
Z5 = zscore(Z5);
Z6 = zscore(Z6);

% Pack z-scored statistics back into a struct cell array Y (same layout as X)
for n = 1:size(X,1)
    for m = 1:size(X,2)
        for k = 1:size(X,3)
            Y{n,m,k}.Mx(:,1) = Z1(:,n,m,k);
            Y{n,m,k}.Mx(:,2) = Z2(:,n,m,k);
            Y{n,m,k}.Mx(:,3) = Z3(:,n,m,k);
            Y{n,m,k}.Cx  = Z4(:,n,m,k);
            Y{n,m,k}.MPx = Z5(:,n,m,k);
            Y{n,m,k}.MCx = Z6(:,n,m,k);
        end
    end
end

%%
% Compute pairwise distances between each sound and the other two sounds in
% the same 3-AFC trial. kk maps interval index k to the "other" interval.
% Gaussian noise (scaled by NX per statistics class) is added before
% computing distance to model internal neural noise.
% Note: NX(5) differs from task 1a (9 vs 8) — fitted separately per task.
%
% p dimensions: (sound_family, file, interval_pair, stats_class)
%   interval_pair: 1=self-vs-2, 2=self-vs-3, 3=self-vs-1
%   stats_class:   1=Mx(mean), 2=Mx(var), 3=Mx(skew), 4=Cx, 5=MPx, 6=MCx
dst = 'euclidean';
kk = [2 3 1]; % for interval k, kk(k) is the other interval
NX = [1 1 2 1 8 5]/2; % noise scale per statistics class
for n = 1:size(Y,1)
    disp(n)
    for m = 1:size(Y,2)
        for k = 1:3
            p(n,m,k,1) = pdist([Y{n,m,k}.Mx(:,1)+randn(36,1)*NX(1) Y{n,m,kk(k)}.Mx(:,1)+randn(36,1)*NX(1)]',dst)/numel(Y{n,m,k}.Mx(:,1));
            p(n,m,k,2) = pdist([Y{n,m,k}.Mx(:,2)+randn(36,1)*NX(2) Y{n,m,kk(k)}.Mx(:,2)+randn(36,1)*NX(2)]',dst)/numel(Y{n,m,k}.Mx(:,2));
            p(n,m,k,3) = pdist([Y{n,m,k}.Mx(:,3)+randn(36,1)*NX(3) Y{n,m,kk(k)}.Mx(:,3)+randn(36,1)*NX(3)]',dst)/numel(Y{n,m,k}.Mx(:,3));
            p(n,m,k,4) = pdist([nonzeros(Y{n,m,k}.Cx)+randn(1296,1)*NX(4) nonzeros(Y{n,m,kk(k)}.Cx)+randn(1296,1)*NX(4)]',dst)/numel(nonzeros(Y{n,m,kk(k)}.Cx));
            p(n,m,k,5) = pdist([nonzeros(Y{n,m,k}.MPx)+randn(684,1)*NX(5) nonzeros(Y{n,m,kk(k)}.MPx)+randn(684,1)*NX(5)]',dst)/numel(nonzeros(Y{n,m,kk(k)}.MPx));
            p(n,m,k,6) = pdist([nonzeros(Y{n,m,k}.MCx)+randn(3306,1)*NX(6) nonzeros(Y{n,m,kk(k)}.MCx)+randn(3306,1)*NX(6)]',dst)/numel(nonzeros(Y{n,m,kk(k)}.MCx));
        end
    end
end

%%
save('p2_v3.mat','p')

%%
% --- Task simulation (can be run independently by loading p2_v2.mat) ---
clear all
load('p2_v2.mat')


%%
clearvars -except p
% ds = dir('_sounds/_dis*');
load('ds.mat')
load('dsn1b.mat')
CR = [];
np = 0.04; % decision noise: small Gaussian jitter added to summed distances before argmin

% Simulate the 3-AFC task 1000 times and average to get stable proportion correct.
% Sound families for task 1b are indices 12-22 (offset +11 relative to ds).
% On each trial the model picks the interval with the minimum total distance
% (summed across all statistics classes) after adding decision noise.
for k = 1:1000
    for n = 1:size(p,1)
        % d = dir([ds(n+11).folder '/' ds(n+11).name '/*.wav']);
        d = dsn{n};
        for m = 1:size(p,2)
            % Pick interval with smallest summed distance across stats classes
            [~,I] = min(np*randn(3,1) + sum(squeeze(p(n,m,:,:)),2));
            % Map model interval choice to target position (cyclic: 1->3, 2->1, 3->2)
            if I == 1
                R = 3;
            elseif I == 2
                R = 1;
            elseif I == 3
                R = 2;
            end

            % Decode the correct target position from the filename
            I = strfind(d(m).name,'TP');
            if str2num(d(m).name(I+2)) == R
                CR(n,m,k) = 1;
            else
                CR(n,m,k) = 0;
            end
        end
    end
end

% Average proportion correct over simulation iterations
CR = mean(CR,3);

%%
% Reshape performance into the N1/N2 condition structure used in the figures.
% Task 1b has a 5x6 off-diagonal grid (300 trials) plus 60 diagonal trials.
% v{d} collects anti-diagonal entries at lag d; vx{d} re-orders them by N1.
% v{6} holds the diagonal (N1 == N2) conditions from ud2a.
for n = 1:size(p,1)
    ud1  = reshape(CR(n,1:300),5,6,10);   % 5 N1 levels x 6 N2 levels x 10 repeats
    ud2a(:,:) = reshape(CR(n,301:360),6,10); % diagonal: 6 N1=N2 levels x 10 repeats

    udm(:,:) = mean(ud1,3);
    v{1}(:,n) = mean([udm(:,6)';udm(5,1:5)]);
    v{2}(:,n) = mean([udm(1:4,5)';udm(4,1:4)]);
    v{3}(:,n) = mean([udm(1:3,4)';udm(3,1:3)]);
    v{4}(:,n) = mean([udm(1:2,3)';udm(2,1:2)]);
    v{5}(:,n) = mean([udm(1,2)';udm(1,1)]);
    v{6}(:,n) = mean(ud2a,2);
end

% Reorder each off-diagonal group so conditions are sorted by increasing N1
vx{1} = flipud([v{1}(1,:);v{2}(1,:);v{3}(1,:);v{4}(1,:);v{5}(1,:)]);
vx{2} = flipud([v{1}(2,:);v{2}(2,:);v{3}(2,:);v{4}(2,:)]);
vx{3} = flipud([v{1}(3,:);v{2}(3,:);v{3}(3,:)]);
vx{4} = flipud([v{1}(4,:);v{2}(4,:)]);
vx{5} = flipud([v{1}(5,:)]);
vx{6} = v{6};

for n = 1:length(vx)
    vm{n}    = mean(vx{n},2); % mean over sound families
    vm_sd{n} = std(vx{n},[],2);
end

%%
% Load human behavioural data and print mean proportion correct for a quick check
v1b = load('v1b.mat'); % human data: fields vm (mean per condition) and vx (per-subject)

v1x = [];
for k = 1:length(v1b.v)
    v1x = [v1x v1b.v{k}'];
end

[mean(v1x,'all') mean(CR,'all')] % [human model] overall proportion correct

%%
% --- Figure: proportion correct vs N1/N2 condition ---
figure(1)
c = colororder;
c = c([3:6 2 1],:);     % one colour per off-diagonal lag group + diagonal (6th colour differs from 1a)
dx = [0.95 0.95 0.95];  % near-white for open marker faces (model)
set(gcf,'position',[100 100 1000 400])

% Left panel: off-diagonal conditions (N1 != N2)
subplot('position',[0.1 0.1 0.5 0.8])
hold on

% x-axis positions for each off-diagonal lag group (offset +0.2 for model in 1b)
xL{1} = [1:5]+0.2;
xL{2} = [7:10]+0.2;
xL{3} = [12:14]+0.2;
xL{4} = [16:17]+0.2;
xL{5} = [19]+0.2;
xL{6} = [21:26]+0.2;

dof = 0;
for n = 1:length(xL)-1
    se = std(v1b.vx{n},[],2)/sqrt(size(v1b.vx{n},2)); % human SEM across participants
    sd = std(v{n},[],2)/2;                               % model SD across sound families
    if n < 5
        % Shaded error band: model (SD) and human (SEM)
        patch([xL{n} fliplr(xL{n})],[vm{n}'+sd' fliplr(vm{n}'-sd')],c(n,:),'FaceAlpha',0.2,'EdgeAlpha',0)
        patch([xL{n} fliplr(xL{n})],[v1b.vm{n}'+se' fliplr(v1b.vm{n}'-se')],c(n,:),'FaceAlpha',0.2,'EdgeAlpha',0)
        plot(xL{n}-dof,vm{n},'-.','Color',c(n,:),'linewidth',2)
        plot(xL{n}-dof,vm{n},'s','MarkerFaceColor',dx,'MarkerEdgeColor',c(n,:),'MarkerSize',10,'linewidth',1.5)
        plot(xL{n},v1b.vm{n},'-','Color',c(n,:),'linewidth',2)
        plot(xL{n},v1b.vm{n},'s','MarkerFaceColor',c(n,:),'MarkerEdgeColor',dx,'MarkerSize',10,'linewidth',1.5)
    else
        % Single-point condition: use rectangular patch for error band
        patch([xL{n}-0.25 fliplr(xL{n})-0.25 fliplr(xL{n})+0.25 xL{n}+0.25],...
            [vm{n}'+sd' fliplr(vm{n}'-sd') fliplr(vm{n}'-sd') vm{n}'+sd'],...
            c(n,:),'FaceAlpha',0.2,'EdgeAlpha',0)
        patch([xL{n}-0.25 fliplr(xL{n})-0.25 fliplr(xL{n})+0.25 xL{n}+0.25],...
            [v1b.vm{n}'+se' fliplr(v1b.vm{n}'-se') fliplr(v1b.vm{n}'-se') v1b.vm{n}'+se'],...
            c(n,:),'FaceAlpha',0.2,'EdgeAlpha',0)
        plot(xL{n}-dof,vm{n},'-.','Color',c(n,:),'linewidth',2)
        plot(xL{n}-dof,vm{n},'s','MarkerFaceColor',dx,'MarkerEdgeColor',c(n,:),'MarkerSize',10,'linewidth',1.5)
        plot(xL{n},v1b.vm{n},'-','Color',c(n,:),'linewidth',2)
        plot(xL{n},v1b.vm{n},'s','MarkerFaceColor',c(n,:),'MarkerEdgeColor',dx,'MarkerSize',10,'linewidth',1.5)
    end
end

% Label the x-axis with N2 values; N1 is shown via colour group
xl = [1:5 7:10 12:14 16:17 19];
N1 = [1 1 1 1 1 2 2 2 2 4 4 4 8 8 16];
N2 = [2 4 8 16 32 4 8 16 32 8 16 32 16 32 32];
set(gca,'YLim',[0.15 1.05],'XLim',[0 20],'fontsize',14)
set(gca,'XTick',xl,'XTickLabel',[])
line([0 20],[.33 .33],'color','k','linestyle',':') % chance level for 3-AFC
text(-1,0.11,'N2','fontsize',14)
for k = 1:length(xl)
    text(xl(k),0.11,num2str(N2(k)),'HorizontalAlignment','Center','fontsize',14)
end
ylabel('Proportion Correct')

% Right panel: diagonal conditions (N1 == N2)
subplot('position',[0.7 0.1 0.2 0.8])
hold on

xL{6} = 1:6;
sd = std(v{6},[],2)/2;
patch([xL{6} fliplr(xL{6})],[vm{6}'+sd' fliplr(vm{6}'-sd')],c(6,:),'FaceAlpha',0.2,'EdgeAlpha',0)
plot(xL{6},vm{6},'-.','Color',c(6,:),'linewidth',2)
pp(1) = plot(xL{6},vm{6},'s','MarkerFaceColor',dx,'MarkerEdgeColor',c(6,:),'MarkerSize',10,'linewidth',1.5);

se = std(v1b.vx{6},[],2)/sqrt(size(v1b.vx,2));
patch([xL{6} fliplr(xL{6})],[v1b.vm{6}'+se' fliplr(v1b.vm{6}'-se')],c(6,:),'FaceAlpha',0.2,'EdgeAlpha',0)
plot(xL{6},v1b.vm{6},'-','Color',c(6,:),'linewidth',2)
pp(2) = plot(xL{6},v1b.vm{6},'s','MarkerFaceColor',c(6,:),'MarkerEdgeColor',dx,'MarkerSize',10,'linewidth',1.5);

xl = [1:6];
N1 = [1 2 4 8 16 32];
N2 = [1 2 4 8 16 32];
set(gca,'YLim',[0.15 1.05],'XLim',[0 7],'fontsize',14)
set(gca,'XTick',xl,'XTickLabel',N1)
line([0 7],[.33 .33],'color','k','linestyle',':')
ylabel('Proportion Correct')
legend(pp,{'Human','Model'},'Location','SouthEast','box','off')
