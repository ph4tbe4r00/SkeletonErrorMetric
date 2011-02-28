function randerror = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v)


verbose = 0;

%% Compute rand error
if verbose
    disp('Preparing vectors...');
end

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
            test(k) = labeled(v{j}(k,2), v{j}(k,1), v{j}(k,3));
            gt(k) = j; % we just map keyset{j} to j
            if verbose
                fprintf('%s Label: %d Iteration: %d\n', keyset{j}, test(k), k);
            end
            inRange = 1;
            % if the current label lies inside a skeleton, we remove it 
            % from the unlabeled set
            if isKey(UnlabeledM, int2str(test(k))),
                remove(UnlabeledM, int2str(test(k)));
            end
        end
    end
    
    if inRange,
        if verbose
            fprintf('\n');
        end
        test = test(~isnan(test));
        gt = gt(~isnan(gt));
        TestLabels = [TestLabels; test];
        GTLabels = [GTLabels; gt];
    end
end

% At this point, the unique set will contain those clusters in fusion that
% do not have a label from the skeletons
numUnlabeled = length(keys(UnlabeledM));
if verbose
    fprintf('Num unlabeled clusters: %d\n', numUnlabeled);
end

TestLabels = remapLabels(TestLabels);
GTLabels = remapLabels(GTLabels);

% pad TestLabels with a unique name for each segement in Fusion that does
% not have a skeleton
% TestLabels = [TestLabels; (length(TestLabels):length(TestLabels)+numUnlabeled-1)'];
% 
% % pad GTLabels with 1 name for each segement in GT that does not have a
% % skeleton
% GTLabels = [GTLabels; length(GTLabels)*ones(numUnlabeled,1)];

if verbose
    disp('Done.');
end

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
if verbose
    disp('Computing rand error...');
end
randerror = RandError(TestLabels, GTLabels);
if verbose
    fprintf('Rand error: %f\n', randerror);
end
