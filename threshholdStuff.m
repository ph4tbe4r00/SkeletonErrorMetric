function [labeled] = threshholdStuff(labeled)

ThRESH = 0;

unlabeledKeys = unique(labeled);
%{
clusterSize = [];
for j = 1:size(labeled,3)
    slice = labeled(:,:,j);
    for i = 1:length(unlabeledKeys)
        if ~isempty(find(slice == unlabeledKeys(i)))
            clusterSize = [clusterSize; length(find(slice == unlabeledKeys(i)))];
        end
    end
end
%}

for j = 1:size(labeled,3)
    slice = labeled(:,:,j);
    for i = 1:length(unlabeledKeys)
        if length(find(slice == unlabeledKeys(i))) < ThRESH
            slice( slice == unlabeledKeys(i)) = -1;
        end
    end
    labeled(:,:,j) = slice;
end

end

