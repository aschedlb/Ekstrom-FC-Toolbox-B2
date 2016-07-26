function write2BrainNetViewer(aalRegions,adj,nodeDegree,condTitle)

% This function outputs two files that are formatted for BrainNet Viewer. 
% The user should then enter in the two output files (-.node, -.edge) and
% specifcy the visualization parameters.
% FYI: If one ever tries to plot nodes in the orbital gyrus or cerebellum,
% no nodes will be plotted. This toolbox uses the update AAL parcellation,
% but BrainNet Viewer used the old parcellation scheme.

global resultsDir

% Write node file
[a,b,c,d,e,f] = textread(which('Node_AAL90_modified.node'),'%f %f %f %f %f %s');
remove = [5 6 9 10];

numbers = [a b c d e];
names = f;

numbers(remove,:) = [];
names(remove,:) = [];

newNumbers = [numbers(1:24,:); zeros(8,5); numbers(25:end,:); zeros(26,5)];
newNames = [names(1:24); repmat({'empty'},8,1); names(25:end); repmat({'empty'},26,1)];

newNumbers(:,4:5) = 0;
newNumbers(aalRegions,4) = nodeDegree;
newNumbers = num2cell(newNumbers);

input = [newNumbers newNames];
input = input(aalRegions,:);

fileID = fopen([resultsDir,'/BNVnode_',condTitle,'.node'],'w');
formatSpec = '%f %f %f %f %f %s\n';

for iRow = 1:size(input,1)
    fprintf(fileID,formatSpec,input{iRow,:});
end

fclose(fileID);

% Write edge file
dlmwrite([resultsDir,'/BNVedge_',condTitle,'.edge'],adj,'delimiter',' ')

end