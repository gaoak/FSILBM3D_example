function [solid] = readAscallSolid(filePath,nSolid,time,initialVelocity,Lref,Tref)
fileID = fopen(filePath,'r');
if fileID == -1
    error('Cant found file : %s',filePath);
end
title = fgetl(fileID);  % variable titles
zones = fgetl(fileID);  % read the first zone information
string= strsplit(strtrim(zones));
% Read paramters
solid.nodesV = str2double(strrep(string{7 },',','')); % the node number in the virtual plate
solid.nodesI = str2double(strrep(string{10},',','')); % the node number in the initial plate
% Read data
for i=1:nSolid
    if i==1
        cLine0 = i + 2;
        cLine1 = cLine0 + solid.nodesV - 1;
    else
        cLine0 = cLine1 + solid.nodesI + 2;
        cLine1 = cLine0 + solid.nodesV - 1;
    end
    eLine0 = cLine1 + 1;
    eLine1 = eLine0 + solid.nodesI - 1;
    solid.coor{i} = readmatrix(filePath, 'Range', [cLine0 1 cLine1 3]);
    solid.elem{i} = readmatrix(filePath, 'Range', [eLine0 1 eLine1 4]);
    % Update coordinates
    solid.coor{i}(:,1) = solid.coor{i}(:,1) - initialVelocity(1) / Lref * time * Tref;  % dimensionless  
    solid.coor{i}(:,2) = solid.coor{i}(:,2) - initialVelocity(2) / Lref * time * Tref;
    solid.coor{i}(:,3) = solid.coor{i}(:,3) - initialVelocity(3) / Lref * time * Tref;
    fprintf('Read fish number ready : %d\n', i)
end
end
