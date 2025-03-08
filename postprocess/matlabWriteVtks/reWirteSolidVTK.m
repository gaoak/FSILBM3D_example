run getParameters.m
%% File serises
readPath  = [casePath '\DatBodySpan\'];
writePath = [casePath '\DatBodySpan\'];
for n = 1:nfile
    time = LBM.sTime + (n - 1) * LBM.dTime;
    for i = 1:LBM.nSolid
        % Generate reading and writing file paths
        [readName, writeName] = generateSolidPath(readPath,writePath,time,i);
        % Read mesh data
        solid = readAscallSolid(readName,time,LBM.UVW,LBM.Lref,LBM.Tref);
        % Write mesh data in vtks
        writeSolidVTK(solid,writeName)
    end
end
fclose all;