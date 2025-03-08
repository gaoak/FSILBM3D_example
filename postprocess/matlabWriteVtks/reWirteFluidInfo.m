run getParameters.m
%% Begine postprocessing
meanData.u  = 0;
meanData.v  = 0;
meanData.w  = 0;
meanData.uu = 0;
meanData.vv = 0;
meanData.ww = 0;
meanData.uv = 0;
readPath  = [casePath '\DatFlow\'];
writePath = [casePath '\DatFlow\'];
for n = 1:nfile
    time = LBM.sTime + (n - 1) * LBM.dTime;
    [readName, writeName] = generateFluidPath(readPath,writePath,time,1);
    mesh = readBinaryFluid(readName,time,LBM.UVW,LBM.Uref,LBM.Lref,LBM.Tref);
    fprintf('Averaging data : %s\n',readName)
    % Calcualte averaging data
    meanData.u  = meanData.u  + mean(mean(mesh.u,1),3);
    meanData.v  = meanData.v  + mean(mean(mesh.v,1),3);
    meanData.w  = meanData.w  + mean(mean(mesh.w,1),3);
    meanData.uu = meanData.uu + mean(mean(mesh.u.*mesh.u,1),3);
    meanData.vv = meanData.vv + mean(mean(mesh.v.*mesh.v,1),3);
    meanData.ww = meanData.ww + mean(mean(mesh.w.*mesh.w,1),3);
    meanData.uv = meanData.uv + mean(mean(mesh.u.*mesh.v,1),3);
end
meanData.u  = meanData.u  / nfile;
meanData.v  = meanData.v  / nfile;
meanData.w  = meanData.w  / nfile;
meanData.uu = meanData.uu / nfile;
meanData.vv = meanData.vv / nfile;
meanData.ww = meanData.ww / nfile;
meanData.uv = meanData.uv / nfile;
% Judge the first grid height
if (mod(mesh.ny,2)==0)
    mesh.h0 = 0.5 * mesh.dh;
    mesh.firstGrid = 1;
else
    mesh.h0 = 1.0 * mesh.dh;
    mesh.firstGrid = 2;
end
% Calculate y coordinates
y_coor  = zeros(1,mesh.ny);
for i = 1:mesh.ny
    y_coor(i)  = mesh.dh * (i - 1) + mesh.h0;
end
% Calculate averaging turbulent parameters
meanData.tau_w  = LBM.Nu * meanData.u(mesh.firstGrid) * LBM.Uref / mesh.h0;
meanData.u_tau  = sqrt(meanData.tau_w / LBM.denIn) / LBM.Uref;
meanData.Re_tau = meanData.u_tau * LBM.Uref * LBM.Lref / LBM.Nu;
% first order statistic
meanData.y_plus = meanData.u_tau * LBM.Uref * y_coor(:) / LBM.Nu;
meanData.u_plus = meanData.u / meanData.u_tau;
meanData.v_plus = meanData.v / meanData.u_tau;
meanData.w_plus = meanData.w / meanData.u_tau;
% second order statistic
meanData.uu_plus = (meanData.uu / meanData.u_tau / meanData.u_tau - meanData.u_plus .* meanData.u_plus);
meanData.vv_plus = (meanData.vv / meanData.u_tau / meanData.u_tau - meanData.v_plus .* meanData.v_plus);
meanData.ww_plus = (meanData.ww / meanData.u_tau / meanData.u_tau - meanData.w_plus .* meanData.w_plus);
meanData.uv_plus = (meanData.uv / meanData.u_tau / meanData.u_tau - meanData.u_plus .* meanData.v_plus);
%% Write files
fileID = fopen([casePath '\DatInfo\turbulent.plt'], 'w');
fprintf(fileID, 'variables= "y_plus" "u_plus" "v_plus" "w_plus" "uu_plus" "vv_plus" "ww_plus" "uv_plus"\n');
for j = 1:length(meanData.y_plus)
    fprintf(fileID, [repmat('%.8g ', 1, 8), '\n'], meanData.y_plus(j), meanData.u_plus(j), meanData.v_plus(j), meanData.w_plus(j)...
                  ,  meanData.uu_plus(j), meanData.vv_plus(j), meanData.ww_plus(j), meanData.uv_plus(j));
end
fclose(fileID);
