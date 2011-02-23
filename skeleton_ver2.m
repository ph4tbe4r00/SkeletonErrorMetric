clear all;
clc;

JEFF_DATASET = 6;
AMELIO_FUSION = 5;

%% Read in Piet data (offset version)
disp('Reading XMLs...');
breadcrumbsOffset = containers.Map();
for j = 1:8
    breadcrumbsOffset = loadPietData(sprintf('../Data/dataset%u/contour-%i.xml',...
                                JEFF_DATASET, j), breadcrumbsOffset, j, ...
                                1-120, 1380-120, 1928+30, 3876+30, 300, 4);
end
v = values(breadcrumbsOffset);
keyset = keys(breadcrumbsOffset);
nProcess = length(v);
disp('Done.')

%% Read in Amelio's data --> "labeled"
disp('Reading fusion data...');
labeled = amelio_data_loader(...
    sprintf('../Data/amelio-fusion-%d/fusion/', AMELIO_FUSION));

disp('Done.');

%% Compute rand error
disp('Preparing vectors...');

TestLabels = [];
GTLabels = [];

for j = 1:nProcess,
    nPoints = size(v{j}, 1);
    test = NaN(nPoints, 1);
    gt = NaN(nPoints, 1);
    inRange = 0;
    for k = 1:nPoints,
        if (v{j}(k,1) < size(labeled,2) && v{j}(k,2) < size(labeled,1) && ...
                v{j}(k,1) > 0 && v{j}(k,2) > 0),
            test(k) = labeled(v{j}(k,1), v{j}(k,2), v{j}(k,3));
            gt(k) = j; % we just map keyset{j} to j
            fprintf('%s Label: %d Iteration: %d\n', keyset{j}, test(k), k);
            inRange = 1;
        end
    end
    
    if inRange,
        fprintf('\n');
        test = test(~isnan(test));
        gt = gt(~isnan(gt));
        TestLabels = [TestLabels; int32(test)];
        GTLabels = [GTLabels; int32(gt)];
    end
end

TestLabels = remapLabels(TestLabels);
GTLabels = remapLabels(GTLabels);

disp('Done.');

%%
disp('Computing rand error...');
fprintf('Rand Index: %f\n', RandError(TestLabels, GTLabels));
