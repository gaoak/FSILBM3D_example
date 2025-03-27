run getParameters.m
%% File serises
readPath  = [casePath '\DatBodySpan\'];
writePath = [casePath '\DatBodySpan\'];
for n = 1:nfile
    time = LBM.sTime + (n - 1) * LBM.dTime;
    % Generate reading and writing file paths
    [readName, writeName] = generateFilePath(readPath,writePath,time,0,2);
    % Read mesh data
    solid = readAscallSolid(readName,LBM.nSolid,time,LBM.UVW,LBM.Lref,LBM.Tref);
    % Write mesh data in vtks
    writeSolidPLT(solid,writeName,LBM.nSolid)
end
fclose all;