function blp_precomputing(slices, BLP_WEIGHTS_TESS_THRESH, VOLUME)

n = slices;

PATH = sprintf('../Data/v%d_outputs/', VOLUME); 
% relative path to directory with original images and scripts

% addpath(PATH);

tessi = cell(n, 1);
labi = cell(n, 1);
ragi = cell(n, 1);
softi = cell(n, 1);
weightsi = cell(n, 1);
rag = [];
weights = [];
for i = 1:n
    fprintf('  %u of %u...  ', i, n);
    [tessi{i} labi{i} ragi{i} softi{i} weightsi{i}] = ...
        do_things(i, BLP_WEIGHTS_TESS_THRESH, PATH);
    if i > 1
        ragi{i} = ragi{i} + max(ragi{i-1}(:));
        labi{i} = double(labi{i}~=0) .* (labi{i} + max(labi{i-1}(:)));        
    end
    rag = [rag; ragi{i}];  % concatenate
    weights = [weights; weightsi{i}];
end
fprintf('\n');


%%
weights = weights - mean(weights);
weights = weights / std(weights);
% weights = weights + 1;
% weights = 0*weights;

%%
newweights = [];
for i = 1:n-1
    % add 3D crossings in RAG and add weights
    for j = min(ragi{i}(:)):max(ragi{i}(:))
        corrs = unique(labi{i+1}(labi{i} == j));  % labels of image 2, 
        %i.e., already increased by max(rag1(:))
        corrs(corrs == 0) = [];
        rag = [rag; [0*corrs+j corrs]];

        for k = 1:length(corrs)
            newweights = [newweights; sum(sum(labi{i} == j & labi{i+1} == corrs(k)))];
        end

    end
end
%%
newweights = newweights - mean(newweights(:));
newweights = newweights / std(newweights(:));
newweights(newweights > 4) = 4;
newweights = exp(newweights);
newweights = newweights - 1;
%%

% keyboard

weights = [weights; newweights];
%%
nNodes = max(rag(:));
nEdges = size(rag, 1);


save(sprintf('blp_weights_tessthresh_%d_VOLUME_%d', BLP_WEIGHTS_TESS_THRESH, VOLUME), ...
    'tessi', 'labi', ...
    'ragi', 'weightsi', 'rag', 'weights', ...
    'nNodes', 'nEdges');
