function [labeled] = threshholdStuff(labeled)

ThRESH = 200;

unlabeledKeys = unique(labeled);
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

