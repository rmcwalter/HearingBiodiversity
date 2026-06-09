function [rsp, a_out, a_all] = do_trials(pd, d)
% do_trials  Simulates observer decisions and computes proportion correct.
%
% For each trial the observer selects the interval with the smallest
% pairwise texture distance to the reference, then accuracy is evaluated
% by comparing the selected interval against the ground-truth odd-one-out
% interval encoded in each filename.
%
% Inputs:
%   pd  - [N x 3] matrix of pairwise texture distances for N trials
%   d   - struct array of wav file directory entries (length N)
%
% Outputs:
%   rsp   - [1 x 3] mean proportion correct for each condition
%             (1: species, 2: mixture, 3: individual)
%   a_out - overall mean proportion correct across all trials
%   a_all - cell(1,3) of per-trial accuracy vectors for each condition

% Determine the selected interval (minimum distance = most similar pair)
r = zeros(length(d), 1);
for k = 1:size(pd, 1)
    [~, I] = min(pd(k, :));
    if I == 1
        r(k) = 3;
    elseif I == 2
        r(k) = 2;
    else
        r(k) = 1;
    end
end

% Determine correct response from filename: character at positions end-6, end-5, end-4
% encodes which interval contains the odd-one-out (value 3)
a = zeros(length(d), 1);
for k = 1:size(pd, 1)
    I = find([str2num(d(k).name(end-6)) str2num(d(k).name(end-5)) str2num(d(k).name(end-4))] == 3);
    if r(k) == I
        a(k) = 1;
    end
end

% Split accuracy into three conditions:
%   species discrimination (90 pairs x 5 repeats)
%   mixture discrimination (180 pairs x 5 repeats)
%   individual discrimination (30 pairs x 5 repeats)
a_all{1}(:) = a([1:5*90]);
a_all{2}(:) = a(90*5+[1:5*180]);
a_all{3}(:) = a(270*5+[1:5*30]);

rsp(1) = mean(a([1:5*90]));
rsp(2) = mean(a(90*5+[1:5*180]));
rsp(3) = mean(a(270*5+[1:5*30]));

a_out = mean(a);
