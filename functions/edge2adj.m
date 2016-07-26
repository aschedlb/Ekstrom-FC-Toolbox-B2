function [adj] = edge2adj(edges,elecs2remove)

% Creates adjacency matrix from edge matrix

adj = zeros(max(edges(:,2)));

for i = 1:size(edges,1)
    adj(edges(i,1),edges(i,2)) = edges(i,3);
    adj(edges(i,2),edges(i,1)) = edges(i,3);    
end

adj(elecs2remove,:) = [];
adj(:,elecs2remove) = [];

end