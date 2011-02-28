clear all; close all; clc;

% compute rand errors for 5 different methods:
% fusion, verena, b-lp, thresholded weights, MHVS
JEFF_DATASET = 9;
SLICES = 8;
BLP_WEIGHTS_TESS_THRESH = 100;
WEIGHTS_THRESHOLD = 0;


%%%%
VOLUME = 2;

volume_offsets = [...
    1-120   1380-120   1928+30   3876+30  ;...
    1549    3018       2247      3623     ;...
    ];
%%%%

%% Read in Piet data 
fprintf('Reading XMLs...');
breadcrumbsOffset = containers.Map();
breadcrumbsOriginal = containers.Map();
for j = 1:SLICES
    breadcrumbsOffset = loadPietData( ...
                            sprintf('../Data/dataset%u/contour-%i.xml', JEFF_DATASET, j), ...  % path
                            breadcrumbsOffset, ...  % offset data
                            breadcrumbsOriginal, ...% original data
                            j, ...                  % slice
                     volume_offsets(VOLUME, 1), ... % xMin
                     volume_offsets(VOLUME, 2), ... % xMax
                     volume_offsets(VOLUME, 3), ... % yMin
                     volume_offsets(VOLUME, 4), ... % yMax
                            300, ...                % crop
                            4);                     % downsample
end
v = values(breadcrumbsOffset);
keyset = keys(breadcrumbsOffset);
nProcess = length(v);

vOriginal = values(breadcrumbsOriginal);

fprintf('    Done.\n')







%% Read in Amelio's data --> "labeled"
AMELIO_FUSION = 5;

fprintf('Reading fusion data...');
[labeled] = amelio_data_loader(...
    sprintf('../Data/v%d_outputs/amelio/fusion/', VOLUME), SLICES);
UnlabeledM = get_unlabeled(labeled, SLICES);
fprintf('     Done.\n');
fprintf('     Number unique labels: %d\n', length(keys(UnlabeledM)));

randerror(1) = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v);
fprintf('Fusion rand error = %.4f', randerror(1));

%% Read in Verena's data --> "labeled"
fprintf('Reading Aglomerate clustering data...');
[labeled] = verena_data_loader(SLICES);
UnlabeledM = get_unlabeled(labeled, SLICES);
fprintf('     Done.\n');
fprintf('     Number unique labels: %d\n', length(keys(UnlabeledM)));

randerror(2) = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v);
fprintf('Verena rand error = %.4f', randerror(2));

%% Read in b-lp data
fprintf('Computing b-lp weights (for b-lp and threshold)...');
blp_precomputing(SLICES, BLP_WEIGHTS_TESS_THRESH);
fprintf('     Done.\n');

fprintf('Computing b-lp clustering...');
blp_produce_output(SLICES, BLP_WEIGHTS_TESS_THRESH);
fprintf('     Done.\n');



fprintf('Reading b-lp clustering data...');
[labeled] = amelio_data_loader(...
    sprintf('../Data/v%d_outputs/blp/fusion/', VOLUME), SLICES);
UnlabeledM = get_unlabeled(labeled, SLICES);
fprintf('     Done.\n');
fprintf('     Number unique labels: %d\n', length(keys(UnlabeledM)));

randerror(3) = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v);
fprintf('B-LP rand error = %.4f', randerror(3));

%% Read in weights-threshold data
fprintf('Computing thresholded-weights clustering...')
threshold_produce_output(SLICES, BLP_WEIGHTS_TESS_THRESH, WEIGHTS_THRESHOLD);
fprintf('     Done.\n');
%%
fprintf('Reading thresholded-weights clustering data...');
[labeled] = amelio_data_loader(...
    sprintf('../Data/v%d_outputs/threshold/fusion/', VOLUME), SLICES);
UnlabeledM = get_unlabeled(labeled, SLICES);
fprintf('     Done.\n');
fprintf('     Number unique labels: %d\n', length(keys(UnlabeledM)));

randerror(4) = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v);
fprintf('Threshold rand error = %.4f', randerror(4));



%% Read in MHVS data
fprintf('Computing MHVS clustering...');
[labeled] = amelio_data_loader(...
    sprintf('../Data/v%d_outputs/mhvs/fusion/', VOLUME), SLICES);
UnlabeledM = get_unlabeled(labeled, SLICES);
fprintf('     Done.\n');
fprintf('     Number unique labels: %d\n', length(keys(UnlabeledM)));

randerror(5) = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v);
fprintf('MHVS rand error = %.4f', randerror(5));
