function thresholdRhoSeriesCorrelations(thresholdValue)

% This function provides another way to determine significance with 
% networks by thresholding the number of connections based on the rho value
% or edge weights.
% Input: thresholdVal = the rho value to threshold the network
%           Ex: thresholdVal = 0.3 -> all edges > 0.3 will be included in
%           the network.
% Output: MAT-file containing the thresholded edges

global condition resultsDir

for iCond = 1:length(condition)
    
    % Get data
    cd(resultsDir)
    [fileName,pathName,~] = uigetfile('Beta_correlations_*.mat',...
        'Please select which beta series you would like to threshold.');
    load([pathName,fileName])
    
    nSubs = size(allRho,1);
    nEdges = size(allRho,2);
    
    edges = nanmean(allRho);
    edges(edges < thresholdValue) = 0;
    
    bonferonniPvals = allPvals < 0.05/(nSubs*nEdges);
    thresholdRhos = allRho > thresholdValue;
    individualEdges = bonferonniPvals.*thresholdRhos;
    
    save([resultsDir,'Threshold_Rho_',fileName(19:end)],...
        'subjID','aalRegions','edges','individualEdges','thresholdValue')
    
end

end