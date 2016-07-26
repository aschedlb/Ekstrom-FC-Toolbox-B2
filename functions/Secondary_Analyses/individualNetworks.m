function [edgesAllSubs] = individualNetworks(bootInfo,comparison)

% Individual networks analysis
% Rather than averaging across subjects for the group analyses, this
% function runs the analysis on each subject?s network. Thus one could 
% compute individual network metrics and run performance/behavioral 
% correlations.
% Input: bootInfo from UDIs
%        comparison: 'individual' or 'difference'

global condition resultsDir

for iCond = 1:length(condition)
    
    % Get data
    cd(resultsDir)
    [fileName,pathName,~] = uigetfile('Beta_correlations_*.mat',...
        'Please select which beta series you would like to bootstrap.');
    load([pathName,fileName])
    
    nSubs = size(allRho,1);
    nEdges = size(allRho,2);
    
    % Bootstrap
    correlationMatrix = zeros(nSubs,nEdges,bootInfo.nBoot); %allocation
    
    for iPerm = 1:bootInfo.nBoot
        
        newCorrelations = cellfun(@randomizeSeries,allBetaSeries,'UniformOutput',false);
        correlationMatrix(:,:,iPerm) = cell2mat(newCorrelations');
        
    end
    
    % Fisher's Z transform to compare correlation values
    observedCorrelations = atanh(allRho);
    bootstrapCorrelations = atanh(correlationMatrix);
    
    sortedCorrDistribution = sort(bootstrapCorrelations(:));
    
    % Threshold the networks
    upperIndex = floor((nSubs*nEdges*bootInfo.nBoot)*(1 - bootInfo.alpha(1)));
    
    upperCriticalValue = sortedCorrDistribution(upperIndex);
    edgesAllSubs(:,:,iCond) = observedCorrelations >= upperCriticalValue;
    
end

for iSub = 1:length(subjID)
    
    edges = squeeze(edgesAllSubs(iSub,:,1:2));
    [adj,~,~] = networkComparison(allEdges,plotLabels,comparison);
    
    for iGT = 1:size(adj,3)
        
        nodeDegree(:,iGT,iSub) = degrees_und(adj(:,:,iGT))'; %node degree
        btwnCentrality(:,iGT,iSub) = betweenness_bin(adj(:,:,iGT))'; % betweenness centrality
        density(iGT,iSub) = density_und(adj(:,:,iGT)); %density
        
        for iModule = 1:500
            [modules,Q] = modularity_und(adj(:,:,iGT));
            if Q > maxQ(iGT)
                maxQ(iGT) = Q; % modularity
                finalModules(iGT,:) = modules;
            end
        end
        
        participationCoeff(:,iGT,iSub) = participation_coef(adj(:,:,iGT),finalModules(iGT,:))'; % participation coefficient
        
    end
    
end

% Correlate density with performance
% load(['TrialQuantity_',condition{1},'.mat'])
% [rho,pval] = corr(density(1,:)',nTrials(:,1)./(nTrials(:,1)+nTrials(:,2)));
% [rho,pval] = corr(density(2,:)',nTrials(:,2)./(nTrials(:,1)+nTrials(:,2)));

% Correlate average beta value for a region with node degree for each
% subject for each condition
% for iCond = 1:length(condition)
%
%     for i = 1:nSubs
%        aveBetas = mean(allBetaSeries{i});
%        tempND = squeeze(nodeDegree(:,iCond,i));
%        [rho(i,iCond),pval(i,iCond)] = corr(aveBetas',tempND);
%     end
%
% end

end