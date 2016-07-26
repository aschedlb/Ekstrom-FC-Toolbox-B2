function Plot3DGraph_vararg(elecNums,elecLabels,edges,centerCoords,varargin)

% Description: Plots the networks in 3D space
% IMPORTATNT: The variables used when calling this function must exactly be
% named at the default variables below!!!

% Inputs
% elecNums: numeric indices of channels plotted in the order they are input
% elecLabels: cell array of ROI labels
% edges: n X 3 array of edges where first column = e1 number, second column = e2 number, and third column = edge weight
% centerCoords: n x 3 array of coordinates for cube centers
% Expected variable arguements: saveDir, plotTitle, edgeColor, nodeColor, edgeWidth

% Output
% Saves plots of networks

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Default variable arguments
saveDir = 'No Save';
plotTitle = 'Unknown';
edgeColor = zeros(length(edges),3); % all edges black ([0 0 0])
edgeWidth = 3*ones(length(edges),1);
nodeColor = zeros(length(elecNums),3); % all nodes black
nodeTextColor = 'k';
nodeSize = 1000*ones(1,length(elecNums));

% Handles varargs
possible_args = {'saveDir','plotTitle','edgeColor','nodeColor','edgeWidth','nodeTextColor','nodeSize'};

for iArg = 1:length(varargin)
    foo_var = inputname(4+iArg);
    fooIdx = find(strcmp(foo_var,possible_args));
    eval([possible_args{fooIdx},'= varargin{iArg};'])
end

nNodes = length(elecNums);

% Set up figure
figure('Position',[1 1 900 800]);
hold on;
axis off
set(gca,'XTickLabel',[],'YTickLabel',[])

% Sort edges from small to big so that biggest edges are plotted last and
% are superimposed over the weak ones
[~,sortIdx] = sort(edges(:,3),'ascend');
edges = edges(sortIdx,:);
edgeColor = edgeColor(sortIdx,:);
edgeWidth = edgeWidth(sortIdx);

% Plot edges first so that nodes are superimposed over the end of each line
for iEdge = 1:size(edges,1)
    
    if edges(iEdge,3) >0
        
        % Determine node elec numbers
        e1Node = edges(iEdge,1);
        e2Node = edges(iEdge,2);
        
        % Determine the nodes x and y location
        e1X = centerCoords(e1Node,1);
        e2X = centerCoords(e2Node,1);
        e1Y = centerCoords(e1Node,2);
        e2Y = centerCoords(e2Node,2);
        e1Z = centerCoords(e1Node,3);
        e2Z = centerCoords(e2Node,3);
        
        % Plot line between points
        line([e1X e2X],[e1Y e2Y],[e1Z e2Z],'Color',edgeColor(iEdge,:),'LineWidth',edgeWidth(iEdge))
        
    else
        edges(iEdge,3) = NaN;  %zero out nonsignificant edges -> this will effect degree calculation
    end
    
end

for iNode = 1:nNodes
    
    % Plots nodes
    scatter3(centerCoords(iNode,1),centerCoords(iNode,2),centerCoords(iNode,3),nodeSize(iNode),nodeColor(iNode,:),'filled');
    
    % Plot node labels
    text(centerCoords(iNode,1),centerCoords(iNode,2),centerCoords(iNode,3),char(elecLabels(iNode)),'Color',nodeTextColor(iNode,:),'FontSize',16,'FontWeight','bold');
    
end

title(plotTitle,'FontSize',40);

if ~strcmp(saveDir,'No Save')
    cd(saveDir)
    saveTitle = (plotTitle);
    screen2jpeg(saveTitle)
end

end