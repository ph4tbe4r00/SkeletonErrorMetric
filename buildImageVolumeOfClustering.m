%buildImageVolumeOfClustering(graphInfo, weightMatrix)
%weightMatrix should be cost matrix, not similarity!
function numberOfValidClusters = buildImageVolumeOfClustering(graphInfo, regionInfo, clusterIds, imsize, minClusterSize, maxClusterSize, doColorImages)

clusterIds = crushClusterLabels(clusterIds);
colorValues = round(rand(length(clusterIds),3)*255);

if ~doColorImages & ~exist(num2str(minClusterSize))
  disp('creating directory');
  mkdir(num2str(minClusterSize))
end

numberOfValidClusters = 0;
for i=1:length(graphInfo)
  disp([i length(graphInfo)]);
  c = graphInfo(i).c;
  im = zeros(imsize);
  imc = zeros(size(im,1),size(im,2),3);
  for j=1:size(c,1)
    %get clusterID for region
    id = clusterIds(c(j,5));

    %test if cluster is large enough
    if length(find(clusterIds==id))<minClusterSize | length(find(clusterIds==id))>=maxClusterSize
      continue
    end

    %put region into image
    im(regionInfo(c(j,5)).PixelIdxList) = mod(id,254)+1;
    
    %make color image
    
    imcTmp = zeros(size(im));
    imcTmp(regionInfo(c(j,5)).PixelIdxList) = 1;
    imc(:,:,1) = imc(:,:,1) + imcTmp*colorValues(id,1);
    imc(:,:,2) = imc(:,:,2) + imcTmp*colorValues(id,2);
    imc(:,:,3) = imc(:,:,3) + imcTmp*colorValues(id,3);
  
%    disp('found one');
numberOfValidClusters = numberOfValidClusters + 1;
  end
  
  
  %write section image
  if doColorImages
    imwrite(uint8(imc),strcat('clusterVolume_',imageFileName(i),'.tif'),'tif');
  else
    imwrite(uint8(im),strcat(num2str(minClusterSize),'\clusterVolume_',imageFileName(i),'.tif'),'tif');
  end
end

[tmp1,i1,tmp2] = unique(sort(clusterIds),'first');
[tmp1,i2,tmp2] = unique(sort(clusterIds),'last');
largestClusterSize = max(i2-i1)+1;