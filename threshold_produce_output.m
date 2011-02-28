function [out] = threshold_produce_output(slices, BLP_WEIGHTS_TESS_THRESH, threshold, VOLUME)

n = slices;

PATH = '../co_cluster_distrib/Comparisons/'; 
% relative path to directory with original images and scripts

addpath(PATH);

load(sprintf('blp_weights_tessthresh_%d_VOLUME_%d', BLP_WEIGHTS_TESS_THRESH, VOLUME))


%% thresholding version (bypass b-lp)
x = [rag(weights > threshold, :) ones(sum(weights > threshold), 1)];

%%

% make into R matrix
% x = [x; x(:,[2 1]) x(:,3)]; % 1->2 also needs a 2->1
% R = accumarray({x(:,1), x(:,2)}, x(:,3));

% make this into an image
% labOut1 = lab1;  % make a copy of the labeling
% labOut2 = lab2;  % make a copy of the labeling
lab = zeros(size(labi{1},1),size(labi{1},2),n);
for i = 1 : n
    lab(:,:,i) = labi{i};
end
labOut = lab;
for i = 1:size(x,1)
%     fprintf('%u of %u\n', i, size(x,1));
    oldreg = labOut(lab == x(i,1));  % find the label in the new image @ same location
    labOut(lab == x(i,2)) = oldreg(1);  %oldreg should all be the same
end
% labOut1 = labOut(:,:,1);
% labOut2 = labOut(:,:,2);

% labOut2 = double(labOut2 ~= 0) .* (labOut2 - max(lab1(:))); % convert back to compact labelsl
% show the image
% image(labOut);
%%




out = labOut;

my_map = jet(max(labOut(:)));
my_map = my_map(randperm(size(my_map, 1)),:);
alpha = .75;

origi = cell(n,1);
rgbi = origi;
overlayi = origi;

OUTPUT_PATH = sprintf('../Data/v%d_outputs/threshold/', VOLUME);

for i = 1:n
    origi{i} = double(imread(sprintf(...
        '../Data/v%d_outputs/originals/z=%.6u.png', VOLUME, 1)));
    origi{i} = repmat(origi{i}, [1 1 3]) / 255;
    
    rgbi{i} = ind2rgb(labOut(:,:,i), my_map);
    
    overlayi{i} = alpha*origi{i} + (1-alpha)*rgbi{i};

    imwrite(rgbi{i}, sprintf('%sfusion/z=%.2u.png', OUTPUT_PATH, i), 'png');
    imwrite(overlayi{i}, sprintf('%sfusion-overlay/z=%.2u.png', OUTPUT_PATH, i), 'png');
end


