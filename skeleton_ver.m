%
% XML parser
%
clear all;
clc;

JEFF_DATASET = 6;
AMELIO_FUSION = 5;

%%
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
disp('Reading XML again (no offset)');
%% the non-offset version
breadcrumbsOriginal = containers.Map();
for j = 1:8
    breadcrumbsOriginal = loadPietData(sprintf('../Data/dataset%u/contour-%i.xml',...
                                JEFF_DATASET, j), breadcrumbsOriginal, j, ...
                                NaN, NaN, NaN, NaN, NaN, NaN);
end
vOriginal = values(breadcrumbsOriginal);

disp('Done.')



%%
% then, if amelio's pixel labels were stored in a 3D integer array, we
% would do the following

% amelio's data --> "labeled"
disp('Reading fusion data...');
labeled = amelio_data_loader(...
    sprintf('../Data/amelio-fusion-%d/fusion/', AMELIO_FUSION));
%% control+page up
disp('Done.');

disp('Computing entropies...');
sequences = cell(nProcess, 1);
entropies = NaN(nProcess, 1);
control_entropies = NaN(nProcess, 1);  % control: random labels

% nlabels = sum(cellfun(@(x) length(unique(x(~isnan(x)))), sequences));  % a joke
nlabels = 10;

for j = 1:nProcess
    nPoints = size(v{j}, 1);
    sequences{j} = NaN(nPoints, 1);
    for k = 1:nPoints
        %{
        if (v{j}(k,1) < size(labeled,1) && v{j}(k,2) < size(labeled,2)),
            sequences{j}(k) = labeled(v{j}(k, 1), v{j}(k, 2), v{j}(k, 3));
        end
        %}
        if (v{j}(k,1) < size(labeled,2) && v{j}(k,2) < size(labeled,1) && ...
                v{j}(k,1) > 0 && v{j}(k,2) > 0),
            sequences{j}(k) = labeled(v{j}(k, 1), v{j}(k, 2), v{j}(k, 3));
            fprintf('%s %d\n', keyset{j}, k);
        end
    end
    entropies(j) = discrete_entropy(sequences{j});
    control_entropies(j) = discrete_entropy(ceil(rand(1, length(sequences{j}))*nlabels));
end
disp('Done.');

hist(entropies);
entropies



%% JEFF

for j = 1:1
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




%%

% close all;
for j = 1:1
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