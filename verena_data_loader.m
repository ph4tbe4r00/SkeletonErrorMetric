function [out] = verena_data_loader(slices)

load for_dan;
out = labOut;
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
