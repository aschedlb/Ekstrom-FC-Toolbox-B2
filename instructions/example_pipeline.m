%% Example Pipeline

% NOTE: Please ensure there is only one version of SPM and the AAL Toolbox 
% on your computer!

clc
clear
close all

%% User Defined Inputs

% Global variables
global expDir subjID condition resultsDir

% Experiment directory
expDir = '/someName/Matlab/';

% Patient IDs, same as name of patient folder
subjID = {'Subject1','Subject2','Subject3','Subject4','Subject5',...
    'Subject6','Subject7','Subject8','Subject9','Subject10'};

% Conditions of the experiment: compare only two at a time!
condition = {'condition1';'condition2'};

% Behavioral information
% behavioralInfo = cell array;
% Please create a cell array (number of subjects x condition) called
% behavioralInfo. Each cell should contain the trial numbers for the
% condition of interest for that subject. The trial numbers should
% correspond to the beta images; this information is used to find all the
% beta values for a particular condition to make a beta series.

% Bootstrapping parameters
bootInfo = struct('nBoot',1000,'alpha',[0.001 0.01 0.05 0.10]);

% Save results
resultsDir = [expDir,'/Results/',savedate];
if ~exist(resultsDir,'dir')
    mkdir(resultsDir)
end

%% Organize Beta Estimates

% Directory containing beta estimates
% NOTE: If the title is not on dialog box -> MATLAB Tech. Support Case
% #01573596
betaDir = uigetdir(pwd,'Please select the directory where the beta estimates are located.');

% Function to organize all subject betas -> Needs to be modified to grab 
% the beta image files
organizeBetas(betaDir,behavioralInfo)

%% Beta Time Series Analysis

% Please choose the regions of interest for the beta time series analysis
load('ROI_MNI_V5_vol.mat')
[aalRegions,successSelect] = listdlg('PromptString','Select ROIs',...
    'SelectionMode','multiple','ListString',{ROI1.Nom_L});

% Beta Time Series
[analysisType,centerCoords] = betaTimeSeriesAnalysis(ROI1,aalRegions,betaDir);

%% Statistical Anlaysis
edgesAll = bootstrapSeriesCorrelations(bootInfo);

%% Graph Results

%%% Networks %%%

% Threshold of the networks
alphaIndex = [1 1]; %Threshold index (from bootInfo) for each condition

% Labels given by the AAL toolbox
plotLabels = {ROI1(aalRegions).Nom_L};
%plotLabels = {ROI1(aalRegions).Nom_C}; %If these abbreviations are not useful, please use the next two lines of code instead.
%%%%[~,~,raw]  = xlsread('newAALlabels.xlsx'); %Shortened version of labels
%%%%plotLabels = raw(aalRegions);

% User can rearrange the order of the ROIs plotted on the circlular plots
% and in the bar graphs of metrics
sortPlotNodes = 1:length(aalRegions);

% Visualize networks in
% a) circular form
% b) 3D brain space
% c) Gephi: CSV-File edge and node table are output rather than a MATLAB figure
% d) BrainNet Viewer: .node and .edge files output rather than a MATLAB figure
[adj,allTitles,comparison] = visualizeNetworks(aalRegions,centerCoords,alphaIndex,plotLabels,sortPlotNodes);

%%% Graph Theory Metrics %%%
visualizeGTmetrics(adj,plotLabels,sortPlotNodes,titles)