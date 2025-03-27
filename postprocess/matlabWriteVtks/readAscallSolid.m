function [solid] = readAscallSolid(filePath,nSolid,time,initialVelocity,Lref,Tref)
if ~isfile(filePath)
    error('Can not found solid mesh files! : %s',filePath);
end
% Read paramters
solid.nodesV = floor(size(importdata(filePath).data,1)/2) + 1; % the node number in the virtual plate
solid.nodesI = floor(solid.nodesV/2) - 1;                      % the node number in the initial plate
% Read data
for i=1:nSolid
    if i==1
        cLine0 = i + 2;
        cLine1 = cLine0 + solid.nodesV - 1;
        eLine0 = cLine1 + 1;
        eLine1 = eLine0 + solid.nodesI - 1;
    else
        cLine0 = cLine1 + solid.nodesI + 2;
        cLine1 = cLine0 + solid.nodesV - 1;
    end
    solid.coor{i} = readmatrix(filePath, 'Range', [cLine0 1 cLine1 3]);
    % Update coordinates
    solid.coor{i}(:,1) = solid.coor{i}(:,1) - initialVelocity(1) / Lref * time * Tref;  % dimensionless  
    solid.coor{i}(:,2) = solid.coor{i}(:,2) - initialVelocity(2) / Lref * time * Tref;
    solid.coor{i}(:,3) = solid.coor{i}(:,3) - initialVelocity(3) / Lref * time * Tref;
    fprintf('Read fish number ready : %d\n', i)
end
solid.elem = readmatrix(filePath, 'Range', [eLine0 1 eLine1 4]);
end
