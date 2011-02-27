clear all; close all; clc;

% compute rand errors for 5 different methods:
% fusion, verena, b-lp, thresholded weights, MHVS
JEFF_DATASET = 9;
SLICES = 8;




%% Read in b-lp data
disp('Computing b-lp clustering...')
[labeled] = blp_data_loader(SLICES);
UnlabeledM = get_unlabeled(labeled, SLICES);
fprintf('Number unique labels: %d\n', length(keys(UnlabeledM)));
disp('Done.');

randerror(3) = skeleton_ver2(labeled, UnlabeledM, JEFF_DATASET, SLICES);
