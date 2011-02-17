%
% XML parser
%
clc;

%%
breadcrumbs = containers.Map();
for j = 1:8
    breadcrumbs = loadPietData(sprintf('dataset5/contour-%i.xml', j), breadcrumbs, j);
end

%%
close all;
v = values(breadcrumbs);
nProcess = length(values);
for j = 1:8
    img = imread(sprintf('dataset5/%i.tif', j));
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
labeled = [];

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


