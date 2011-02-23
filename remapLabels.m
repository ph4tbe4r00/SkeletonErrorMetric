function [rLabels] = remapLabels(labels)

remapM = containers.Map();

uLabels = unique(labels);
for i = 1:length(uLabels),
    remapM(int2str(uLabels(i))) = i-1;
end

% there probably is a better vectorized solution ...
rLabels = zeros(size(labels));
for i = 1:length(labels),
    rLabels(i) = remapM(int2str(labels(i)));
end

end