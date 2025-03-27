run getParameters.m
readPath  = [casePath '\DatFlow\'];
writePath = [casePath '\DatFlow\'];
%% Write average fluid vtk
for i = LBM.nBlock:-1:1
    sonBlocks = length(LBM.meshContain{i});
    % Read father mesh data
    [readNameFather, writeNameFather] = generateFilePath(readPath,writePath,0.0,i,1);
    meshFather = readBinaryFluid(readNameFather,0.0,[0 0 0],LBM.Uref,LBM.Lref,LBM.Tref);  
    % Read son mesh data
    for j = 1:sonBlocks
        [readNameSon, writeNameSon] = generateFilePath(readPath,writePath,0.0,LBM.meshContain{i}(j),1);
        meshSon = readBinaryFluid(readNameSon,0.0,[0 0 0],LBM.Uref,LBM.Lref,LBM.Tref); 
        % Update mesh data in coarse mesh
        meshFather = finerToCoarse(meshSon,meshFather);
        fprintf('deliver data from block %d to block %d\n',LBM.meshContain{i}(j),i)
    end
end
% Write mesh data in vtks
if LBM.nBlock>1
    writeFluidVTK(meshFather,writeNameFather)
end
% Calculate space averaging data
meanData.u  = mean(mean(meshFather.u, 1),3) * LBM.Uref;
meanData.v  = mean(mean(meshFather.v, 1),3) * LBM.Uref;
meanData.w  = mean(mean(meshFather.w, 1),3) * LBM.Uref;
meanData.uu = mean(mean(meshFather.uu,1),3) * LBM.Uref * LBM.Uref;
meanData.vv = mean(mean(meshFather.vv,1),3) * LBM.Uref * LBM.Uref;
meanData.ww = mean(mean(meshFather.ww,1),3) * LBM.Uref * LBM.Uref;
meanData.uv = mean(mean(meshFather.uv,1),3) * LBM.Uref * LBM.Uref;
meanData.uw = mean(mean(meshFather.uw,1),3) * LBM.Uref * LBM.Uref;
meanData.vw = mean(mean(meshFather.vw,1),3) * LBM.Uref * LBM.Uref;
% Judge the first grid height
y_coor  = zeros(1,meshFather.ny);
if isHalfWayBounceBack
    h0 = 0.5 * meshFather.dh * LBM.Lref;
    firstGrid = 1;
    for i = 1:meshFather.ny
        y_coor(i)  = meshFather.dh * LBM.Lref * (i - 1) + h0;
    end
else
    h0 = 1.0 * meshFather.dh * LBM.Lref;
    firstGrid = 2;
    for i = 1:meshFather.ny
        y_coor(i)  = meshFather.dh * LBM.Lref * (i - 1);
    end
end
% Calculate averaging turbulent parameters
turbulent.tau_w   = LBM.Mu * meanData.u(firstGrid) / h0;                 % μ*u_0/y_0
turbulent.u_tau   = sqrt(turbulent.tau_w / LBM.denIn);                   % sqrt(τ_w/ρ)
turbulent.y_plus  = turbulent.u_tau * y_coor(1,:) * LBM.denIn / LBM.Mu;  % y*u_τ/ν
turbulent.Re_tau  = turbulent.u_tau * LBM.Lref * LBM.denIn / LBM.Mu;
fprintf('Calculate Re_tau: %s\n',turbulent.Re_tau)
% Calculate first order statistic
turbulent.u_plus  = meanData.u  / turbulent.u_tau;
turbulent.v_plus  = meanData.v  / turbulent.u_tau;
turbulent.w_plus  = meanData.w  / turbulent.u_tau;
% Calculate second order statistic
turbulent.uu_plus = meanData.uu / turbulent.u_tau / turbulent.u_tau;
turbulent.vv_plus = meanData.vv / turbulent.u_tau / turbulent.u_tau;
turbulent.ww_plus = meanData.ww / turbulent.u_tau / turbulent.u_tau;
turbulent.uv_plus = meanData.uv / turbulent.u_tau / turbulent.u_tau;
turbulent.uw_plus = meanData.uw / turbulent.u_tau / turbulent.u_tau;
turbulent.vw_plus = meanData.vw / turbulent.u_tau / turbulent.u_tau;
%% Write files
linear_law = turbulent.y_plus;
log_law    = 2.5 * log(turbulent.y_plus) + 5.5;
fileID = fopen([casePath '\DatInfo\turStatistics.plt'], 'w');
fprintf(fileID, 'variables= "y_plus" "u_plus" "v_plus" "w_plus" "uu_plus" "vv_plus" "ww_plus" "uv_plus" "uw_plus" "vw_plus" "linear_law" "log_law"\n');
for j = 1:length(turbulent.y_plus)
    fprintf(fileID, [repmat('%.8g ', 1, 12), '\n'], turbulent.y_plus(j),  turbulent.u_plus(j),  turbulent.v_plus(j),  turbulent.w_plus(j) , ...
                                                    turbulent.uu_plus(j), turbulent.vv_plus(j), turbulent.ww_plus(j), turbulent.uv_plus(j), ...
                                                    turbulent.uw_plus(j), turbulent.vw_plus(j), linear_law(j), log_law(j));
end
fclose all;
