function weightMatrix = buildGraphWeightMatrixDist(graphInfo, regionInfo)
c = double(graphInfo(end).c);  
n = double(c(end,5));
weightMatrix = sparse(n,n);

%now fill matrix with distances
for i=1:length(graphInfo);
  [i length(graphInfo)]
  if i==1
    disp('first layer');
    c1 = double(graphInfo(i+1).c);
    c2 = double(graphInfo(i).c);
    c3 = double(graphInfo(i+1).c);
  elseif i==length(graphInfo)
    disp('last layer');
    c1 = double(graphInfo(i-1).c);
    c2 = double(graphInfo(i).c);
    c3 = double(graphInfo(i-1).c);
  else
    c1 = double(graphInfo(i-1).c);
    c2 = double(graphInfo(i).c);
    c3 = double(graphInfo(i+1).c);
  end
  
  for j=1:size(c2,1)
% $$$     [j size(c2,1)]

    %weights for all points from upper layer
    c2t = repmat(c2(j,:),size(c1,1),1);
    dist = (c1(:,1:2) - c2t(:,1:2)).^2;
    dist = sum(dist')';
    
    ind1 = ones(size(c1,1),1).*c2(j,5);
    ind2 = c1(:,5);
    ind = sub2ind(size(weightMatrix),ind1,ind2);
    
    % distance function
    weightMatrix(ind) = 1+(dist);    

    %weights for all points form lower layer
    c2t = repmat(c2(j,:),size(c3,1),1);
    dist = (c3(:,1:2) - c2t(:,1:2)).^2;
    dist = sum(dist')';
    
    ind1 = ones(size(c3,1),1).*c2(j,5);
    ind2 = c3(:,5);
    ind = sub2ind(size(weightMatrix),ind1,ind2);
    
    % distance function
    weightMatrix(ind) = 1+(dist);
  end
end

%tmp = weightMatrix(find(weightMatrix(:)~= 0));
%weightMatrix = weightMatrix - mean(weightMatrix(:));
%weightMatrix = weightMatrix ./ sqrt(std(weightMatrix(:)));
%weightMatrix = exp(weightMatrix);
%size(weightMatrix)

%sanity check.. matrix has to be symmetric
test = weightMatrix ~= (weightMatrix');
ind = find(test);
disp(strcat('Sanity check: This number should be zero: ', num2str(length(ind))));
end

function out = normalizeDist(dist)
    out = dist - mean(dist);
    %out = out / std(out);
    %out = out - min(out);
    %out = exp(out);
end

