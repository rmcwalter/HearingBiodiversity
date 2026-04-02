function measure_bird_stats
% MEASURE_BIRD_STATS  Compute and compare auditory texture statistics across
% ten European bird species using the Sound Texture Synthesis (STS) framework.
%
% This function:
%   1. Discovers all .wav recordings for each species.
%   2. Validates and resamples audio to 48 kHz as needed.
%   3. Extracts auditory subband envelopes and modulation-filterbank features.
%   4. Computes synthesis statistics (Meas_SynthStats) for each recording.
%   5. Saves per-recording stats to '_stats/' and a pairwise distance matrix
%      to 'bird_stats_pdist_v2.mat'.
%   6. Plots two distance-matrix figures: one species-averaged, one per-recording.
%
%  Author: Richard McWalter
%
%%  --- Initialisation ---

clear all

% Add required toolboxes: LTFAT (filterbanks), minFunc (optimisation), STS core
addpath(genpath('_ltfat'))
addpath(genpath('_minFunc_2012'))
addpath(genpath('_sts'))

% Set up the auditory filterbank in half-octave spacing and load its parameters
mfb_mode = 'halfoctave';
AudSys_Setup(mfb_mode);
load(['_system/AudSys_Setup_' mfb_mode '.mat'])

% d = dir('/Volumes/SD512/macaulay/raw_chorus/*.wav');  % alternative data path

%% --- Species list and file discovery ---

% Ten European bird species whose recordings are analysed
sl = {'Carrion_Crow',...
      'Common_Chaffinch',...
      'Common_Chiffchaff',...
      'Common_Firecrest',...
      'Dunnock',...
      'Eurasian_Blackbird',...
      'Eurasian_Blue_Tit',...
      'Eurasian_Jay',...
      'Song_Thrush',...
      'Willow_Warbler'};

% Build a combined directory listing 'd' and track each species' index range
% in Nx(k,:) = [first_index last_index] for later species-level averaging
N = 0;
for k = 1:10
    if k == 1
        d = dir(['../' sl{k} '/*/*.wav']);
        Nx(k,:) = [1 length(d)];
        N = length(d);
    else
        d = [d;dir(['../' sl{k} '/*/*.wav'])];
        Nx(k,:) = [1+N length(d)]   % display index range as it is built
        N = length(d);
    end
end

%% --- Sample-rate validation pass (read-only, no processing) ---

% Quick scan to flag any file not at the expected 48 kHz sample rate
for kk = 1:length(d)
    % disp(kk)
    clearvars y fs

    [y fst] = audioread([d(kk).folder '/' d(kk).name]);
    if fst ~= 48e3
        disp([num2str(kk) 'bad'])
        fst
    end
end

%% --- Feature extraction loop ---

for kk = 1:length(d)
    disp(kk)
    clearvars y fs

    % Load audio
    [y fsf] = audioread([d(kk).folder '/' d(kk).name]);

    % Resample to 48 kHz if necessary (take mono channel if stereo)
    if fsf ~=48e3
        fst = 48e3;
        y = resample(y(:,1),fst,fsf);
    else
        fst = fsf;
    end

    % Truncate to at most 3 seconds
    if length(y) > 3*fst
        y = y(1:3*fst);
    end

    % Zero-pad to exactly 3 s and normalise RMS to 0.025
    y1 = zeros(fst*3,1);
    y1(1:length(y)) = y;
    y1 = y1 * 0.025/rms(y1);

    % Decompose into auditory subbands and extract Hilbert envelopes
    y_sub = ufilterbank(y1,g,1)';
    [dey_sub eyf_sub] = Subband_Envelopes(y_sub,fst,fs_d,compression,'hilbert',fcc);

    % Apply modulation filterbank to subband envelopes
    deym_sub = mfilterbank(dey_sub,mfb);

    % Compute summary statistics (marginal moments, correlations, etc.)
    Y{kk} = Meas_SynthStats(dey_sub,deym_sub,mfb_mode);
end

%% --- Save per-recording statistics ---

mkdir('_stats')

for k = 1:length(Y)
    X.stats = Y{k};
    X.filename = d(k).name;
    fn = d(k).folder;
    % Parse species name and recording ID from the folder path
    I = strfind(fn,'/');
    X.species = fn(I(end-1)+1:I(end)-1)
    X.soundID = fn(I(end)+1:end)
    save(['_stats/' num2str(k) '.mat'],'X')
end

%% --- Assemble and z-score feature matrices ---

% Stack each statistic type across recordings into 2-D matrices (features x recordings)
clearvars Mx1 Mx2 Cx MPx MCx
for m = 1:length(Y)
    Mx1(:,m) = Y{m}.Mx(:,1);   % marginal mean
    Mx2(:,m) = Y{m}.Mx(:,2);   % marginal variance
    Cx(:,m)  = reshape(Y{m}.Cx,1,[]);   % subband correlations
    MPx(:,m) = reshape(Y{m}.MPx,1,[]);  % modulation-power correlations
    MCx(:,m) = reshape(Y{m}.MCx,1,[]);  % modulation cross-correlations
end

% Z-score each feature across recordings so all statistics contribute equally
Mx1 = zscore(Mx1);
Mx2 = zscore(Mx2);
Cx  = zscore(Cx);
MPx = zscore(MPx);
MCx = zscore(MCx);

%% --- Pairwise Euclidean distance computation ---

% Compute all pairwise distances for each statistic type;
% pd(m,n,s) = Euclidean distance between recordings m and n for statistic s
for m = 1:length(Y)
    disp(m)
    for n = 1:length(Y)
        pd(m,n,1) = pdist([Mx1(:,m)';Mx1(:,n)']);
        pd(m,n,2) = pdist([Mx2(:,m)';Mx2(:,n)']);
        pd(m,n,3) = pdist([Cx(:,m)';Cx(:,n)']);
        pd(m,n,4) = pdist([MPx(:,m)';MPx(:,n)']);
        pd(m,n,5) = pdist([MCx(:,m)';MCx(:,n)']);
    end
end

%% --- Figure 1: Species-averaged distance matrix ---

load('bird_stats_pdist_v3.mat');

% Average across the 5 statistic types and then average within species pairs
pd_summary = mean(pd,3);
for m = 1:10
    for n = 1:10
        % Average all recording-pair distances within each species-pair block
        pd2(m,n) = mean(pd(Nx(m,1):Nx(m,2),Nx(n,1):Nx(n,2)),'all');
    end
end
% Normalise to [0, 1] for display
pd2 = pd2 - min(min(pd2));
pd2 = pd2./max(max(pd2));

% Plot species x species distance matrix (10 x 10)
figure
set(gcf,'position',[200 200 400 400])
colormap sky
cm = flipud(colormap);   % invert so darker = more similar
colormap(cm)
subplot('position',[0.25 0.25 0.6 0.6])
imagesc(pd2)
c = colorbar;
c.Position = [0.86 0.25 0.03 0.6];
c.TickDirection = 'out';
ylabel(c,'Normalized Eucledian Distance of Summary Statistics','Rotation',270)
% Replace underscores with spaces for readable tick labels
for k = 1:10
    sk{k} = sl{k};
    I = strfind(sk{k},'_');
    sk{k}(I) = ' ';
end
set(gca,'TickDir','out');
set(gca,'YTick',[1:10],'YTickLabel',sk)
set(gca,'XTick',[1:10],'XTickLabel',sk,'XTickLabelRotation',30)

%% --- Figure 2: Per-recording distance matrix with species boundaries ---

% Average across the 5 statistic types for every recording pair
pd_summary = mean(pd,3);
pd_summary = pd_summary - min(min(pd_summary));
pd_summary = pd_summary./max(max(pd_summary));

figure
set(gcf,'position',[200 200 800 800])
colormap(cm)
subplot('position',[0.25 0.25 0.6 0.6])
imagesc(pd_summary)

c = colorbar;
c.Position = [0.86 0.25 0.015 0.6];
c.TickDirection = 'out';
ylabel(c,'Normalized Eucledian Distance of Summary Statistics','Rotation',270)
for k = 1:10
    sk{k} = sl{k};
    I = strfind(sk{k},'_');
    sk{k}(I) = ' ';
end
set(gca,'TickDir','out');
% Place species labels at the midpoint of each species block
set(gca,'YTick',mean(Nx,2),'YTickLabel',sk)
set(gca,'XTick',mean(Nx,2),'XTickLabel',sk,'XTickLabelRotation',30)
% Draw alternating dark/light lines at species block boundaries
for k = 1:2:10
    line([1 1],Nx(k,:),'linewidth',2,'color',[0.2 0.2 0.2])
    line([1 1],Nx(k+1,:),'linewidth',2,'color',[0.8 0.8 0.8])
    line(3039*[1 1],Nx(k,:),'linewidth',2,'color',[0.2 0.2 0.2])
    line(3039*[1 1],Nx(k+1,:),'linewidth',2,'color',[0.8 0.8 0.8])
    line(Nx(k,:),[1 1],'linewidth',2,'color',[0.2 0.2 0.2])
    line(Nx(k+1,:),[1 1],'linewidth',2,'color',[0.8 0.8 0.8])
    line(Nx(k,:),[3039 3039],'linewidth',2,'color',[0.2 0.2 0.2])
    line(Nx(k+1,:),[3039 3039],'linewidth',2,'color',[0.8 0.8 0.8])
end









