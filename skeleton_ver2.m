clear all;
clc;

JEFF_DATASET = 7;
AMELIO_FUSION = 5;
SLICES = 8;

%% Read in Piet data 
disp('Reading XMLs...');
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

disp('Done.')

%% Read in Amelio's data --> "labeled"
disp('Reading fusion data...');
[labeled, UnlabeledM] = amelio_data_loader(...
    sprintf('../Data/amelio-fusion-%d/fusion/', AMELIO_FUSION), SLICES);
fprintf('Number unique labels: %d\n', length(keys(UnlabeledM)));
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
            v{j}
            test(k) = labeled(v{j}(k,2), v{j}(k,1), v{j}(k,3));
            gt(k) = j; % we just map keyset{j} to j
            fprintf('%s Label: %d Iteration: %d\n', keyset{j}, test(k), k);
            inRange = 1;
            % if the current label lies inside a skeleton, we remove it 
            % from the unlabeled set
            if isKey(UnlabeledM, int2str(test(k))),
                remove(UnlabeledM, int2str(test(k)));
            end
        end
    end
    
    if inRange,
        fprintf('\n');
        test = test(~isnan(test));
        gt = gt(~isnan(gt));
        TestLabels = [TestLabels; test];
        GTLabels = [GTLabels; gt];
    end
end

% At this point, the unique set will contain those clusters in fusion that
% do not have a label from the skeletons
numUnlabeled = length(keys(UnlabeledM));
fprintf('Num unlabeled clusters: %d\n', numUnlabeled);

TestLabels = remapLabels(TestLabels);
GTLabels = remapLabels(GTLabels);

% pad TestLabels with a unique name for each segement in Fusion that does
% not have a skeleton
%TestLabels = [TestLabels; (length(TestLabels):length(TestLabels)+numUnlabeled-1)'];

% pad GTLabels with 1 name for each segement in GT that does not have a
% skeleton
%GTLabels = [GTLabels; length(GTLabels)*ones(numUnlabeled,1)];

disp('Done.');

%% Plot data
%{
disp('Overlaying skeletons on fusion output...');
for j = 1:SLICES
    img = imread(sprintf(...
        '../Data/amelio-fusion-%d/fusion_overlay/z=%.2d.png', AMELIO_FUSION, j));
    figure, imshow(img, 'InitialMagnification', 300);
    hold on;
    for i=1:nProcess,
        zvals = v{i}(:,3)==j;  % values at this z-slice
        if isempty(zvals)
            continue;
        end

        toplot = v{i}(zvals,:);

        if size(toplot, 1) == 1
            col = [0 0 1];
        else
            col = rand(1,3);
        end
        
        for k = 1:size(toplot, 1) % plot each point separately to check bounds
            if (toplot(k,1) < size(labeled,2) && toplot(k,2) < size(labeled,1) && ...
                    toplot(k,1) > 0 && toplot(k,2) > 0),
                plot(toplot(k,1), toplot(k,2), '.', 'Color', col, 'MarkerSize', 20);
            end
        end
    end
end
%}
%% Plot original
%{
for j = 1:SLICES
    img = imread(sprintf(...
        '../Data/jeff_originals/%d.tif', j));
    figure, imshow(img, 'InitialMagnification', 25);
    hold on;
    for i=1:nProcess,
        zvals = vOriginal{i}(:,3)==j;  % values at this z-slice
        if isempty(zvals)
            continue;
        end

        toplot = vOriginal{i}(zvals,:);

        if size(toplot, 1) == 1
            col = [0 0 1];
        else
            col = rand(1,3);
        end
        
        for k = 1:size(toplot, 1) % plot each point separately to check bounds
            plot(toplot(k,1), toplot(k,2), '.', 'Color', col, 'MarkerSize', 20);
        end
    end
end
%}
%%
disp('Computing rand error...');
fprintf('Rand error: %f\n', RandError(TestLabels, GTLabels));
