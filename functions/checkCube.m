function [allROIvoxels,centerCoords] = checkCube(regionIDs,masks,centerCoords,cubeSize)

% Series of checks to ensure the cube contains the correct voxels in the
% proper locations

allROIvoxels = cell(1,length(regionIDs));

%% Check to ensure centers of cubes and the rest of the cube voxels are located within the ROI
cubeCenterIndex = sub2ind(size(masks),centerCoords(:,1),centerCoords(:,2),centerCoords(:,3));
failedCenters = find(~(masks(cubeCenterIndex) == regionIDs'));

%% Find closest voxel to centerCoord within ROI and replace coordinate
if ~isempty(failedCenters)
    for iFail = 1:length(failedCenters)
        [i,j,k] = ind2sub(size(masks),find(masks == regionIDs(failedCenters(iFail))));
        distances = pdist([centerCoords(failedCenters(iFail),:); i j k]);
        [~,nearestVoxel] = min(distances(1:length(i)));
        centerCoords(failedCenters(iFail),:) = [i(nearestVoxel) j(nearestVoxel) k(nearestVoxel)];
    end
end

%% Builds cubes and gets the indices of the voxels

for iRegion = 1:length(regionIDs)
    
    modCubeSize = cubeSize;
    cubeCtr = 1;
    
    cubeIdxs{1} = createCube(cubeSize,centerCoords(iRegion,:),masks);
    ROIvoxels = cubeIdxs{1}(masks(cubeIdxs{1}) == regionIDs(iRegion));
    
    % If for some reason, the cube encompassess voxels not belonging to the
    % ROI, this code iteratively finds  voxels 1 voxel outside the cube 
    % (i.e. in the cube the next size up). I essentially morph the cube to 
    % fit into the space. allROIvoxels is a list (in order) of other voxel
    % coordinates to use.
    
    totalVoxels = numel(find((masks == regionIDs(iRegion))));
    
    while length(ROIvoxels) < totalVoxels
        
        cubeIdxs{cubeCtr+1} = createCube(modCubeSize+1,centerCoords(iRegion,:),masks);
        
        addVoxels = setdiff(cubeIdxs{cubeCtr+1},cubeIdxs{cubeCtr});
        
        % Checks to ensure the cube contains the appropriate voxels
        goodVoxels = addVoxels((masks(addVoxels) == regionIDs(iRegion)));
        ROIvoxels = [ROIvoxels; goodVoxels];
        
        modCubeSize = modCubeSize + 1;
        cubeCtr = cubeCtr + 1;
        
    end
    
    allROIvoxels{iRegion} = ROIvoxels;
    disp(['Region ',num2str(iRegion),' Complete'])
    clear ROIVoxels totalVoxels addVoxels goodVoxels cubeIdxs
    
end

end