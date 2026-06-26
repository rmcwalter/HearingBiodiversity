function run_model_ablation(d,Z,NP,kkX,dr,wt,nt)
% run_model_ablation  Observer model run for a specified subset of stat classes.
%
% Identical to run_model, except the distance aggregation step only uses
% the statistic classes listed in wt rather than all six. This enables the
% ablation study in Observer_model_exp5_ablation.
%
% Inputs:
%   d    - dir struct of WAV files (one entry per trial)
%   Z    - cell array of z-scored stats structs (3 intervals per trial)
%   NP   - 1x6 noise parameter vector (same ordering as run_model)
%   kkX  - run index for filename
%   dr   - output directory
%   wt   - row from kkx indicating which stat classes to include
%          (e.g. [1 3 0 0 0 0] means use envelope mean and skewness only)
%   nt   - ablation subset index appended to filename for identification
%
% Output:
%   <dr>/<NP-string>_<kkX>_<nt>.mat  containing rsp_out and rsp

clearvars -except d Z NP kkX dr wt nt

mkdir(dr)

rng('shuffle')

for rx = 1
    clearvars -except d rx rsp Z mx NP rsp_out kk kkX dr wt nt

    % Interval pair indices for the 3-interval oddity task (see run_model)
    M = [2 3 3];
    N = [1 1 2];
    L = length(d);
    Lmk = 1;
    for mk = 1:Lmk
        for m = 1:L

            Y{1} = Z{3*(m-1)+1};
            Y{2} = Z{3*(m-1)+2};
            Y{3} = Z{3*(m-1)+3};

            % Compute noisy pairwise distances for all 6 stat classes
            % (the subset selection happens after via wt)
            for n = 1:3
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
                pd(m+(mk-1)*L,n,1) = pdist([nsm(1,:)+Y{N(n)}.Mx(:,1)';nsm(2,:)+Y{M(n)}.Mx(:,1)']);
                pd(m+(mk-1)*L,n,2) = pdist([nsm(3,:)+Y{N(n)}.Mx(:,2)';nsm(4,:)+Y{M(n)}.Mx(:,2)']);
                pd(m+(mk-1)*L,n,3) = pdist([nsm(5,:)+Y{N(n)}.Mx(:,3)';nsm(6,:)+Y{M(n)}.Mx(:,3)']);
                pd(m+(mk-1)*L,n,4) = pdist([nsc(1,:)+Y{N(n)}.Cx';nsc(2,:)+Y{M(n)}.Cx']);
                pd(m+(mk-1)*L,n,5) = pdist([nsmp(1,:)+Y{N(n)}.MPx';nsmp(2,:)+Y{M(n)}.MPx']);
                pd(m+(mk-1)*L,n,6) = pdist([nsmc(1,:)+Y{N(n)}.MCx';nsmc(2,:)+Y{M(n)}.MCx']);
            end
        end
    end

    % Ablation: select only the classes indicated by non-zero entries of wt,
    % z-score each selected class's distances, then average across them.
    length(find(wt~=0))
    wt
    for k = 1:length(find(wt~=0))
        pd2(:,:,k) = reshape(zscore(reshape(pd(:,:,wt(k)),1,[])),Lmk*L,3);
    end

    pd = mean(pd2,3);  % (trials x 3) combined distance using selected classes only

    % Oddity decision: same logic as run_model
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

    % Score against ground truth from filename
    a = zeros(size(pd,1),1);
    for k = 1:size(pd,1)
        I = str2num(d(mod((k-1),L)+1).name(end-4));

        if r(k) == I
            a(k) = 1;
        else
            a(k) = 0;
        end
    end

    a_out(:,rx) = a;
end

% Reshape into (conditions x chorus_sizes x repetitions)
for k = 1:size(a_out,1)/35
    rsp(:,:,k) = reshape(a((k-1)*35+1:35*k),5,[]);
end
rsp_out = mean2(rsp);
rsp_temp = mean(mean(rsp,3));
rsp_temp([1 2 7])-[0.85 0.687 0.553]  % sanity check vs. expected performance

% Filename encodes noise params, run index, and ablation subset index
NPs = num2str(NP);
I = findstr(NPs,' ');
NPs(I) = '';
save([dr '/' NPs '_' num2str(kkX) '_' num2str(nt) '.mat'],'rsp_out','rsp')
