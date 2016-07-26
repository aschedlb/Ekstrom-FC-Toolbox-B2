function write2Gephi(edges,plotLabels,plotTitle)

global subjID resultsDir

gephiEdges = edges((edges(:,3) == 1),1:2);

% Edge type: undirected or directed
edgeType = cell(length(gephiEdges),1);
edgeType(:) = {'Undirected'};

% Edge weight
edgeWeight = ones(length(gephiEdges),1);

% Edge table
edgeTableHandle = table(gephiEdges(:,1),gephiEdges(:,2),edgeType,edgeWeight);
edgeTableHandle.Properties.VariableNames = {'Source','Target','Type','Weight'};

% Edge file name
if length(subjID) == 1
    edgeTableName = [resultsDir,'Gephi_Edge_Table_',subjID{1},'_',plotTitle];
else
    edgeTableName = [resultsDir,'Gephi_Edge_Table_group_',plotTitle];
end

% Write node table
nodeTableHandle = table((1:length(plotLabels)),plotLabels);
nodeTableHandle.Properties.VariableNames = {'ID','Label'};
writetable(nodeTableHandle,'Gephi_Node_Table');

% Write edge table
writetable(edgeTableHandle,edgeTableName,'WriteVariableNames',true);

end