function pd = noise_and_distance(Z, d, W, NP, mt, kk, kflag)
% noise_and_distance  Adds internal noise to texture statistics and computes
% pairwise Euclidean distances for each trial.
%
% For each stimulus pair in d, the function draws independent Gaussian
% noise samples (scaled by NP) and adds them to the relevant statistic
% vectors before computing pairwise distances.  The statistic type is
% selected by mt; weights W scale each statistic's contribution.
%
% Inputs:
%   Z      - cell array of statistics structs (3 per stimulus in d)
%   d      - struct array of wav file directory entries
%   W      - [1 x K] weight vector for each statistic class
%   NP     - internal noise standard deviation
%   mt     - model type string: 'spec_v2'|'var_v2'|'corr_v2'|
%             'mod_power_v2'|'atmw_v2'
%   kk     - statistic class index/indices to include (default: 1)
%   kflag  - selection mode: 1 = exclude kk, 3 = include all, else = include kk
%             (default: 0, i.e. include only kk)
%
% Output:
%   pd  - [N x 3] pairwise distance matrix for N stimuli x 3 intervals

if nargin < 7, kflag = 0; end
if nargin < 6, kk = 1; end

% M and N define the interval pairing for each of the 3 trial sub-types:
%   Sub-type 1 (species): compare interval 1 vs interval 2  (N=1, M=2)
%   Sub-type 2 (mixture): compare interval 1 vs interval 3  (N=1, M=3)
%   Sub-type 3 (individual): compare interval 2 vs interval 3  (N=2, M=3)
% In each trial the listener hears three intervals; two come from the same
% category (N repeated twice) and one is the odd-one-out (M).
M = [2 3 3];
N = [1 1 2];

for m = 1:length(d)
    % Each stimulus m has 3 segments stored consecutively in Z
    Y{1} = Z{3*(m-1)+1};
    Y{2} = Z{3*(m-1)+2};
    Y{3} = Z{3*(m-1)+3};

    for n = 1:3
        % Draw independent noise vectors for each statistic class.
        % Two noise draws per class so that noise is independent for the
        % two intervals being compared (simulating independent perceptual
        % samples of the same auditory statistic).
        for nk = 1:6
            nsm(nk, :) = NP * randn(size(Y{N(n)}.Mx(:, 1)))';   % envelope marginals noise
        end
        for nk = 1:2
            nsc(nk, :) = NP * randn(size(Y{N(n)}.Cx))';         % envelope correlation noise
        end
        for nk = 1:2
            nsmp(nk, :) = NP * randn(size(Y{N(n)}.MPx))';       % modulation power noise
        end
        for nk = 1:2
            nsmc(nk, :) = NP * randn(size(Y{N(n)}.MCx))';       % modulation correlation noise
        end

        % Compute Euclidean distance between noisy statistic representations
        % of the reference interval N(n) and the comparison interval M(n).
        % Mx(:,1) = envelope mean (frequency spectrum proxy)
        % Mx(:,2) = envelope coefficient of variation
        % Mx(:,3) = envelope skewness
        % Cx      = pairwise envelope correlation (vectorised)
        % MPx     = modulation power
        % MCx     = modulation correlation
        if strcmp(mt, 'spec_v2')
            pd(m, n, 1) = pdist([nsm(1,:)+Y{N(n)}.Mx(:,1)'; nsm(2,:)+Y{M(n)}.Mx(:,1)']);
        elseif strcmp(mt, 'var_v2')
            pd(m, n, 1) = pdist([nsm(3,:)+Y{N(n)}.Mx(:,2)'; nsm(4,:)+Y{M(n)}.Mx(:,2)']);
        elseif strcmp(mt, 'corr_v2')
            pd(m, n, 1) = pdist([nsc(1,:)+Y{N(n)}.Cx'; nsc(2,:)+Y{M(n)}.Cx']);
        elseif strcmp(mt, 'mod_power_v2')
            pd(m, n, 1) = pdist([nsmp(1,:)+Y{N(n)}.MPx'; nsmp(2,:)+Y{M(n)}.MPx']);
        elseif strcmp(mt, 'atmw_v2')
            % Full auditory texture model: all six statistic classes,
            % each stored in a separate slice of pd(:,:,k)
            pd(m, n, 1) = pdist([nsm(1,:)+Y{N(n)}.Mx(:,1)'; nsm(2,:)+Y{M(n)}.Mx(:,1)']);
            pd(m, n, 2) = pdist([nsm(3,:)+Y{N(n)}.Mx(:,2)'; nsm(4,:)+Y{M(n)}.Mx(:,2)']);
            pd(m, n, 3) = pdist([nsm(5,:)+Y{N(n)}.Mx(:,3)'; nsm(6,:)+Y{M(n)}.Mx(:,3)']);
            pd(m, n, 4) = pdist([nsc(1,:)+Y{N(n)}.Cx';  nsc(2,:)+Y{M(n)}.Cx']);
            pd(m, n, 5) = pdist([nsmp(1,:)+Y{N(n)}.MPx'; nsmp(2,:)+Y{M(n)}.MPx']);
            pd(m, n, 6) = pdist([nsmc(1,:)+Y{N(n)}.MCx'; nsmc(2,:)+Y{M(n)}.MCx']);
        end
    end
end

% Apply per-class weights before combining across statistic classes
for k = 1:size(pd, 3)
    pd(:, :, k) = W(k) * pd(:, :, k);
end

% Select which statistic class slices to average into the final distance.
% pdk is always 1:6; I selects indices into kk based on kflag:
%   kflag == 1  →  exclude the class(es) in kk  (leave-one-out ablation)
%   kflag == 3  →  include all classes           (full model)
%   else        →  include only the class(es) in kk (isolation / subset)
pdk = 1:6;
if kflag == 1
    I = find(kk ~= pdk);   % exclude kk
elseif kflag == 3
    I = find(kk ~= 0);     % include all (kk ~= 0 is always true for 1:6)
else
    I = find(kk == pdk);   % include only kk
end

pd = mean(pd(:, :, kk(I)), 3);
