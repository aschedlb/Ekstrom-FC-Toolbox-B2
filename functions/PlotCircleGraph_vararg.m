
function PlotCircleGraph_vararg(elecNums,elecLabels,edges,varargin)

% Description: Plots the networks in circular form
% IMPORTATNT: The variables used when calling this function must exactly be
% named at the default variables below!!!

% Inputs
% elecNums: numeric indices of channels plotted in the order they are input
% elecLabels: cell array of ROI labels
% edges: n X 3 array of edges where first column = e1 number, second column = e2 number, and third column = edge weight
% Expected variable arguements: saveDir, plotTitle, edgeColor, nodeColor, edgeWidth

% Output
% Saves plots of networks

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Default variable arguments
saveDir = 'No Save';
plotTitle = 'Unknown';
edgeColor = zeros(length(edges),3); % all edges black ([0 0 0])
edgeWidth = 1*ones(length(edges),1);
nodeColor = zeros(length(elecNums),3); % all nodes black
nodeTextColor = zeros(length(elecNums),3);
nodeSize = 1000*ones(1,length(elecNums));

% Handles varargs
possible_args = {'saveDir','plotTitle','edgeColor','nodeColor','edgeWidth','nodeTextColor','nodeSize'};

for iArg = 1:length(varargin)
    foo_var = inputname(3+iArg);
    fooIdx = find(strcmp(foo_var,possible_args));
    eval([possible_args{fooIdx},'= varargin{iArg};'])
end

% Node location in a circle
nNodes = length(elecNums);
spacing =(2*pi)/(nNodes);
thetas = pi/2 + 0.08:spacing:5/2*pi + 0.08; %The pi/2 + 0.12 just changes the angle at which the first dot is plotted.
thetas = thetas(1:nNodes);

% Convert polar coords to cart for scatter plotting
for iCoord = 1:length(thetas)
    [elecX(iCoord),elecY(iCoord)] = pol2cart(thetas(iCoord),1.2);
end

% Set up figure
figure('Position',[1 1 1100 1000]);
figLims = 1.4;
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
        
        % Figure out the corresponding indices in elecNums
        e1Idx = find(elecNums==e1Node);
        e2Idx = find(elecNums==e2Node);
        
        % Determine the nodes x and y location
        e1X = elecX(e1Idx);
        e2X = elecX(e2Idx);
        e1Y = elecY(e1Idx);
        e2Y = elecY(e2Idx);
        
        % Plot line between points
        line([e1X e2X],[e1Y e2Y],'Color',edgeColor(iEdge,:),'LineWidth',edgeWidth(iEdge))
        
    else
        edges(iEdge,3) = NaN;  %zero out nonsignificant edges -> this will effect degree calculation
    end
    
end

for iNode = 1:nNodes
    
    % Plots nodes
    scatter(elecX(iNode),elecY(iNode),nodeSize(iNode),'MarkerFaceColor',nodeColor(iNode,:),'MarkerEdgeColor',[0 0 0]);
    
    % Plot node labels
    [textX,textY] = pol2cart(thetas(iNode),1.4); %1.3 changes the radius length of where the labels are plotted
    text(textX - 0.12,textY,char(elecLabels(iNode)),'Color',nodeTextColor(iNode,:),'FontSize',24,'FontWeight','bold','Interpreter','none'); %text_x - 0.1 shifts the labels to the left

end

xlim([-figLims figLims])
ylim([-figLims figLims])

title(plotTitle,'FontSize',40);

if ~strcmp(saveDir,'No Save')
    cd(saveDir)
    saveTitle = (plotTitle);
    screen2jpeg(saveTitle)
end

end