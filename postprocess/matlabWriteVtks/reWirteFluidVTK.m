run getParameters.m
%% File serises
readPath  = [casePath '\DatFlow\'];
writePath = [casePath '\DatFlow\'];
for n = 1:nfile
    time = LBM.sTime + (n - 1) * LBM.dTime;
    for i = LBM.nBlock:-1:1
        sonBlocks = length(LBM.meshContain{i});
        % Read father mesh data
        [readNameFather, writeNameFather] = generateFluidPath(readPath,writePath,time,i);
        meshFather = readBinaryFluid(readNameFather,time,LBM.UVW,LBM.Uref,LBM.Lref,LBM.Tref);  
        % Read son mesh data
        for j = 1:sonBlocks
            [readNameSon, writeNameSon] = generateFluidPath(readPath,writePath,time,LBM.meshContain{i}(j));
            meshSon = readBinaryFluid(readNameSon,time,LBM.UVW,LBM.Uref,LBM.Lref,LBM.Tref); 
            % Update mesh data in coarse mesh
            meshFather = finerToCoarse(meshSon,meshFather);
            fprintf('deliver data from block %d to block %d\n',LBM.meshContain{i}(j),i)
        end
        % Write mesh data in vtks
        if ~isOnlyWriteRootBlock 
            writeFluidVTK(meshFather,writeNameFather)
        end
    end
    if isOnlyWriteRootBlock 
        writeFluidVTK(meshFather,writeNameFather)
    end
end
% write whole block contains the calculation domain at all times
writeWholeVTK(meshFather,time,LBM.UVW,LBM.Lref,LBM.Tref,writePath)
