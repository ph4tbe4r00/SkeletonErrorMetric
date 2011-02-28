function [graphInfo, regionInfo, NodeToImgM] = buildGraphAndRegionInfo(VOLUME, SLICES, TESSLEVEL)
nodeCounter = 1;
graphInfo = struct();
regionInfo = struct();
NodeToImgM = containers.Map();

disp('building graph and region info');
for i=1:SLICES
    im = imread(sprintf('../Data/v%d_outputs/tessellations/z=%.6u/%.3u.png', VOLUME, i, TESSLEVEL));
    
    im = ~im; % added by dan to flip white to black
    % our boundary was white, region black
    % verena has boundary black, region white
    
    % for some reason .... they were doing 8 connectivity?
    %s = regionprops(im>0,'Centroid','PixelIdxList','Area','Eccentricity','MajorAxisLength','MinorAxisLength');
    
    % fixed version
    s = regionprops(bwconncomp(im,4),'Centroid','PixelIdxList','Area','Eccentricity','MajorAxisLength','MinorAxisLength');
    c = [];
    avgSize = 0;
    for j=1:length(s)
        avgSize = avgSize + s(j).Area;
    end
    fprintf('Average size: %f\n', avgSize/length(s));
    
    for j=1:length(s)
        cs = round(s(j).Centroid);
        %if (s(j).Area > avgSize/length(s))
        if (s(j).Area > 100)
            c = [c; [cs(1) cs(2) i double(median(double(im(s(j).PixelIdxList)))) nodeCounter s(j).Area s(j).MajorAxisLength s(j).MinorAxisLength]];
            regionInfo(nodeCounter).PixelIdxList = s(j).PixelIdxList;
            NodeToImgM(int2str(nodeCounter)) = i;
            nodeCounter = nodeCounter+1;
        end
    end
    graphInfo(i).c = double(c);
    graphInfo(i).imgName = sprintf('z=%.6u-%.3u.png', i, TESSLEVEL);
end