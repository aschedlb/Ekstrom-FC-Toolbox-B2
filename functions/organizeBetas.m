function organizeBetas(betaDir,behavioralInfo)

% Input: betaDir = directory where beta estimates are located (organized by
%                  subject)
%        behavioralInfo = cell array (subject x condtion) of trial numbers
%        belonging to that condition and subject
% Output: MAT-file with all the beta volumes for all trials for all subjects
%         MAT-file containing the number of trials for each subject and condtion

global expDir subjID condition

%% Check Inputs
if nargin ~= 1
    error('Not the correct number of inputs!')
end

warning('Betas need to be consecutively ordered!')

%% Allocations
allBetaVolumes = cell(1,length(subjID));
nTrials = zeros(length(subjID),length(condition));

%% Get Data and Consolidate into One LARGE File
for iCond = 1:length(condition)
    
    fileName = ['Beta_Volumes_',condition{iCond}];
    
    for iSub = 1:length(subjID)
        
        disp(['Subject ',num2str(iSub)])
        
        trialIdentity = behavioralInfo(iSub,iCond);
        
        cd(betaDir)
        allFiles = dir('beta_*');
        
        ctr = 1;
        
        for iFile = trialIdentity
            
            betaVolume(:,:,:,ctr) = spm_read_vols(spm_vol(allFiles(iFile).name)); %SPM functions that read in the matrix of beta values for entire volume
            disp(['File ',num2str(ctr)])
            ctr = ctr + 1;
            
        end
        
        allBetaVolumes{iSub} = betaVolume;
        
        nTrials(iSub,iCond) = length(trialIdentity);
        
    end
    
    % Save a MAT-file that contains a cell array of subjects each with a 4D matrix -> beta volume(3D) x trial
    save([betaDir fileName],'-v7.3','allBetaVolumes');
    
end

% Save a MAT-file that contains a matrix of total trial numbers for each subject x condition
save([expDir,'/TrialQuantity_',condition{1}],'nTrials')

end