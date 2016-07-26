function [edge] = adj2edge(adj,elecs2Remove)

% Creates an adj matrix back to edge matrix

nNodes = size(adj,1) + length(elecs2Remove);

pairs = combnk(1:nNodes,2);

if elecs2Remove
    for iRemove = elecs2Remove
        [foo,~] = find(pairs == iRemove);
        pairs(foo,:) = [];
        
        adj = insertrows(adj,zeros(1,size(adj,2)),iRemove-1);
        adj = insertrows(adj',zeros(1,size(adj,1)),iRemove-1);
    end
end

lineIndex = sub2ind([nNodes nNodes],pairs(:,1),pairs(:,2));

edge = adj(lineIndex);

edge = [pairs edge];

end