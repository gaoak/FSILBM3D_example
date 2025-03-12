run getParameters.m
%% File serises
meanData.uu_plus = 0;
meanData.vv_plus = 0;
meanData.ww_plus = 0;
meanData.uv_plus = 0;
readPath  = [casePath '\DatFlow\'];
writePath = [casePath '\DatFlow\'];
for n = 1:nfile
    time = LBM.sTime + (n - 1) * LBM.dTime;
    for i = LBM.nBlock:-1:1
        sonBlocks = length(LBM.meshContain{i});
        % Read father mesh data
        [readNameFather, writeNameFather] = generateFilePath(readPath,writePath,time,i,0);
        meshFather = readBinaryFluid(readNameFather,time,LBM.UVW,LBM.Uref,LBM.Lref,LBM.Tref);  
        % Read son mesh data
        for j = 1:sonBlocks
            [readNameSon, writeNameSon] = generateFilePath(readPath,writePath,time,LBM.meshContain{i}(j),0);
            meshSon = readBinaryFluid(readNameSon,0.0,LBM.UVW,LBM.Uref,LBM.Lref,LBM.Tref); 
            % Update mesh data in coarse mesh
            meshFather = finerToCoarse(meshSon,meshFather);
            fprintf('deliver data from block %d to block %d\n',LBM.meshContain{i}(j),i)
        end
    end
    fprintf('Averaging data : %s\n',readNameFather)
    % Calcualte averaging data
    turbulent.u  = mean(mean(meshFather.u,1),3) * LBM.Uref;
    turbulent.v  = mean(mean(meshFather.v,1),3) * LBM.Uref;
    turbulent.w  = mean(mean(meshFather.w,1),3) * LBM.Uref;
    turbulent.uu = mean(mean(meshFather.u.*meshFather.u,1),3) * LBM.Uref * LBM.Uref;
    turbulent.vv = mean(mean(meshFather.v.*meshFather.v,1),3) * LBM.Uref * LBM.Uref;
    turbulent.ww = mean(mean(meshFather.w.*meshFather.w,1),3) * LBM.Uref * LBM.Uref;
    turbulent.uv = mean(mean(meshFather.u.*meshFather.v,1),3) * LBM.Uref * LBM.Uref;
    % Judge the first grid height
    if (mod(meshFather.ny,2)==0)
        h0 = 0.5 * meshFather.dh * LBM.Lref;
        firstGrid = 1;
    else
        h0 = 1.0 * meshFather.dh * LBM.Lref;
        firstGrid = 2;
    end
    % Calculate y coordinates
    y_coor  = zeros(1,meshFather.ny);
    for i = 1:meshFather.ny
        y_coor(i)  = meshFather.dh * LBM.Lref * (i - 1) + h0;
    end
    % Calculate averaging turbulent parameters
    turbulent.tau_w  = LBM.Mu * turbulent.u(firstGrid) / h0;
    turbulent.u_tau  = sqrt(turbulent.tau_w / LBM.denIn);
    turbulent.Re_tau = turbulent.u_tau * LBM.Lref * LBM.denIn / LBM.Mu;
    turbulent.y_plus = turbulent.u_tau * y_coor(1,:) * LBM.denIn / LBM.Mu;  % y*u_τ/ν
    % first order statistic
    turbulent.u_plus = turbulent.u / turbulent.u_tau;
    turbulent.v_plus = turbulent.v / turbulent.u_tau;
    turbulent.w_plus = turbulent.w / turbulent.u_tau;
    % second order statistic
    turbulent.uu_plus = (turbulent.uu / turbulent.u_tau / turbulent.u_tau - turbulent.u_plus .* turbulent.u_plus);
    turbulent.vv_plus = (turbulent.vv / turbulent.u_tau / turbulent.u_tau - turbulent.v_plus .* turbulent.v_plus);
    turbulent.ww_plus = (turbulent.ww / turbulent.u_tau / turbulent.u_tau - turbulent.w_plus .* turbulent.w_plus);
    turbulent.uv_plus = (turbulent.uv / turbulent.u_tau / turbulent.u_tau - turbulent.u_plus .* turbulent.v_plus);
    % sum
    meanData.uu_plus = meanData.uu_plus + turbulent.uu_plus;
    meanData.vv_plus = meanData.vv_plus + turbulent.vv_plus;
    meanData.ww_plus = meanData.ww_plus + turbulent.ww_plus;
    meanData.uv_plus = meanData.uv_plus + turbulent.uv_plus;
    disp(turbulent.Re_tau)
end
%% Write files
fileID = fopen([casePath '\DatInfo\turbulentSecond.plt'], 'w');
fprintf(fileID, 'variables= "y_plus" "uu_plus" "vv_plus" "ww_plus" "uv_plus"\n');
for j = 1:length(turbulent.y_plus)
    fprintf(fileID, [repmat('%.8g ', 1, 5), '\n'], turbulent.y_plus(j),meanData.uu_plus(j)/nfile, ...
        meanData.vv_plus(j)/nfile, meanData.ww_plus(j)/nfile, meanData.uv_plus(j)/nfile);
end
fclose(fileID);