function Hs = discrete_entropy(s)

% get counts

us = unique(s);

if length(us) > 1
    counts = hist(s, unique(s));
else
    counts = length(s);
end

% normalize
p = counts / length(s);

% compute entropy
Hs = -sum(p.*log(p));