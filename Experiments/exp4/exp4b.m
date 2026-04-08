function exp4b
% exp4b - Experiment 4b: Per-condition and per-pair discrimination results
%
% Loads participant accuracy data from Exp4b.mat and produces two figures:
%
%   Figure 1 - Bar chart comparing mean proportion correct across three
%   discrimination conditions at a fixed chorus size:
%     Column 1 (MX_results3(:,1)): Same Species discrimination
%     Column 2 (MX_results3(:,2)): Mixture discrimination
%     Column 3 (MX_results3(:,3)): Different Species discrimination
%   Individual data points and 2*SEM error bars are overlaid.
%
%   Figure 2 - Per-pair performance across all 45 species-pair combinations,
%   showing mixture (MX) and species (SX) discrimination accuracy side by side,
%   with individual-level mixture performance (MXi) shown as a shaded band.

%%
clear all
load('Exp4b.mat')

% --- Figure 1: Summary bar chart by condition ---
figure
set(gcf,'position',[200 200 400 600])
c = colororder;
hold on

% Chance-level reference line (1/3 for 3-AFC)
line([0 4],[0.33 0.33],'linewidth',2,'linestyle',':','color',[0.8 0.8 0.8])
text(3.5,0.35,'chance','color',[0.8 0.8 0.8],'fontsize',14)

% Bars: mean proportion correct per condition
bar(1,mean(MX_results3(:,1)),'facecolor',c(2,:),'facealpha',0.5)  % Individuals
bar(2,mean(MX_results3(:,2)),'facecolor',c(3,:),'facealpha',0.5)  % Mixtures
bar(3,mean(MX_results3(:,3)),'facecolor',c(1,:),'facealpha',0.5)  % Species

% Scatter individual participant data points, jittered horizontally
x = linspace(0.95,1.05,size(MX_results3,1));
se = std(MX_results3)/sqrt(length(MX_results3));
sd2 = std(MX_results3)*2;
for k = 1:size(MX_results3,1)
    plot(x(k)+.1,MX_results3(k,1),'o','MarkerFaceColor',c(2,:),'MarkerEdgeColor',[0.8 0.8 0.8],'MarkerSize',8)
    plot(x(k)+1.1,MX_results3(k,2),'o','MarkerFaceColor',c(3,:),'MarkerEdgeColor',[0.8 0.8 0.8],'MarkerSize',8)
    plot(x(k)+2.1,MX_results3(k,3),'o','MarkerFaceColor',c(1,:),'MarkerEdgeColor',[0.8 0.8 0.8],'MarkerSize',8)
end

% Overlay 2*SEM error bars and diamond markers for the mean
kk = [2 3 1];  % color index mapping: bar 1->c(2), bar 2->c(3), bar 3->c(1)
for k = 1:3
    eb1 = errorbar(k-0.1,mean(MX_results3(:,k)),2*se(k));
    eb1.CapSize = 0;
    eb1.LineWidth = 2;
    eb1.Color = c(kk(k),:);
    plot(k-0.1,mean(MX_results3(:,k)),'d','MarkerFaceColor',c(kk(k),:),'MarkerEdgeColor',[0.8 0.8 0.8],'MarkerSize',10,'linewidth',1.5)
end

set(gca,'YLim',[0.25 1],'FontSize',12)
set(gca,'XTick',[1:3],'XTickLabel',{'Individiuals','Mixtures','Species'},'FontSize',12)
text(0.25,0.95,['n = ' num2str(size(MX_results3,1))],'fontsize',14)
ylabel('Proportion Correct')

%% --- Figure 2: Per-pair performance across all 45 species-pair combinations ---
c = colororder;

% Species labels for the legend
sl = {'Crow','Chaffinch','Chiffchaff','Firecrest','Dunnock','Eur. Blackbird',...
    'Eur. Bluetit','Eur. Jay','Song Thrush','Willow Warbler'};

% Colormaps grading from white to the mixture (c3) and species (c1) colors
cmap = [linspace(1,c(3,1),45)' linspace(1,c(3,2),45)' linspace(1,c(3,3),45)'];
cmap2 = [linspace(1,c(1,1),45)' linspace(1,c(1,2),45)' linspace(1,c(1,3),45)'];

figure
set(gcf,'position',[200 200 1200 300])
subplot('position',[0.05 0.2 0.7 0.75])
hold on

% Loop over all 45 species pairs, sorted by mixture performance (Ik)
for k = 1:size(cmap,1)
    % Bar height = mean mixture discrimination accuracy for this pair
    bar(k,MXn_temp(Ik(k)),'FaceColor',cmap(round(MXn_temp(Ik(k))*45),:),'EdgeColor',[0.9 0.9 0.9],'FaceAlpha',1)

    % Asymmetric error bars for mixture accuracy (lower / upper separately)
    eb1a = errorbar(k-0.1,MXn_temp(Ik(k)),MXn_std_temp(Ik(k)),0);
    eb1b = errorbar(k-0.1,MXn_temp(Ik(k)),0,MXn_std_temp(Ik(k)));
    eb1a.CapSize = 0;
    eb1b.CapSize = 0;
    eb1a.Color = cmap(1,:);
    eb1b.Color = cmap(end,:);
    eb1a.LineWidth = 1;
    eb1b.LineWidth = 1;

    % Circle marker for mixture mean
    plot(k-0.1,MXn_temp(Ik(k)),'o','MarkerFaceColor',cmap(round(MXn_temp(Ik(k))*45),:),'MarkerEdgeColor',[0.9 0.9 0.9],'linewidth',1)

    % Error bar and square marker for species discrimination accuracy
    eb2 = errorbar(k+0.1,SXn_temp(Ik(k)),SXn_std_temp(Ik(k)));
    eb2.CapSize = 0;
    eb2.Color = cmap2(round(SXn_temp(Ik(k))*45),:);
    eb2.LineWidth = 1;
    plot(k+0.1,SXn_temp(Ik(k)),'s','MarkerFaceColor',cmap2(round(SXn_temp(Ik(k))*45),:),...
        'MarkerEdgeColor',[0.9 0.9 0.9],'linewidth',1,'MarkerSize',8)

    % X-tick label: species index pair (i,j)
    xtl{k} = [num2str(i(Ik(k))) ',' num2str(j(Ik(k)))];

    % Shaded band showing individual-level mixture accuracy (MXi) +/- 1 SD
    patch(k+[0 0.3 0.3 0],[MXi_temp(Ik(k))+MXi_std_temp(Ik(k)) ...
                                 MXi_temp(Ik(k))+MXi_std_temp(Ik(k)) ...
                                 MXi_temp(Ik(k))-MXi_std_temp(Ik(k)) ...
                                 MXi_temp(Ik(k))-MXi_std_temp(Ik(k))],c(2,:),'EdgeAlpha',0,'FaceAlpha',0.22)
    line(k+[0 0.3],[MXi_temp(Ik(k)) MXi_temp(Ik(k))],'linestyle','-','color',c(2,:),'linewidth',2)
end

% Chance reference line across all pairs
line([0.6 45.4],[1 1]./3,'linestyle',':','color',[0.4 0.4 0.4],'linewidth',2)

% MX1mean = mean(MX_results3(:,1));
% MX1se = std(MX_results3(:,1))/sqrt(length(MX_results3(:,1)));
% line([0.6 45.4],[MX1mean MX1mean],'linestyle','-','color',c(2,:),'linewidth',2)
% patch([0.6 45.4 45.4 0.6],[MX1mean+MX1se MX1mean+MX1se MX1mean-MX1se MX1mean-MX1se],c(2,:),'EdgeAlpha',0,'FaceAlpha',0.22)

set(gca,'XTick',1:45,'XTickLabel',xtl,'fontsize',10)
set(gca,'XLim',[0 46])
set(gca,'YLim',[0.3 1.0333])
xlabel('Sound Pairs','fontsize',12)
ylabel('Proportion Correct','fontsize',12)
set(gca,'TickDir','out');

text(0.25,0.95,['n = ' num2str(size(MX_results3,1))],'fontsize',12)

% Species legend (printed outside the plot area)
for k = 1:9
    text(50,1-k/15,[num2str(k) '. ' sl{k}],'fontsize',12)
end
text(49.6,1-10/15,[num2str(10) '. ' sl{10}],'fontsize',12)
