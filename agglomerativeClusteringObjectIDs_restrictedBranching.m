% [clusterIds, minCosts] = agglomerativeClusteringObjectIDs(weightMatrix, maxCounter, graphInfo, noBranching)
function [clusterIds, minCosts] = agglomerativeClusteringObjectIDs_restrictedBranching(weightMatrix, maxCounter, graphInfo, maxCost)
  disp('allPoints');
  allPoints = [];
  for i=1:length(graphInfo)
    c = graphInfo(i).c;
    allPoints = [allPoints; c];
  end

  c = graphInfo(end).c;
  n = double(c(end,5));
  
  %weightMatrixCopy
  wmc = weightMatrix;
  %clusterIds = zeros(size(wmc,1),1);
  clusterIds = [1:size(wmc,1)];
  idCounter = 1;
  
  minCosts = 0;
  minCost = 10;
  counter = 1;
  
  indTmp = find(wmc>0);
  ind2 = find(wmc>0);
  [weightValues, ind] = sort(wmc(indTmp));
  ind = indTmp(ind);
  indCounter = 0;
  
  disp('start clustering');
  tic;
  while (indCounter<length(ind)) & (counter<maxCounter) & (minCosts(end)<=maxCost)
    %find points with minimal cost
    
  
    indCounter = indCounter+1;
    
    if (wmc(ind(indCounter))==0)
      continue;
    end

%    disp(strcat('***',num2str(counter),'***'));
    
    if (mod(counter,100)==0);
      toc;
      disp(num2str(counter));
      
      [tmp1,i1,tmp2] = unique(sort(clusterIds),'first');
      [tmp1,i2,tmp2] = unique(sort(clusterIds),'last');
      max(i2-i1)
      clear i1 i2 tmp1 tmp2
      
      save(strcat('clusterIds_minCosts_',imageFileName(counter),'.mat'),'clusterIds','minCosts');
      tic;
    end

    minCost = weightValues(indCounter);
    minCosts = [minCosts; minCost];
    [p1,p2] = find(wmc==minCost);
    
    p1 = p1(1);
    p2 = p2(1);
    
    %update objectIds
    idKeep = min(clusterIds(p1),clusterIds(p2));
    idMerge = max(clusterIds(p1),clusterIds(p2));
    
    clusterIds(find(clusterIds == idMerge)) = idKeep;

    wmc(p1,p2) = 0;
    wmc(p2,p1) = 0;

    %get section of p1
    section1 = allPoints(p1,3);
    section2 = allPoints(p2,3);

    %set all connections from p1 to section2 0
    s2c = graphInfo(section2).c;
    
    wmcInd = find(wmc~=0);

    wmcIndDel = sub2ind(size(wmc),repmat(p1,length(s2c(1,5):s2c(end,5)),1),[s2c(1,5):s2c(end,5)]');
    wmcIndDel = [wmcIndDel; sub2ind(wmcIndDel, sub2ind(size(wmc),[s2c(1,5):s2c(end,5)]',repmat(p1,length(s2c(1,5):s2c(end,5)),1)))];
    
% $$$     wmc(p1,s2c(1,5):s2c(end,5)) = 0;
% $$$     wmc(s2c(1,5):s2c(end,5),p1) = 0;
  
    
    %set all connections from p2 to section1 0
    s1c = graphInfo(section1).c;
    
    wmcIndDel = [wmcIndDel; sub2ind(size(wmc),repmat(p2,length(s1c(1,5):s1c(end,5)),1),[s1c(1,5):s1c(end,5)]')];
    wmcIndDel = [wmcIndDel; sub2ind(size(wmc),[s1c(1,5):s1c(end,5)]',repmat(p2,length(s1c(1,5):s1c(end,5)),1))];

    wmcInd(ismember(wmcInd,wmcIndDel)) = [];
    [rows,cols] = ind2sub(size(wmc),wmcInd);
    wmc = sparse(rows, cols, wmc(wmcInd),size(wmc,1),size(wmc,2));
% $$$     wmc(p2,s1c(1,5):s1c(end,5)) = 0;
% $$$     wmc(s1c(1,5):s1c(end,5),p2) = 0;

    counter = counter+1;
  end
  
if (indCounter==length(ind))
  disp('*** reached maximal number of iterations ***');
  indCounter
end

    

