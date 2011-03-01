function [randerror col row] = skeleton_ver2(labeled, UnlabeledM, nProcess, keyset, v, vOriginal)


verbose = 1;

%% Compute rand error
if verbose
    disp('Preparing vectors...');
end

TestLabels = [];
GTLabels = [];
perSkeletonRandError = NaN(nProcess,1);
perSkeletonColError = NaN(nProcess,1);
perSkeletonRowError = NaN(nProcess,1);

%{
length(unlabeledKeys)
for i = 1:length(unlabeledKeys)
    for j = 1:size(labeled,3)
        if isKey(UnlabeledM, unlabeledKeys{i})
            
            if length(find(labeled(:,:,j) == str2int(unlabeledKeys{i}))) < 200,
                if isKey(UnlabeledM, unlabeledKeys{i})
                    remove(UnlabeledM, unlabeledKeys{i});
                end
            end
        end
    end
end
%}
hackhack = 0;
for j = 1:nProcess,
    nPoints = size(v{j}, 1);
    test = NaN(nPoints, 1);
    gt = NaN(nPoints, 1);
    inRange = 0;
    for k = 1:nPoints,
        if (v{j}(k,1) < size(labeled,2) && v{j}(k,2) < size(labeled,1) && ...
                v{j}(k,1) > 0 && v{j}(k,2) > 0) %...
          %      && length(find(labeled(:,:,v{j}(k,3)) == labeled(v{j}(k,2), v{j}(k,1), v{j}(k,3)))) > 100, % threshhold
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
                hackhack = hackhack+1;
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
        
        tmpTest = remapLabels(test);
        tmpGT = remapLabels(gt);
        [perSkeletonRandError(j) perSkeletonColError(j) perSkeletonRowError(j)] = RandError(tmpTest, tmpGT);
    end
end
hackhack

% At this point, the unique set will contain those clusters in fusion that
% do not have a label from the skeletons

numUnlabeled = length(keys(UnlabeledM));
if verbose
    fprintf('Num unlabeled clusters: %d\n', numUnlabeled);
    fprintf('Num labeled clusters: %d\n', hackhack);
end

TestLabels = remapLabels(TestLabels);
GTLabels = remapLabels(GTLabels);

% pad TestLabels with a unique name for each segement in Fusion that does
% not have a skeleton
TestLabels = [TestLabels; (length(TestLabels):length(TestLabels)+numUnlabeled-1)'];
% 
% % pad GTLabels with 1 name for each segement in GT that does not have a
% % skeleton
GTLabels = [GTLabels; length(GTLabels)*ones(numUnlabeled,1)];

%{
tmptmp = imread(sprintf('../Data/v%d_outputs/tessellations/z=%.6u/%.3u.png', 2, 1, 33));
orgImgs = zeros(size(tmptmp,1), size(tmptmp,2), 3);
for i = 1:size(labeled,3)
    orgImgs(:,:,i) = imread(sprintf('../Data/v%d_outputs/tessellations/z=%.6u/%.3u.png', 2, i, 33));
end
my_map = jet(length(unique(labeled)));
my_map = my_map(randperm(size(my_map, 1)),:);

rgbi = cell(size(labeled,3),1);
for i = 1:size(labeled,3)
    rgbi{i} = ind2rgb(labeled(:,:,i), my_map);
end

figure;
for i = 1:size(labeled,3)
    subplot(1,size(labeled,3),i);
    imshow(rgbi{i});
end
%}

if verbose
    disp('Done.');
end

%% Plot data
%{
disp('Overlaying skeletons on fusion output...');
for j = 1:1
    img = imread(sprintf(...
        '../Data/v%d_outputs/amelio/fusion_overlay/z=%.2d.png', 3, j));
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
%}
%%
if verbose
    disp('Computing rand error...');
end
[randerror col row] = RandError(TestLabels, GTLabels);
%keyboard
if verbose
    fprintf('Rand error: %f\n', randerror);
    %figure,hist(perSkeletonRandError, 50);
    %perSkeletonRandError = perSkeletonRandError(~isnan(perSkeletonRandError));
    %avg = sum(perSkeletonRandError)/length(perSkeletonRandError);
    %fprintf('Avg per-skeleton error: %f\n', avg);
    %figure,hist(perSkeletonColError, 50);
    %figure,hist(perSkeletonRowError, 50);
end
