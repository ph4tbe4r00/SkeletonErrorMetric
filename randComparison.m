clear all; close all; clc;

% compute rand errors for 5 different methods:
% fusion, verena, b-lp, thresholded weights, MHVS
JEFF_DATASET = 9;
SLICES = 8;
BLP_WEIGHTS_TESS_THRESH = 170;


%%
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
                            1-120, ...              % xMin
                            1380-120, ...           % xMax
                            1928+30, ...            % yMin
                            3876+30, ...            % yMax
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
    sprintf('../Data/amelio-fusion-%d/fusion/', AMELIO_FUSION), SLICES);
UnlabeledM = get_unlabeled(labeled, SLICES);
fprintf('     Done.\n');
fprintf('     Number unique labels: %d\n', length(keys(UnlabeledM)));

randerror(1) = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v);


%% Read in Verena's data --> "labeled"
fprintf('Reading Aglomerate clustering data...');
[labeled] = verena_data_loader(SLICES);
UnlabeledM = get_unlabeled(labeled, SLICES);
fprintf('     Done.\n');
fprintf('     Number unique labels: %d\n', length(keys(UnlabeledM)));

randerror(2) = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v);


%% Read in b-lp data
fprintf('Computing b-lp weights (for b-lp and threshold)...');
blp_precomputing(SLICES, BLP_WEIGHTS_TESS_THRESH);
fprintf('     Done.\n');

fprintf('Computing b-lp clustering...');
blp_produce_output(SLICES, BLP_WEIGHTS_TESS_THRESH)
fprintf('     Done.\n');




fprintf('Reading b-lp clustering data...');
[labeled] = blp_data_loader(SLICES);
UnlabeledM = get_unlabeled(labeled, SLICES);
fprintf('     Done.\n');
fprintf('     Number unique labels: %d\n', length(keys(UnlabeledM)));

randerror(3) = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v);


%% Read in weights-threshold data
fprintf('Computing thresholded-weights clustering...')

fprintf('     Done.\n');

fprintf('Reading thresholded-weights clustering data...');
[labeled] = threshold_data_loader(SLICES);
UnlabeledM = get_unlabeled(labeled, SLICES);
fprintf('     Done.\n');
fprintf('     Number unique labels: %d\n', length(keys(UnlabeledM)));
randerror(4) = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v);




%% Read in MHVS data
fprintf('Computing weights-threshold clustering...');
[labeled] = threshold_data_loader(SLICES);
UnlabeledM = get_unlabeled(labeled, SLICES);
fprintf('     Done.\n');
fprintf('     Number unique labels: %d\n', length(keys(UnlabeledM)));
randerror(5) = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v);
