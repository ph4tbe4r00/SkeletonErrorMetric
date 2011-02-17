function Hs = discrete_entropy(s)

% get counts
counts = hist(s, unique(s));

% normalize
p = counts / length(s);

% compute entropy
Hs = -sum(p.*log(p));