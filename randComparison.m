clear all; close all; clc;

% compute rand errors for 5 different methods:
% fusion, verena, b-lp, thresholded weights, MHVS
JEFF_DATASET_NAME = 'dataset9Dan';
SLICES = 8;
BLP_WEIGHTS_TESS_THRESH = 100;
WEIGHTS_THRESHOLD = 0;


%%%%
VOLUME = 1;

volume_offsets = [...
    1-120   1380-120   1928+30   3876+30  ;...
    1546    3018       2243      3627     ;...
    ];

volume_crops = [300; 0];
volume_downsamples = [4; 4];
    

%%%%

%% Read in Piet data 
fprintf('Reading XMLs...');
breadcrumbsOffset = containers.Map();
breadcrumbsOriginal = containers.Map();
for j = 1:SLICES
    breadcrumbsOffset = loadPietData( ...
                            sprintf('../Data/skeletons_from_jeff/%s/contour-%i.xml', ...
                        JEFF_DATASET_NAME, j), ...  % path
                            breadcrumbsOffset, ...  % offset data
                            breadcrumbsOriginal, ...% original data
                            j, ...                  % slice
                     volume_offsets(VOLUME, 1), ... % xMin
                     volume_offsets(VOLUME, 2), ... % xMax
                     volume_offsets(VOLUME, 3), ... % yMin
                     volume_offsets(VOLUME, 4), ... % yMax
                       volume_crops(VOLUME),    ... % crop
                 volume_downsamples(VOLUME)      ); % downsample
end
v = values(breadcrumbsOffset);
keyset = keys(breadcrumbsOffset);
nProcess = length(v);

vOriginal = values(breadcrumbsOriginal);

fprintf('    Done.\n\n')







%% Read in Amelio's data --> "labeled"
AMELIO_FUSION = 5;

fprintf('Reading fusion data...');
[labeled] = amelio_data_loader(...
    sprintf('../Data/v%d_outputs/amelio/fusion/', VOLUME), SLICES);
UnlabeledM = get_unlabeled(labeled, SLICES);
fprintf('     Done.');
fprintf('  (#UL = %d)\n', length(keys(UnlabeledM)));

randerror(1) = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v);
fprintf('Fusion rand error = %.4f\n\n', randerror(1));




%% Read in Verena's data --> "labeled"
fprintf('Reading Aglomerate clustering data...');
[labeled] = verena_data_loader(SLICES);
UnlabeledM = get_unlabeled(labeled, SLICES);
fprintf('     Done.');
fprintf('  (#UL = %d)\n', length(keys(UnlabeledM)));
randerror(2) = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v);
fprintf('Verena rand error = %.4f\n\n', randerror(2));





%% Read in b-lp data
fprintf('Computing b-lp weights (for b-lp and threshold)...');
blp_precomputing(SLICES, BLP_WEIGHTS_TESS_THRESH, VOLUME);
fprintf('     Done.\n');
%%
fprintf('Computing b-lp clustering...');
blp_produce_output(SLICES, BLP_WEIGHTS_TESS_THRESH, VOLUME);
fprintf('     Done.\n');
%%
fprintf('Reading b-lp clustering data...');
[labeled] = amelio_data_loader(...
    sprintf('../Data/v%d_outputs/blp/fusion/', VOLUME), SLICES);
UnlabeledM = get_unlabeled(labeled, SLICES);
fprintf('     Done.');
fprintf('   (#UL = %d)\n', length(keys(UnlabeledM)));

randerror(3) = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v);
fprintf('B-LP rand error = %.4f\n\n', randerror(3));





%% Read in weights-threshold data
fprintf('Computing thresholded-weights clustering...')
threshold_produce_output(SLICES, BLP_WEIGHTS_TESS_THRESH, WEIGHTS_THRESHOLD, VOLUME);
fprintf('     Done.\n');
%%
fprintf('Reading thresholded-weights clustering data...');
[labeled] = amelio_data_loader(...
    sprintf('../Data/v%d_outputs/threshold/fusion/', VOLUME), SLICES);
UnlabeledM = get_unlabeled(labeled, SLICES);
fprintf('     Done.');
fprintf('   (#UL = %d)\n', length(keys(UnlabeledM)));

randerror(4) = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v);
fprintf('Threshold rand error = %.4f\n', randerror(4));





%% Read in MHVS data
fprintf('Computing MHVS clustering...');
[labeled] = amelio_data_loader(...
    sprintf('../Data/v%d_outputs/mhvs/fusion/', VOLUME), SLICES);
UnlabeledM = get_unlabeled(labeled, SLICES);
fprintf('     Done.');
fprintf('   (#UL = %d)\n', length(keys(UnlabeledM)));

randerror(5) = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v);
fprintf('MHVS rand error = %.4f\n', randerror(5));



figure; bar(randerror);