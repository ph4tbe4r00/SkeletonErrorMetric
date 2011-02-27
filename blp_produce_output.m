function [out] = blp_produce_output(slices, BLP_WEIGHTS_TESS_THRESH )


n = slices;

PATH = '../co_cluster_distrib/Comparisons/'; 
% relative path to directory with original images and scripts

addpath(PATH);

load(sprintf('blp_weights_tessthresh_%d', BLP_WEIGHTS_TESS_THRESH))


%%
% create textfile
current_dir = pwd;
cd(PATH);
fid = fopen('blp_temp_input.txt', 'w');
fprintf(fid, '%u %u\n', nNodes, nNodes);
for i = 1 : nEdges
    fprintf(fid, '%u %u %f\n', rag(i, 1)-1, rag(i, 2)-1, weights(i));  %-1 to index from 0
end
fclose(fid);

% run the thing
system('./run_blp.sh > blp_temp_output.txt');

fid = fopen('blp_temp_output.txt');
x = cell2mat(textscan(fid, '%u %u %u\n'));
x(:,1:2)=x(:,1:2)+1;

cd(current_dir);

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


OUTPUT_PATH = '../Data/v2_outputs/blp/';

for i = 1:n
    origi{i} = double(imread(sprintf('or/z=%.6u.png', 1)));
    origi{i} = repmat(origi{i}, [1 1 3]) / 255;
    
    rgbi{i} = ind2rgb(labOut(:,:,i), my_map);
    
    overlayi{i} = alpha*origi{i} + (1-alpha)*rgbi{i};
    
    saveas(rgbi{i}, sprintf('%sfusion/z=%.2u.png', OUTPUT_PATH, i), 'png');
    saveas(overlayi{i}, sprintf('%sfusion-overlay/z=%.2u.png', OUTPUT_PATH, i), 'png');
end


