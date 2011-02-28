function [tess lab rag soft weights] = do_things(Z, THRESH_VAL, PATH)

tess = imread(sprintf('%stessellations/z=%.6u/%.3u.png', PATH, Z, THRESH_VAL));
lab = bwlabel(~tess, 4);
rag = imRAG(lab);
soft = double(imread(sprintf('%sp_bdry/z=%.6u.png', PATH, Z)));

nEdges = size(rag, 1);

% get the weights using the soft output and unreadable code
weights = NaN(nEdges, 1);
for i = 1:nEdges
%     fprintf('%d of %d\n', i, nEdges);

%     lut1 = makelut(@(x) x(2,2) == 0 && any(x(:)),3);
%     lut2 = makelut(@(x) x(2,2) == 0 && any(x(:)),3);
%     lutBG= makelut(@(x) x(2,2), 3);
%     x = applylut(lab==rag(i,1), lut1) & applylut(lab==rag(i,2), lut2) & applylut(lab==0, lutBG);
  
    % the above is equivalent but 20x slower
    x = bwmorph(lab==rag(i,1), 'dilate') & bwmorph(lab==rag(i,2), 'dilate') & lab==0;

    weights(i) = -median(soft(x)); % need - sign because soft is big where boundaries are strong
    % but we want the weights to be affinities
end