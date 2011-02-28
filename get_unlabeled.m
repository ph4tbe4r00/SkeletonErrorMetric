function UnlabeledM = get_unlabeled(out, slices)

verbose = 0;

uLabels = [];
for i = 1:slices,
    uLabels = [uLabels; unique(out(:,:,i))];
end

uLabels = unique(uLabels);

if verbose
    fprintf('Unique Labels: %d\n', length(uLabels));
end

UnlabeledM = containers.Map();
for j = 1:length(uLabels),
    UnlabeledM(int2str(uLabels(j))) = 1;
end
