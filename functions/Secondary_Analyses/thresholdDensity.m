function thresholdDensity(densityVal)

% This function provides another way to determine significance with 
% networks by thresholding the number of connections based on density while
% taking the rho value of each connection into account.
% Input: densityVal = the density of the network
%           Ex: densityVal = 0.5 -> 50% connected network
% Output: MAT-file containing the thresholded edges

global condition resultsDir

for iCond = 1:length(condition)
    
    % Get data
    cd(resultsDir)
    [fileName,pathName,~] = uigetfile('Beta_correlations_*.mat',...
        'Please select which beta series you would like to threshold.');
    load([pathName,fileName])
    
    nEdges = size(allRho,2);
    
    edges = nanmean(allRho);
    [sortEdges,~] = sort(edges);
    thresholdValue = sortEdges(round(densityVal*nEdges));
    edges(edges < thresholdValue) = 0;
    edges = edges';
    
    bonferonniPvals = allPvals < 0.05/(nSubs*nEdges);
    thresholdRhos = allRho > thresholdValue;
    individualEdges = bonferonniPvals.*thresholdRhos;
    
    save([resultsDir,'Threshold_Density_',fileName(19:end)],...
        'subjID','aalRegions','edges','individualEdges','thresholdValue')
    
end

end