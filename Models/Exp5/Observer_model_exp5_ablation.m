function Observer_model_exp5_ablation
% Observer_model_exp5_ablation
% Ablation study: runs the observer model for every subset of the 6
% auditory texture statistic classes, then plots model fit vs. human data.
%
% Statistics classes (indexed 1-6):
%   1 - Envelope Mean
%   2 - Envelope Coefficient of Variation
%   3 - Envelope Skewness
%   4 - Envelope Correlation
%   5 - Modulation Power
%   6 - Modulation Correlation
%
% There are sum(nchoosek(6,k), k=1..6) = 63 non-empty subsets.
% kkx (63 x 6) encodes each subset: row n lists the included class indices,
% padded with zeros.
%
% Section 1 - Run model for all 63 subsets -> exp5_model_ablation/
% Section 2 - Plot per-subset result figure (one figure per subset)
% Section 3 - Aggregated summary figure: error bar chart + 4 example subplots

%%  SECTION 1: Run ablation for all 63 statistic subsets

clear all

addpath(genpath('_ltfat'))
addpath(genpath('_minFunc_2012'))
addpath(genpath('_sts'))
mfb_mode = 'halfoctave';
AudSys_Setup(mfb_mode);
load(['_system/AudSys_Setup_' mfb_mode '.mat'])


load('exp5_stim_name.mat')

% Reassemble full Z cell array from per-subject files
for n = 1:50
    load(['_statz/Z' num2str(n) '.mat'])
    for k = 1:1050
        Z{(n-1)*1050+k} = ZZ{k};
    end
end

% Build kkx: enumerate all non-empty subsets of {1..6} in order of size
% Row n contains the included class indices (zero-padded to width 6)
kkx = zeros(63,6);
kk = 0;
for k = 1:6
    kx = nchoosek(1:6,k);   % all size-k subsets
    ks = size(kx);
    for n = 1:ks(1)
        kk = kk + 1;
        kkx(kk,1:ks(2)) = kx(n,:);
    end
end

% Run model for each subset (nt=n identifies which subset for file naming)
for n = 1:63
    for kk = 1:20%size(NP,1)
        run_model_ablation(d,Z,[1 1 2 1 8 5],kk,'rspZ3y',kkx(n,:),n);
    end
end


%%  SECTION 2: Per-subset result figures
% For each of the 63 subsets, load results and plot model vs. human data.

clear all
for nk = 1:63
    d = dir(['exp5_model_ablation/*_' num2str(nk) '.mat']);

    for k = 1:length(d)
        load([d(k).folder '/' d(k).name]);
        rspXX(k,:) = mean(mean(rsp,3));
    end

    rspX = mean(rspXX,3);

    rspX_pct = mean(prctile(rspXX,[2.5 97.5]),3);
    rspX_sd  = (rspX_pct(2,:)-rspX_pct(1,:))/2;

    load('expv8_N27.mat')
    if size(udsm,1) == 1
        udm = mean(udsm,1);
    else
        udm = mean(udsm,2);
    end
    se = std(udsm,[],2)/sqrt(size(udsm,2));

    udX = mean(udsm,2)';

    for k = 1:length(d)
        ErrX(k) = sum(abs(rspX(k,[1:7])-udX([1:7])));
    end

    rspX = mean(rspX);

    figure
    c = colororder;
    hold on

    bar(1:3,udm([1 2 7]),'facecolor',c(1,:),'facealpha',1/4,'edgealpha',0);
    bar(5,udm([3]),'facecolor',c(1,:),'facealpha',0.75/4,'edgealpha',0);
    bar(6,udm([4]),'facecolor',c(1,:),'facealpha',0.5/4,'edgealpha',0);
    bar(7,udm([5]),'facecolor',c(1,:),'facealpha',0.5/4,'edgealpha',0);
    bar(8,udm([6]),'facecolor',c(1,:),'facealpha',0.25/4,'edgealpha',0);
    e = errorbar([1:3 5:8],udm([1 2 7 3 4 5 6]),se,'color',[0.75 0.75 0.75]);
    e.CapSize = 0;
    e.LineWidth = 2;
    e.LineStyle = 'none';
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

    e = errorbar([1:3 5:8]-0.25,rspX([1 2 7 3 4 5 6]),rspX_sd,'color',c(1,:));
    e.CapSize = 0;
    e.LineWidth = 2;
    e.LineStyle = 'none';

    plot([1:3 5:8]-0.25,rspX([1 2 7 3 4 5 6]),'s','MarkerFaceColor',[0.85 0.85 0.85],...
        'MarkerEdgeColor',c(1,:),'MarkerSize',10,'linewidth',1)
end

%%  SECTION 3: Aggregated summary figure
% Top panel: bar chart of mean fit error for all 63 subsets with 95% CI,
%   x-axis labels show which classes were included.
% Bottom panels: example per-condition plots for subsets 1, 19, 34, 63
%   (representing 1-class, mid-range, and full 6-class models).

clear all

% Rebuild kkx (same enumeration as Section 1)
kkx = zeros(63,6);
kk = 0;
for k = 1:6
    kx = nchoosek(1:6,k);
    ks = size(kx);
    for n = 1:ks(1)
        kk = kk + 1;
        kkx(kk,1:ks(2)) = kx(n,:);
    end
end

% Accumulate per-subset error and predictions across all 63 subsets
for nk = 1:63
    d = dir(['exp5_model_ablation/*_' num2str(nk) '.mat']);

    for k = 1:length(d)
        load([d(k).folder '/' d(k).name]);
        rspXX(k,:) = mean(mean(rsp,3));
    end

    rspX = mean(rspXX,3);

    rspX_pct(:,:,nk) = mean(prctile(rspXX,[2.5 97.5]),3);

    load('expv8_N27.mat')
    if size(udsm,1) == 1
        udm = mean(udsm,1);
    else
        udm = mean(udsm,2);
    end
    se = std(udsm,[],2)/sqrt(size(udsm,2));

    udX = mean(udsm,2)';

    for k = 1:length(d)
        ErrX(k,nk) = sum(abs(rspX(k,[1:7])-udX([1:7])));
    end
    Atm_ci(nk,:) = prctile(ErrX(:,nk),[2.5 97.5]);  % CI over runs

    RspX_out(:,nk) = mean(rspX);  % mean prediction per condition per subset

end

% --- Top panel: error bar chart across 63 subsets ---
figure
set(gcf,'position',[200 200 1200 800])
subplot('position',[0.1 0.6 0.8 0.35])
hold on
c = colororder;
b = bar(mean(ErrX));
b.EdgeAlpha = 0;
b.FaceColor = [0.5 0.5 0.5];
for k = 1:63
    line([k k],Atm_ci(k,:),'color',[0.75 0.75 0.75],'linewidth',2)
end
set(gca,'YLim',[0 3])
set(gca,'XTick',[1:63],'XTickLabel',[])
set(gca,'TickDir','out')
% Label x-axis with included class indices (rotated 45 degrees)
for k = 1:63
    I = find(kkx(k,:) ~= 0);
    text(k+0.25,-0.05,num2str(kkx(k,I)),'horizontalalignment','right','Rotation',45)
end
ylabel('Mean Squared Error','FontSize',14)
% Legend for class numbering
text(52,2.6,'Statistics Classes','horizontalalignment','left','fontweight','bold')
text(52,2.5,'1 - Envelope Mean','horizontalalignment','left')
text(52,2.4,'2 - Envelope Coeff. of Variation','horizontalalignment','left')
text(52,2.3,'3 - Envelope Skewness','horizontalalignment','left')
text(52,2.2,'4 - Envelope Correlation','horizontalalignment','left')
text(52,2.1,'5 - Modulation Power','horizontalalignment','left')
text(52,2.0,'6 - Modulation Correlation','horizontalalignment','left')
text(32,-0.5,'Statistics Class Included in Model','horizontalalignment','center','FontSize',14)


% --- Bottom panels: example subsets 1, 19, 34, 63 ---
% Subset 1:  single class (first 1-class subset)
% Subset 19: first 3-class subset
% Subset 34: first 4-class subset
% Subset 63: all 6 classes (full model)

subplot('position',[0.075 0.1 0.2 0.35])
hold on
bar(1:3,udm([1 2 7]),'facecolor',c(1,:),'facealpha',1/4,'edgealpha',0);
bar(5,udm([3]),'facecolor',c(1,:),'facealpha',0.75/4,'edgealpha',0);
bar(6,udm([4]),'facecolor',c(1,:),'facealpha',0.5/4,'edgealpha',0);
bar(7,udm([5]),'facecolor',c(1,:),'facealpha',0.5/4,'edgealpha',0);
bar(8,udm([6]),'facecolor',c(1,:),'facealpha',0.25/4,'edgealpha',0);
e = errorbar([1:3 5:8],udm([1 2 7 3 4 5 6]),se,'color',[0.75 0.75 0.75]);
e.CapSize = 0;
e.LineWidth = 2;
e.LineStyle = 'none';
line([2 8.5],[udm(2) udm(2)],'color','k','linestyle',':')
line([-0.2 9.2],[0.33 0.33],'color','k','linestyle','-.','color',[0.6 0.6 0.6],'linewidth',2)
set(gca,'XTick',[1:3 5:8],'XTickLabel',{'1','8','32','8+1','8+1*','8+8','8+8*'},'fontsize',14)
set(gca,'YLim',[0.3 1])
xlabel('Chorus size')
ylabel('Proportion correct','FontSize',16)
I = find(kkx(1,:) ~= 0);
title(num2str(kkx(1,I)),'fontsize',16)
set(gca,'TickDir','out');
kk = [1 2 7 3 4 5 6];
xt = [1:3 5:8]-0.25;
for k = 1:7
    line([xt(k) xt(k)],[rspX_pct(1,kk(k),1) rspX_pct(2,kk(k),1)],'linewidth',2,'color',c(1,:))
end
plot([1:3 5:8]-0.25,RspX_out([1 2 7 3 4 5 6],1),'s','MarkerFaceColor',[0.85 0.85 0.85],...
    'MarkerEdgeColor',c(1,:),'MarkerSize',8,'linewidth',1)

subplot('position',[0.3 0.1 0.2 0.35])
hold on
bar(1:3,udm([1 2 7]),'facecolor',c(1,:),'facealpha',1/4,'edgealpha',0);
bar(5,udm([3]),'facecolor',c(1,:),'facealpha',0.75/4,'edgealpha',0);
bar(6,udm([4]),'facecolor',c(1,:),'facealpha',0.5/4,'edgealpha',0);
bar(7,udm([5]),'facecolor',c(1,:),'facealpha',0.5/4,'edgealpha',0);
bar(8,udm([6]),'facecolor',c(1,:),'facealpha',0.25/4,'edgealpha',0);
e = errorbar([1:3 5:8],udm([1 2 7 3 4 5 6]),se,'color',[0.75 0.75 0.75]);
e.CapSize = 0;
e.LineWidth = 2;
e.LineStyle = 'none';
line([2 8.5],[udm(2) udm(2)],'color','k','linestyle',':')
line([-0.2 9.2],[0.33 0.33],'color','k','linestyle','-.','color',[0.6 0.6 0.6],'linewidth',2)
set(gca,'XTick',[1:3 5:8],'XTickLabel',{'1','8','32','8+1','8+1*','8+8','8+8*'},'fontsize',14)
set(gca,'YLim',[0.3 1])
xlabel('Chorus size')
I = find(kkx(19,:) ~= 0);
title(num2str(kkx(19,I)),'fontsize',16)
set(gca,'TickDir','out');
kk = [1 2 7 3 4 5 6];
xt = [1:3 5:8]-0.25;
for k = 1:7
    line([xt(k) xt(k)],[rspX_pct(1,kk(k),19) rspX_pct(2,kk(k),19)],'linewidth',2,'color',c(1,:))
end
plot([1:3 5:8]-0.25,RspX_out([1 2 7 3 4 5 6],19),'s','MarkerFaceColor',[0.85 0.85 0.85],...
    'MarkerEdgeColor',c(1,:),'MarkerSize',8,'linewidth',1)

subplot('position',[0.525 0.1 0.2 0.35])
hold on
bar(1:3,udm([1 2 7]),'facecolor',c(1,:),'facealpha',1/4,'edgealpha',0);
bar(5,udm([3]),'facecolor',c(1,:),'facealpha',0.75/4,'edgealpha',0);
bar(6,udm([4]),'facecolor',c(1,:),'facealpha',0.5/4,'edgealpha',0);
bar(7,udm([5]),'facecolor',c(1,:),'facealpha',0.5/4,'edgealpha',0);
bar(8,udm([6]),'facecolor',c(1,:),'facealpha',0.25/4,'edgealpha',0);
e = errorbar([1:3 5:8],udm([1 2 7 3 4 5 6]),se,'color',[0.75 0.75 0.75]);
e.CapSize = 0;
e.LineWidth = 2;
e.LineStyle = 'none';
line([2 8.5],[udm(2) udm(2)],'color','k','linestyle',':')
line([-0.2 9.2],[0.33 0.33],'color','k','linestyle','-.','color',[0.6 0.6 0.6],'linewidth',2)
set(gca,'XTick',[1:3 5:8],'XTickLabel',{'1','8','32','8+1','8+1*','8+8','8+8*'},'fontsize',14)
set(gca,'YLim',[0.3 1])
xlabel('Chorus size')
I = find(kkx(34,:) ~= 0);
title(num2str(kkx(34,I)),'fontsize',16)
set(gca,'TickDir','out');
kk = [1 2 7 3 4 5 6];
xt = [1:3 5:8]-0.25;
for k = 1:7
    line([xt(k) xt(k)],[rspX_pct(1,kk(k),34) rspX_pct(2,kk(k),34)],'linewidth',2,'color',c(1,:))
end
plot([1:3 5:8]-0.25,RspX_out([1 2 7 3 4 5 6],34),'s','MarkerFaceColor',[0.85 0.85 0.85],...
    'MarkerEdgeColor',c(1,:),'MarkerSize',8,'linewidth',1)


subplot('position',[0.75 0.1 0.2 0.35])
hold on
bar(1:3,udm([1 2 7]),'facecolor',c(1,:),'facealpha',1/4,'edgealpha',0);
bar(5,udm([3]),'facecolor',c(1,:),'facealpha',0.75/4,'edgealpha',0);
bar(6,udm([4]),'facecolor',c(1,:),'facealpha',0.5/4,'edgealpha',0);
bar(7,udm([5]),'facecolor',c(1,:),'facealpha',0.5/4,'edgealpha',0);
bar(8,udm([6]),'facecolor',c(1,:),'facealpha',0.25/4,'edgealpha',0);
e = errorbar([1:3 5:8],udm([1 2 7 3 4 5 6]),se,'color',[0.75 0.75 0.75]);
e.CapSize = 0;
e.LineWidth = 2;
e.LineStyle = 'none';
line([2 8.5],[udm(2) udm(2)],'color','k','linestyle',':')
line([-0.2 9.2],[0.33 0.33],'color','k','linestyle','-.','color',[0.6 0.6 0.6],'linewidth',2)
text(8.5,0.35,'chance','color',[0.6 0.6 0.6])
set(gca,'XTick',[1:3 5:8],'XTickLabel',{'1','8','32','8+1','8+1*','8+8','8+8*'},'fontsize',14)
set(gca,'YLim',[0.3 1])
xlabel('Chorus size')
I = find(kkx(63,:) ~= 0);
title(num2str(kkx(63,I)),'fontsize',16)
text(8,0.95,['n = ' num2str(size(udsm,2))],'fontsize',14)
set(gca,'TickDir','out');
kk = [1 2 7 3 4 5 6];
xt = [1:3 5:8]-0.25;
for k = 1:7
    line([xt(k) xt(k)],[rspX_pct(1,kk(k),63) rspX_pct(2,kk(k),63)],'linewidth',2,'color',c(1,:))
end
plot([1:3 5:8]-0.25,RspX_out([1 2 7 3 4 5 6],63),'s','MarkerFaceColor',[0.85 0.85 0.85],...
    'MarkerEdgeColor',c(1,:),'MarkerSize',8,'linewidth',1)
