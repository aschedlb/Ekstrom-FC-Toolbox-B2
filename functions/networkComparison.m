function [adj,allEdges,nodeDegree,allTitles] = networkComparison(allEdges,plotLabels,comparison)

global condition

if strcmp(comparison,'individual')
    
    adj(:,:,1) = edge2adj([combnk(1:length(plotLabels),2) allEdges(:,1)],[]);
    nodeDegree(1,:) = sum(adj(:,:,1),1);
    
    adj(:,:,2) = edge2adj([combnk(1:length(plotLabels),2) allEdges(:,2)],[]);
    nodeDegree(2,:) = sum(adj(:,:,2),1);
    
    allTitles = condition;
    
elseif strcmp(comparison,'difference')
    
    differenceEdges{1} = setdiff(find(allEdges(:,1)),find(allEdges(:,2)));
    differenceEdges{2} = setdiff(find(allEdges(:,2)),find(allEdges(:,1)));
    differenceEdges{3} = intersect(find(allEdges(:,1)),find(allEdges(:,2)));
    
    for iEdge = 1:2
        foo = zeros(size(allEdges,1),1);
        foo(differenceEdges{iEdge}) = 1;
        allEdges(:,iEdge) = foo;
        adj(:,:,iEdge) = edge2adj([combnk(1:length(plotLabels),2) foo],[]);
        nodeDegree(iEdge,:) = sum(adj(:,:,iEdge),1);
    end
    
    allTitles = {[condition{1},'-',condition{2}];[condition{2},'-',condition{1}]};%;[condition{1},'+',condition{2}]};
    
end

end