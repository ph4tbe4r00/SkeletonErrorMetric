function [out] = amelio_data_loader(folder, slices)

out = NaN(276, 195, slices);

for i = 1:slices
    x = int32(imread(sprintf('%sz=%.2d.png', folder, i)));
    y = x(:,:,1) + 256*x(:,:,2) + (256^2)*x(:,:,3);
    out(:,:,i) = y;
end
% 
% uLabels = [];
% for i = 1:slices,
%     uLabels = [uLabels; unique(out(:,:,i))];
% end
% 
% uLabels = unique(uLabels);
% 
% UnlabeledM = containers.Map();
% for j = 1:length(uLabels),
%     UnlabeledM(int2str(uLabels(j))) = 1;
% end
% 
% end
%     