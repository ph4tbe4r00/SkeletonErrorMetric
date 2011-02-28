function [randIndex colMistakes rowMistakes] = RandError(A, B)
% A and B must be the same size. they are matrices/vectors containing integer labels
% returns NaN for images of size 1 pixel since there are no pairs

A = A(:)+1;
B = B(:)+1;
N = length(A);

% create overlap matrix
Obj = accumarray({A, B}, ones(N, 1));

% for now, ignore all background pixels
% Obj = Obj(2:end, 2:end);

% compute mistakes, making use of: cross terms = (sum n)^2/2 - sum(n^2)
colMistakes = sum(sum(Obj, 1).^2 - sum(Obj.^2, 1))/2;
rowMistakes = sum(sum(Obj, 2).^2 - sum(Obj.^2, 2))/2;

colMistakes = colMistakes/(N*(N-1)/2);
rowMistakes = rowMistakes/(N*(N-1)/2);

% divide by number of pairs
randIndex = (colMistakes + rowMistakes);

