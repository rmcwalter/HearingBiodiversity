function run_model(d,Z,NP,kkX,dr)
% run_model  Auditory texture observer model for a 3-interval oddity task.
%
% The model compares auditory texture statistics between pairs of intervals,
% adds independent Gaussian internal noise to each statistic class, then
% picks the "odd one out" as the interval most different from the other two.
%
% Inputs:
%   d    - dir struct of WAV files (one entry per trial); the correct
%          interval is encoded in character d(k).name(end-4) as '1','2' or '3'
%   Z    - cell array of z-scored stats structs; Z{3*(m-1)+1..3} are the
%          three intervals for trial m
%   NP   - 1x6 noise parameter vector, one per statistic class:
%            NP(1) envelope mean, NP(2) envelope CV, NP(3) envelope skewness,
%            NP(4) envelope correlation, NP(5) modulation power,
%            NP(6) modulation correlation
%   kkX  - run index, used in the output filename
%   dr   - output directory (created if absent)
%
% Output:
%   <dr>/<NP-string>_<kkX>.mat  containing:
%     rsp      - (trials/35 x 7 x 1) proportion correct per condition
%     rsp_out  - scalar grand mean proportion correct

clearvars -except d Z NP kkX dr

mkdir(dr)

rng('shuffle')

for rx = 1
    clearvars -except d rx rsp Z mx NP rsp_out kk kkX dr

    % M and N define the 3 interval pairs for the oddity task:
    %   pair 1: intervals N(1)=1 vs M(1)=2   (pd(:,1,:))
    %   pair 2: intervals N(2)=1 vs M(2)=3   (pd(:,2,:))
    %   pair 3: intervals N(3)=2 vs M(3)=3   (pd(:,3,:))
    M = [2 3 3];
    N = [1 1 2];
    L = length(d);   % number of trials
    Lmk = 1;
    for mk = 1:Lmk
        for m = 1:L

            % Load the three intervals for trial m from the pre-computed Z array
            Y{1} = Z{3*(m-1)+1};
            Y{2} = Z{3*(m-1)+2};
            Y{3} = Z{3*(m-1)+3};

            % Compute noisy pairwise distances for each interval pair and stat class
            for n = 1:3
                % Add noise separately to each of the two intervals being compared.
                % nsm rows 1-2: noise for envelope mean pair
                % nsm rows 3-4: noise for envelope CV pair
                % nsm rows 5-6: noise for envelope skewness pair
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

                % Euclidean distance between noisy representations of each stat class
                pd(m+(mk-1)*L,n,1) = pdist([nsm(1,:)+Y{N(n)}.Mx(:,1)';nsm(2,:)+Y{M(n)}.Mx(:,1)']);
                pd(m+(mk-1)*L,n,2) = pdist([nsm(3,:)+Y{N(n)}.Mx(:,2)';nsm(4,:)+Y{M(n)}.Mx(:,2)']);
                pd(m+(mk-1)*L,n,3) = pdist([nsm(5,:)+Y{N(n)}.Mx(:,3)';nsm(6,:)+Y{M(n)}.Mx(:,3)']);
                pd(m+(mk-1)*L,n,4) = pdist([nsc(1,:)+Y{N(n)}.Cx';nsc(2,:)+Y{M(n)}.Cx']);
                pd(m+(mk-1)*L,n,5) = pdist([nsmp(1,:)+Y{N(n)}.MPx';nsmp(2,:)+Y{M(n)}.MPx']);
                pd(m+(mk-1)*L,n,6) = pdist([nsmc(1,:)+Y{N(n)}.MCx';nsmc(2,:)+Y{M(n)}.MCx']);
            end
        end
    end


    % Z-score each stat class's distances across all trials, then average
    % across classes to get a single combined distance per interval pair.
    for k = 1:size(pd,3)
        pd(:,:,k) = reshape(zscore(reshape(pd(:,:,k),1,[])),Lmk*L,3);
    end

    pd = mean(pd,3);  % (trials x 3) combined pairwise distance

    % Decision rule: the odd interval is the one NOT in the closest pair.
    % min distance -> most similar pair -> third interval is the target.
    r = zeros(size(pd,1),1);
    for k = 1:size(pd,1)
        [~,I] = min(pd(k,:));
        if I == 1
            r(k) = 3;    % pairs 1&2 most similar -> interval 3 is odd
        elseif I == 2
            r(k) = 2;    % pairs 1&3 most similar -> interval 2 is odd
        else
            r(k) = 1;    % pairs 2&3 most similar -> interval 1 is odd
        end
    end

    % Score: compare model response r(k) to ground truth encoded in filename
    a = zeros(size(pd,1),1);
    for k = 1:size(pd,1)
        I = str2num(d(mod((k-1),L)+1).name(end-4));  % correct interval (1,2,3)

        if r(k) == I
            a(k) = 1;
        else
            a(k) = 0;
        end
    end

    a_out(:,rx) = a;
end

% Reshape accuracy vector into (conditions x chorus_sizes x repetitions)
% 35 trials per condition block; 7 conditions
for k = 1:size(a_out,1)/35
    rsp(:,:,k) = reshape(a((k-1)*35+1:35*k),5,[]);
end
rsp_out = mean(rsp(:));
rsp_temp = mean(mean(rsp,3));
rsp_temp([1 2 7])-[0.85 0.687 0.553]  % quick sanity check vs. expected performance

% Save with noise parameter string in filename to allow parameter sweeps
NPs = num2str(NP);
I = findstr(NPs,' ');
NPs(I) = '';
save([dr '/' NPs '_' num2str(kkX) '.mat'],'rsp_out','rsp')
