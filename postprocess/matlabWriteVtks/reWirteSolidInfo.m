run getParameters.m
% Read begin point data
for i = 1:LBM.nSolid
    fileStruct    = importdata([casePath '\DatInfo\FishNodeBegin_00' num2str(i) '.plt']);
    fileData      = fileStruct.data;
    % Update velocity
    fileData(:,5) = fileData(:,5)  - LBM.UVW(1) / LBM.Uref;
    fileData(:,6) = fileData(:,6)  - LBM.UVW(2) / LBM.Uref;
    fileData(:,7) = fileData(:,7)  - LBM.UVW(3) / LBM.Uref;
    % Write data
    fileID = fopen([casePath '\DatInfo\FishNodeBegin_00' num2str(i) '_n.plt'], 'w');
    fprintf(fileID, '%s\n',fileStruct.textdata{1});
    for j = 1:size(fileData,1)
        time = fileData(j,1);
        fileData(j,2) = fileData(j,2)  - LBM.UVW(1) / LBM.Lref * time * LBM.Tref;
        fileData(j,3) = fileData(j,3)  - LBM.UVW(2) / LBM.Lref * time * LBM.Tref;
        fileData(j,4) = fileData(j,4)  - LBM.UVW(3) / LBM.Lref * time * LBM.Tref;
        fprintf(fileID, [repmat('%.8g ', 1, size(fileData,2)), '\n'], fileData(j,:));
    end
    fprintf('Writing file read : %s\n', [casePath '\DatInfo\FishNodeBegin_00' num2str(i) '_n.plt'])
end
% Read center point data
for i = 1:LBM.nSolid
    fileStruct    = importdata([casePath '\DatInfo\FishNodeCenter_00' num2str(i) '.plt']);
    fileData      = fileStruct.data;
    % Update velocity
    fileData(:,5) = fileData(:,5)  - LBM.UVW(1) / LBM.Uref;
    fileData(:,6) = fileData(:,6)  - LBM.UVW(2) / LBM.Uref;
    fileData(:,7) = fileData(:,7)  - LBM.UVW(3) / LBM.Uref;
    % Write data
    fileID = fopen([casePath '\DatInfo\FishNodeCenter_00' num2str(i) '_n.plt'], 'w');
    fprintf(fileID, '%s\n',fileStruct.textdata{1});
    for j = 1:size(fileData,1)
        time = fileData(j,1);
        fileData(j,2) = fileData(j,2)  - LBM.UVW(1) / LBM.Lref * time * LBM.Tref;
        fileData(j,3) = fileData(j,3)  - LBM.UVW(2) / LBM.Lref * time * LBM.Tref;
        fileData(j,4) = fileData(j,4)  - LBM.UVW(3) / LBM.Lref * time * LBM.Tref;
        fprintf(fileID, [repmat('%.8g ', 1, size(fileData,2)), '\n'], fileData(j,:));
    end
    fprintf('Writing file read : %s\n', [casePath '\DatInfo\FishNodeCenter_00' num2str(i) '_n.plt'])
end
% Read end point data
for i = 1:LBM.nSolid
    fileStruct    = importdata([casePath '\DatInfo\FishNodeEnd_00' num2str(i) '.plt']);
    fileData      = fileStruct.data;
    % Update velocity
    fileData(:,5) = fileData(:,5)  - LBM.UVW(1) / LBM.Uref;
    fileData(:,6) = fileData(:,6)  - LBM.UVW(2) / LBM.Uref;
    fileData(:,7) = fileData(:,7)  - LBM.UVW(3) / LBM.Uref;
    % Write data
    fileID = fopen([casePath '\DatInfo\FishNodeEnd_00' num2str(i) '_n.plt'], 'w');
    fprintf(fileID, '%s\n',fileStruct.textdata{1});
    for j = 1:size(fileData,1)
        time = fileData(j,1);
        fileData(j,2) = fileData(j,2)  - LBM.UVW(1) / LBM.Lref * time * LBM.Tref;
        fileData(j,3) = fileData(j,3)  - LBM.UVW(2) / LBM.Lref * time * LBM.Tref;
        fileData(j,4) = fileData(j,4)  - LBM.UVW(3) / LBM.Lref * time * LBM.Tref;
        fprintf(fileID, [repmat('%.8g ', 1, size(fileData,2)), '\n'], fileData(j,:));
    end
    fprintf('Writing file read : %s\n', [casePath '\DatInfo\FishNodeEnd_00' num2str(i) '_n.plt'])
end
% Read averaging data
for i = 1:LBM.nSolid
    fileStruct    = importdata([casePath '\DatInfo\FishNodeMean_00' num2str(i) '.plt']);
    fileData      = fileStruct.data;
    % Update velocity
    fileData(:,5) = fileData(:,5)  - LBM.UVW(1) / LBM.Uref;
    fileData(:,6) = fileData(:,6)  - LBM.UVW(2) / LBM.Uref;
    fileData(:,7) = fileData(:,7)  - LBM.UVW(3) / LBM.Uref;
    % Write data
    fileID = fopen([casePath '\DatInfo\FishNodeMean_00' num2str(i) '_n.plt'], 'w');
    fprintf(fileID, '%s\n',fileStruct.textdata{1});
    for j = 1:size(fileData,1)
        time = fileData(j,1);
        fileData(j,2) = fileData(j,2)  - LBM.UVW(1) / LBM.Lref * time * LBM.Tref;
        fileData(j,3) = fileData(j,3)  - LBM.UVW(2) / LBM.Lref * time * LBM.Tref;
        fileData(j,4) = fileData(j,4)  - LBM.UVW(3) / LBM.Lref * time * LBM.Tref;
        fprintf(fileID, [repmat('%.8g ', 1, size(fileData,2)), '\n'], fileData(j,:));
    end
    fprintf('Writing file read : %s\n', [casePath '\DatInfo\FishNodeMean_00' num2str(i) '_n.plt'])
end
fclose all;