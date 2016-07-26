function visualizeGTmetrics(adj,plotLabels,sortPlotNodes,titles)

% This function computes various graph theory metrics on the networks of
% interest and output those computations in graph and file form.
% Graph Theory Measures: node degree, betweenness centrality, density,
% modularity, participation coefficient
% Output: Bar plots of metrics and MAT-file with saved computed metrics

if nargin ~= 4
    error('Not the correct amount of inputs!')
end

[localMetrics,globalMetrics,modifyMetrics] = chooseGTmetrics;
nNodes = length(plotLabels);

% Allocations
maxQ = zeros(1,size(adj,3));

%% Calculation

if sum(sum(adj(:,:,1))) == 0 || sum(sum(adj(:,:,2))) == 0
    error('There are no edges in the networks. Please adjust your threshold.')
end

for iGT = 1:size(adj,3)
    
    nodeDegree(:,iGT) = degrees_und(adj(:,:,iGT)); %node degree
    btwnCentrality(:,iGT) = betweenness_bin(adj(:,:,iGT)); %betweenness centrality
    density(iGT) = density_und(adj(:,:,iGT)); %density
    
    for iModule = 1:500 %Runs the algorithm 500x to find max Newman's Q
        [modules,Q] = modularity_und(adj(:,:,iGT));
        if Q > maxQ(iGT)
            maxQ(iGT) = Q; %modularity as assessed by Newman's Q
            finalModules(iGT,:) = modules;
        end
    end
    
    participationCoeff(:,iGT) = participation_coef(adj(:,:,iGT),finalModules(iGT,:)); %participation coefficient
    
end

%% Modify metrics
if strcmp(modifyMetrics,'normalize')
    nodeDegree = nodeDegree/(nNodes - 1);
    btwnCentrality = btwnCentrality/((nNodes-1)*(nNodes-2));
elseif strcmp(modifyMetrics,'zscore')
    nodeDegree = zscore(nodeDegree);
    btwnCentrality = zscore(btwnCentrality);
end

%% Bar graph of node degree, betwn centrality, participation coeffcient
nMetrics = length(localMetrics);

if nMetrics
    
    %Sorted metrics for plotting
    nodeDegree = nodeDegree(sortPlotNodes,:);
    btwnCentrality = btwnCentrality(sortPlotNodes,:);
    participationCoeff = participationCoeff(sortPlotNodes,:);
        
    % Organize values needed to plot
    for iValues = 1:nMetrics
        
        if ismember('ND',localMetrics)
            barValues{iValues} = nodeDegree(:,1:2);
            allMetricTitles{iValues} = {'Node Degree'};
        elseif ismember('BC',localMetrics)
            barValues{iValues} = btwnCentrality(:,1:2);
            allMetricTitles{iValues} = {'Btwn Centrality'};
        elseif ismember('PC',localMetrics)
            barValues{iValues} = participationCoeff(:,1:2);
            allMetricTitles{iValues} = {'Participation Coeff'};
        end
        
        localMetrics{iValues} = '';
        localMetrics = squeeze(localMetrics);
        
    end
    
    % Size of figure
    figure('Position',[1 1 600*length(localMetrics) 900])
    
    for iBar = 1:length(localMetrics)
        
        subplot(1,length(localMetrics),iBar)
        bHandle = barh(barValues{iBar});
        bHandle(1).FaceColor = [44/255 130/255 143/255];
        bHandle(2).FaceColor = [110/255 91/255 140/255];
        set(gca,'YLim',[0 nNodes+1],'YTick',1:nNodes,'YTickLabel',plotLabels(sortPlotNodes))
        barTitle = [titles{1},' ',allMetricTitles{iBar}];
        title(barTitle)
        legend(titles{1},titles{2})
        
    end
    
    screen2jpeg(['Graph Metrics ',titles{1}])
    
end

%% Display density
if sum(strcmp('DEN',globalMetrics))
    msgbox(num2str(density))
end

%% Display modularity
if sum(strcmp('MOD',globalMetrics))
    
    figure('Position',[1 1 2000 900])
    colormap([1 1 1;0.5 0.5 0.5;0 0 0]);
    
    for iMod = 1:size(adj,3)
        
        [X,Y,indSort] = grid_communities(finalModules(iMod,:));
        subplot(1,size(adj,3),iMod)
        imagesc(adj(indSort,indSort,iMod));
        axis image
        set(gca,'XTickLabel',plotLabels(indSort),'XTick',1:nNodes,'YTickLabel',plotLabels(indSort),'YTick',1:nNodes,'XTickLabelRotation',300)
        grid on
        set(gca,'GridLineStyle','-')
        set(gca,'XTick',1.5:nNodes+0.5,'YTick',1.5:nNodes+0.5)
        hold on;
        plot(X,Y,'r','linewidth',4)
        title(titles{iMod})
        xlabel(num2str(maxQ(iMod)),'FontSize',24)
        
    end
    
    screen2jpeg(['Modularity ',titles{1}])
    
end

%% Save metrics to a MAT-File
save(['GTmetrics ',titles{1}],'nodeDegree','btwnCentrality','participationCoeff','density','maxQ')

end