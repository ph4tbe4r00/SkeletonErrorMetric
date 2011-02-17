%
% XML parser
%
clear all;
clc;

JEFF_DATASET = 6;
AMELIO_FUSION = 5;


%%
disp('Reading XMLs...');
breadcrumbs = containers.Map();
for j = 1:8
    breadcrumbs = loadPietData(sprintf('../Data/dataset%u/contour-%i.xml',...
                                JEFF_DATASET, j), breadcrumbs, j);
end
v = values(breadcrumbs);
nProcess = length(v);
disp('Done.')

%%
close all;
for j = 1:8
    img = imread(sprintf('../Data/jeff_originals/%i.tif', j));
    figure, imshow(img);
    hold on;
    for i=1:nProcess,
        zvals = v{i}(:,3)==j;  % values at this z-slice
        if size(v{i}(zvals,:), 1) == 1
            col = [0 0 1];
        else
            col = rand(1,3);
        end
        plot(v{i}(zvals,1), v{i}(zvals,2), '.', 'Color', col, 'MarkerSize', 20);
    end
end

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
for j = 1:nProcess
    nPoints = size(v{j}, 1);
    sequences{j} = NaN(nPoints, 1);
    for k = 1:nPoints
         sequences{j}(k) = labeled(v{j}(k, 1), v{j}(k, 2), v{j}(k, 3));
    end
    entropies(j) = discrete_entropy(sequences{j});
end
disp('Done.');

hist(entropies);
