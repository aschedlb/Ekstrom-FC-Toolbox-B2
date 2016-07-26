function [cubeIndex] = createCube(cubeSize,centerCoord,masks)

% Finds the index of the cube voxels for each region with the cube centered at the appropriate coordinates

%cubeIndex = zeros(cubeSize^3,1);
ctr = 1;

% If a cube is an odd or even number of voxels
if mod(cubeSize,2) ~= 0
    cubeSide1 = floor(cubeSize/2);
    cubeSide2 = cubeSide1;
else
    cubeSide1 = cubeSize/2 - 1;
    cubeSide2 = cubeSize/2;
end

% Checks boundaries to ensure don't go outside mask
startsEnds = [(centerCoord(1)-cubeSide1) (centerCoord(1)+cubeSide2); (centerCoord(2)-cubeSide1) (centerCoord(2)+cubeSide2); (centerCoord(3)-cubeSide1) (centerCoord(3)+cubeSide2)];
foo = startsEnds(:,1);
startsEnds(foo <= 0) = 1;
foo = startsEnds(:,2);
boundaries = size(masks)';
startsEnds(foo > boundaries,2) = boundaries(foo > boundaries);  
    
for iZ = startsEnds(3,1):startsEnds(3,2)
    for iY = startsEnds(2,1):startsEnds(2,2)
        for iX = startsEnds(1,1):startsEnds(1,2)
            
            cubeIndex(ctr,1) = sub2ind(size(masks),iX,iY,iZ);
            ctr = ctr + 1;
            
        end
    end
end

clear iX iY iZ

end