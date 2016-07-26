function [edgesAll] = bootstrapSeriesCorrelations(bootInfo)

% Bootstrapping is a statistical procedure that checks to see if the
% correlations are significantly greater than chance.

% Input: bootInfo: structure containing the parameters for the 
%           bootstrapping procedure, fields -> nboot, alpha
% Output: Bootstrap_analysisType_condition: MAT-file containing the
%           subjects included in the group analysis, the ROI labels, and
%           the significant edges/connections between two nodes (edgesAll).
%           edgesAll contains a column for each threshold of the
%           distribution that is specificed in bootInfo.

global condition resultsDir

if nargin ~= 1
    error('Not the correct amount of inputs!')
end

% Computation
for iCond = 1:length(condition)

    % Get data
    cd(resultsDir)
    [fileName,pathName,~] = uigetfile('Beta_correlations_*.mat',...
        'Please select which beta series you would like to bootstrap.');
    load([pathName,fileName])
    
    nSubs = size(allRho,1);
    nEdges = size(allRho,2);
    
    % Allocation
    edgesAll = zeros(nEdges,length(bootInfo.alpha));

    % Bootstrap
    correlationMatrix = zeros(nSubs,nEdges,bootInfo.nBoot); %allocation
     
    for iPerm = 1:bootInfo.nBoot
        
        newCorrelations = cellfun(@randomizeSeries,allBetaSeries,...
            'UniformOutput',false);
        correlationMatrix(:,:,iPerm) = cell2mat(newCorrelations');
               
    end
    
    % Fisher's Z transform to compare correlation values
    % Maybe average across the bootstrap correlations to ensure those
    % values undergo a similar process
    observedCorrelations = mean(atanh(allRho),1);
    bootstrapCorrelations = atanh(correlationMatrix);

    sortedCorrDistribution = sort(bootstrapCorrelations(:));

    % Threshold the networks at different alpha values
    for iAlpha = 1:length(bootInfo.alpha)
        
        upperIndex = floor((nSubs*nEdges*bootInfo.nBoot)*(1 - bootInfo.alpha(iAlpha)));
        
        upperCriticalValue = sortedCorrDistribution(upperIndex);
        edgesAll(:,iAlpha) = observedCorrelations >= upperCriticalValue;
        
    end    
    
    save([resultsDir,'Bootstrap_',fileName(19:end)],...
        'subjID','aalRegions','edgesAll')
    
end

end