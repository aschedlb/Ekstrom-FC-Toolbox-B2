function [analysisType,centerCoords] = betaTimeSeriesAnalysis(ROI1,aalRegions,betaDir)

% Inputs: ROI1: structure from MAT-file from AAL Atlas defining the ROIs
%         aalRegions: ROIs selected by user
%         betaDir: directory where beta values are stored
%
% Output: analysisType: analysis the user chooses (average, CoM, user)
%           average: average betas across entire AAL ROI
%           CoM: average across cube built around center of mass of ROI
%           user: average across cube built around coordinates provided by
%                 user in a CSV-file
%         centerCoords: a N x 3 vector containing the coordinates of the
%                       centers of N ROIs
%         ROIindices: a MAT-file containing a cell array with the indices
%                     of the voxels of the ROI in the order they should be 
%                     used
%         Beta_correlations_analysisType_condition: a MAT-file containing a
%           cell array of subjects with each cell containing a matrix of beta
%           series for each ROI

global expDir subjID condition resultsDir

%% Check Inputs

if nargin ~= 3
    error('Not enough inputs!')
end

if length(aalRegions) == 1
    error('For a successful fucntional connectivity analysis, you need more than one ROI. Try again.')
end

%% Analysis Type and Parameters

% Equate trial numbers in a condition within subject
changeTrialNum = inputdlg('Would you like to balance trial numbers? (1 = yes, 0 = no)'); %correct for trial length differences between conditions
load([expDir,'/TrialQuantity_',condition{1},'.mat']) %Number of trials

% Choose analysis
analysisType = chooseROIanalysis;

% If the ROI are cubes, get cube size.
if ~strcmp(analysisType,'average')
    cubeSize = inputdlg('Enter in cube side length (in voxels)');
    cubeSize = str2double(cubeSize);
end

%% ROIs

% Create mask registered to subject space
register = inputdlg('Enter 1 if you need to register the AAL mask to subject space.','Mask Registration',1,{'0'});
if str2double(register{1}) ~= 0
    registerAAL2beta(betaDir)
    movefile(which('rROI_MNI_V5.nii'),expDir)
end

% Get AAL Data
masks = spm_read_vols(spm_vol(which('rROI_MNI_V5.nii')));
coordinateFile = [resultsDir,'centerCoords_',condition{1},'_',condition{2}];
indiceFile = [expDir,'/ROI_indices'];

% Find ROIs
if strcmp(analysisType,'average')
    
    regionIDs = [ROI1(aalRegions).ID];
    
    for iReg = 1:length(aalRegions)
        ROIindices{iReg} = find(masks == regionIDs(iReg));
    end
    
    % Calculating the coordinates if a node is plotted in 3D brain space
    regionCenters = regionprops(masks,'centroid'); %calculates the center of mass location for each region
    centerCoords = reshape(floor([regionCenters(regionIDs).Centroid]),3,[])'; %coordinates for CoM
    centerCoords = [(centerCoords(:,2)) (centerCoords(:,1)) (centerCoords(:,3))]; %rearranges the columns of the coordinates of the CoMs
    
elseif strcmp(analysisType,'CoM') %Creates a cube at the COM of the region and averages the beta series across the cube
    
    regionIDs = [ROI1(aalRegions).ID];
    
    if exist(coordinateFile,'file')
        load(coordinateFile)
    else
        regionCenters = regionprops(masks,'centroid'); %calculates the center of mass location for each region
        centerCoords = reshape(floor([regionCenters(regionIDs).Centroid]),3,[])'; %coordinates for CoM
        centerCoords = [(centerCoords(:,2)) (centerCoords(:,1)) (centerCoords(:,3))]; %rearranges the columns of the coordinates of the CoMs
    end
    
    if exist([expDir,'/ROI_indices.mat'],'file')
        load([expDir,'/ROI_indices.mat'])
    else
        [ROIindices,centerCoords] = checkCube(regionIDs,masks,centerCoords,cubeSize);
    end
    
elseif strcmp(analysisType,'user')
    
    messageHandle = msgbox('Please select the CSV file containing the coordinates for the centers of the cubes.');
    uiwait(messageHandle)
    [centersFile,centersPath] = uigetfile('*.csv',expDir);
    centerCoords = csvread([centersPath centersFile]);
    
    for iReg = 1:size(centerCoords,1)
        ROIindices{iReg} = createCube(cubeSize,centerCoords(iReg,:),masks);
    end
    
    % Check to ensure cubes do not overlap
    allIndices = [ROIindices{:}];
    repeats = length(centerCoords)*(cubeSize^3) - length(unique(allIndices));
    disp([repeats,' overlapping voxels'])
    
end

save(coordinateFile,'centerCoords')
save(indiceFile,'ROIindices')

%% Beta Series

nSubs = length(subjID);
nRegions = size(centerCoords,1);
nEdges = (nRegions^2 - nRegions)/2;

for iCond = 1:length(condition)
    
    allBetaSeries = cell(1,nSubs);
    allRho = zeros(nSubs,nEdges);
    allPvals = zeros(nSubs,nEdges);
    
    % Get Organized Beta Estimates
    %load([betaDir,'/Beta_Volumes_',condition{iCond},'.mat']); %allBetaVolumes = beta volume(3D) x trial
    [fileName,pathName,~] = uigetfile('Beta_Volumes_*.mat',...
        'Please select which beta series you would like to correlate (i.e., which condition?.');
    load([pathName,fileName])
    
    for iSub = 1:nSubs
        
        betaVolume = allBetaVolumes{iSub};

        for iReg = 1:nRegions
           
             % Ensure that the ROI grabs functional data not a NaN
             if strcmp(analysisType,'CoM') || strcmp(analysisType,'user')
                 functionalData = betaVolume(:,:,:,1);
                 functionalData = functionalData(ROIindices{iReg});
                 functionalVoxels = find(~isnan(functionalData));
                 if isempty(functionalVoxels)
                     warning(['There is no functional data for ',ROI1(aalRegions(iReg)).Nom_L]);
                 elseif length(functionalVoxels) < cubeSize^3
                     ROIindices{iReg} = ROIindices{iReg}(functionalVoxels);
                 else
                    ROIindices{iReg} = ROIindices{iReg}(functionalVoxels(1:cubeSize^3));
                 end
             end
            
            % Within 5D beta volume matrix of all subs and trials 
            [i,j,k] = ind2sub(size(masks),ROIindices{iReg});
            foo = repmat(1:nTrials(iSub,iCond),length(i),1);
            volumeIndex = [repmat([i j k],nTrials(iSub,iCond),1) foo(:)];
            betaVolumeCoords = sub2ind(size(betaVolume),volumeIndex(:,1),volumeIndex(:,2),volumeIndex(:,3),volumeIndex(:,4));
            
            %Average across entire ROI/cube
            betaValues = reshape(betaVolume(betaVolumeCoords),length(i),nTrials(iSub,iCond));
            if sum(isnan(betaValues(:)))
                %warning(['You are missing functional data for ',ROI1(aalRegions(iReg)).Nom_L,': ',num2str(sum(isnan(betaValues(:,1)))),' voxels'])
                warning(['You are missing functional data for ',num2str(sum(isnan(betaValues(:,1)))),' voxels'])
            end
            betaSeries(:,iReg) = nanmean(betaValues,1)';
                      
            if sum(isnan(betaSeries(:,iReg)))
                warning('NaN values in beta series!')
            end
            
        end
        
        %Correlate the time series
        if changeTrialNum{1} == 1
            newNtrials = min(nTrials(iSub,:));
            newTrialIdx = randsample(1:nTrials(iSub,iCond),newNtrials);
            betaSeries = betaSeries(sort(newTrialIdx),:);
        end
        
        allBetaSeries{iSub} = betaSeries;

        [corrVals,pVals] = corr(allBetaSeries{iSub});
        index = combnk(1:nRegions,2);
        index = sub2ind(size(corrVals),index(:,1),index(:,2));
        
        allRho(iSub,:) = corrVals(index);
        allPvals(iSub,:) = pVals(index);
        
        clear betaValues betaSeries
    end

    if changeTrialNum{1} == 1
        save([resultsDir,'Beta_correlations_EqualTrials_',analysisType,'_',condition{iCond}],'subjID','aalRegions','allBetaSeries','allRho','allPvals')
    else
        save([resultsDir,'Beta_correlations_',analysisType,'_',condition{iCond}],'subjID','aalRegions','allBetaSeries','allRho','allPvals')
    end
    
    clear betaSeries
    
end

end

