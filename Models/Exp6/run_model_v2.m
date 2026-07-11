function run_model_v2(d,Z,NP,dr,kkx,wt)
% RUN_MODEL_V2  Simulate one repetition of an oddity (3-interval,
% odd-one-out) discrimination task on texture statistics and score
% model accuracy against each stimulus file's ground-truth answer.
%
% Inputs:
%   d    - struct array of stimulus wav file listings (dir() output);
%          the correct oddball interval (1-3) is encoded in the
%          filename, read from d(k).name(end-4).
%   Z    - cell array of per-interval texture-statistic structs
%          (3 consecutive entries per trial, from observer_model_v3_*),
%          each with fields Mx (mean/var/kurtosis), Cx (envelope
%          correlations), MPx (modulation power), MCx (modulation
%          correlations).
%   NP   - 1x6 internal-noise magnitudes applied to [mean, variance,
%          kurtosis, envelope-correlation, modulation-power,
%          modulation-correlation] statistics respectively.
%   dr   - output directory to save the per-run response file into.
%   kkx  - repetition index, used to make the output filename unique.
%   wt   - (unused/legacy) weighting vector for combining stat-distance
%          channels; see commented-out block below.
%
% For each trial the 3 intervals are compared pairwise (interval pairs
% N-M = [1,2],[1,3],[2,3]); independent Gaussian noise is added to each
% interval's statistics before computing the Euclidean distance between
% the pair. The model's response is the interval NOT in the closest
% (most similar) pair, i.e. the odd one out is inferred as whichever
% interval is excluded from the minimum-distance pair.

clearvars -except d Z NP dr wt kkx

mkdir(dr)

rng('shuffle')

for rx = 1
    clearvars -except d rx rsp Z mx NP rsp_out kk dr wt kkx

    M = [2 3 3];   % second interval of each compared pair
    N = [1 1 2];   % first interval of each compared pair -> pairs (1,2) (1,3) (2,3)
    L = length(d);
    Lmk = 1;
    for mk = 1:Lmk
        for m = 1:L

            % Unpack the 3 interval-statistic structs for this trial
            Y{1} = Z{3*(m-1)+1};
            Y{2} = Z{3*(m-1)+2};
            Y{3} = Z{3*(m-1)+3};

            for n = 1:3
                % Draw independent internal noise for the two intervals
                % being compared (nk=1,2), separately for each of the 6
                % statistic channels: mean, variance, kurtosis
                % (nsm rows 1-2,3-4,5-6), envelope correlation (nsc),
                % modulation power (nsmp), modulation correlation (nsmc).
                for nk = 1:2
                    nsm(nk,:) = NP(1)*randn(size(Y{N(n)}.Mx(:,1)))';
                end
                for nk = 1:2
                    nsm(nk+2,:) = NP(2)*randn(size(Y{N(n)}.Mx(:,1)))';
                end
                for nk = 1:2
                    nsm(nk+4,:) = NP(3)*randn(size(Y{N(n)}.Mx(:,1)))';
                end
                for nk = 1:2
                    nsc(nk,:) = NP(4)*randn(size(Y{N(n)}.Cx))';
                end
                for nk = 1:2
                    nsmp(nk,:) = NP(5)*randn(size(Y{N(n)}.MPx))';
                end
                for nk = 1:2
                    nsmc(nk,:) = NP(6)*randn(size(Y{N(n)}.MCx))';
                end
                % Noisy pairwise Euclidean distance between interval
                % N(n) and interval M(n) for each of the 6 stat channels.
                pd(m+(mk-1)*L,n,1) = pdist([nsm(1,:)+Y{N(n)}.Mx(:,1)';nsm(2,:)+Y{M(n)}.Mx(:,1)']);
                pd(m+(mk-1)*L,n,2) = pdist([nsm(3,:)+Y{N(n)}.Mx(:,2)';nsm(4,:)+Y{M(n)}.Mx(:,2)']);
                pd(m+(mk-1)*L,n,3) = pdist([nsm(5,:)+Y{N(n)}.Mx(:,3)';nsm(6,:)+Y{M(n)}.Mx(:,3)']);
                pd(m+(mk-1)*L,n,4) = pdist([nsc(1,:)+Y{N(n)}.Cx';nsc(2,:)+Y{M(n)}.Cx']);
                pd(m+(mk-1)*L,n,5) = pdist([nsmp(1,:)+Y{N(n)}.MPx';nsmp(2,:)+Y{M(n)}.MPx']);
                pd(m+(mk-1)*L,n,6) = pdist([nsmc(1,:)+Y{N(n)}.MCx';nsmc(2,:)+Y{M(n)}.MCx']);
            end
        end
    end
    % length(find(wt~=0));
    % for k = 1:length(find(wt~=0))
        % pd2(:,:,k) = reshape(zscore(reshape(pd(:,:,wt(k)),1,[])),Lmk*L,3);
    % end

    % Combine the 6 stat-channel distances into a single overall
    % dissimilarity per interval-pair (equal-weighted average).
    pd = mean(pd,3);

    % Model response: the interval excluded from the closest (min
    % distance) pair is judged the odd one out.
    %   min at pair (1,2) [I=1] -> oddball is interval 3
    %   min at pair (1,3) [I=2] -> oddball is interval 2
    %   min at pair (2,3) [I=3] -> oddball is interval 1
    r = zeros(size(pd,1),1);
    for k = 1:size(pd,1)
        [~,I] = min(pd(k,:));
        if I == 1
            r(k) = 3;
        elseif I == 2
            r(k) = 2;
        else
            r(k) = 1;
        end
    end

    % Score against ground truth encoded in the filename
    % (second-to-last character before the extension).
    a = zeros(size(pd,1),1);
    for k = 1:size(pd,1)
        I = str2num(d(k).name(end-4));
        if r(k) == I
            a(k) = 1;
        else
            a(k) = 0;
        end
    end

    a_out(:,rx) = a;
end
 % a_out
% Reshape flat trial accuracy (63 trials per block: 7 conditions x 9
% repeats) into conditions x repeats x blocks.
for k = 1:size(a_out,1)/63
    rsp(:,:,k) = reshape(a((k-1)*63+1:63*k),7,[])';
end
% rsp
% size(rsp)
rsp = squeeze(rsp);
% mean(rsp)
rsp_out = mean(rsp(:));           % overall proportion correct across everything
rsp_temp = mean(mean(rsp,3));     % proportion correct per condition, averaged over repeats/blocks
%
% Encode the noise-parameter vector NP into the output filename so
% repeated calls with different NP don't overwrite each other.
NPs = num2str(NP);
I = findstr(NPs,' ');
NPs(I) = '';
save([dr '/' NPs '_' num2str(kkx) '.mat'],'rsp_out','rsp','rsp_temp')