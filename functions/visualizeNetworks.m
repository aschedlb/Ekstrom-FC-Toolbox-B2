
function [adj,allTitles,comparison] = visualizeNetworks(aalRegions,centerCoords,alphaIndex,plotLabels,sortPlotNodes)

% This function has the user choose the type of networks they would like to
% see. There are six options:
%   -   Circle: plots the network in 2D spaces with the nodes distributed 
%       evenly around a circle
% 	-	3D brain space: plots the network in 3D brain space with the nodes 
%       located at the coordinates specified by centerCoords_condition.mat
% 	-	Gephi: outputs a node table and edge table in CSV files that can be 
%       loaded into Gephi for better visualization
% 	-	BrainNet Viewer: outputs a .node and .edge file that can be loaded 
%       into BrainNet Viewer for better visualization
% 	-	Individual: plots each condition by itself
% 	-	Difference: plots the set differences and union (of edges) between
%       two conditions
% Ouptut: JPEG or EPS files of the plotted networks
%         CSV-files to input into Gephi
%         .node and .edges files to input into BrainNetViewer

global resultsDir condition

% Check inputs
if nargin ~= 5
    error('Not the correct amount of inputs!')
end

% Plot specifications
[configuration,comparison] = chooseGraph;

% Get data
cd(resultsDir)

[fileName,pathName,~] = uigetfile('Bootstrap_*.mat',...
	'Please select which data you would like to visualize (condition 1).');
load([pathName,fileName])

if ~isempty(strfind(fileName,condition{1}))
    allEdges(:,1) = edgesAll(:,alphaIndex(1));
elseif ~isempty(strfind(fileName,condition{2}))
    allEdges(:,2) = edgesAll(:,alphaIndex(1));
else
    error('The file chosen does not match the conditions entered.')
end

[fileName,pathName,~] = uigetfile('Bootstrap_*.mat',...
	'Please select which data you would like to visualize (condition 2).');
load([pathName,fileName])

if ~isempty(strfind(fileName,condition{1}))
    allEdges(:,1) = edgesAll(:,alphaIndex(2));
elseif ~isempty(strfind(fileName,condition{2}))
    allEdges(:,2) = edgesAll(:,alphaIndex(2));
else
    error('The file chosen does not match the conditions entered.')
end

allEdges(allEdges > 0) = 1; %Binarize the edge weights

% Modulates and preps data structure for visualization
[adj,allEdges,nodeDegree,allTitles] = networkComparison(allEdges,plotLabels,comparison);

% Node color parameters
degreeRange = min(nodeDegree(:)):max(nodeDegree(:));
cmap = jet(length(degreeRange));

% Create colorbar
if strcmp(configuration,'circle') || strcmp(configuration,'3D')
    cbarTitle = 'Node Degree';
    makeColorbar(degreeRange,cmap,cbarTitle,allTitles)
end

% Save info
saveDir = resultsDir;

for iCond = 1:length(condition)
    
    edges = [combnk(1:length(plotLabels),2) allEdges(:,iCond)];
    
    % Node Size
    nodeSize = 300 + exp((nodeDegree(iCond,:) - (min(degreeRange)-1)).^(1-max(degreeRange)/10));
    nodeSize = nodeSize(sortPlotNodes);
    
    % Node Color to match node degree
    nodeColor = cmap((nodeDegree(iCond,:) - (min(degreeRange)-1)),:);
    nodeColor = nodeColor(sortPlotNodes,:);
    nodeTextColor = nodeColor;
    
    % Edge Color
	edgeColors = zeros(length(edges),3,2);
    edgeColor = edgeColors(:,:,iCond);
    
    % Save info
    plotTitle = allTitles{iCond};
    
    if strcmp(configuration,'circle')
        % PlotCircleGraph_vararg(elec_nums,elec_labels,edges,varargin)
        % possible_args = {'saveDir','plotTitle','edgeColor','nodeColor','edgeWidth','nodeTextColor'};
        PlotCircleGraph_vararg(sortPlotNodes,plotLabels(sortPlotNodes),...
            edges,nodeSize,nodeColor,nodeTextColor,edgeColor,plotTitle,saveDir)
    elseif strcmp(configuration,'3D')
        Plot3DGraph_vararg(sortPlotNodes,plotLabels(sortPlotNodes),...
            edges,centerCoords(sortPlotNodes,:),nodeSize,nodeColor,nodeTextColor,edgeColor,plotTitle,saveDir)
    elseif strcmp(configuration,'Gephi')
        write2Gephi(edges,plotLabels,plotTitle) % Outputs edge info to a CSV-File for network visualzation in Gephi
    elseif strcmp(configuration,'BrainNet Viewer')
        write2BrainNetViewer(aalRegions,adj(:,:,iCond),nodeDegree(iCond,:),plotTitle) % Outputs .node and .edge files for network visualization in BrainNet Viewer
    end
    
end

end
