run getParameters.m
readPath  = [casePath '\DatFlow\'];
writePath = [casePath '\DatFlow\'];
%% Write average fluid vtk
for i = LBM.nBlock:-1:1
    sonBlocks = length(LBM.meshContain{i});
    % Read father mesh data
    [readNameFather, writeNameFather] = generateFilePath(readPath,writePath,0.0,i,1);
    meshFather = readBinaryFluid(readNameFather,0.0,LBM.UVW,LBM.Uref,LBM.Lref,LBM.Tref);  
    % Read son mesh data
    for j = 1:sonBlocks
        [readNameSon, writeNameSon] = generateFilePath(readPath,writePath,0.0,LBM.meshContain{i}(j),1);
        meshSon = readBinaryFluid(readNameSon,0.0,LBM.UVW,LBM.Uref,LBM.Lref,LBM.Tref); 
        % Update mesh data in coarse mesh
        meshFather = finerToCoarse(meshSon,meshFather);
        fprintf('deliver data from block %d to block %d\n',LBM.meshContain{i}(j),i)
    end
end
% Write mesh data in vtks
writeFluidVTK(meshFather,writeNameFather)
% Calculate space averaging data
meanData.u  = mean(mean(meshFather.u,1),3) * LBM.Uref;
meanData.v  = mean(mean(meshFather.v,1),3) * LBM.Uref;
meanData.w  = mean(mean(meshFather.w,1),3) * LBM.Uref;
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
turbulent.tau_w  = LBM.Mu * meanData.u(firstGrid) / h0;                 % μ*u_0/y_0
turbulent.u_tau  = sqrt(turbulent.tau_w / LBM.denIn);                   % sqrt(τ_w/ρ)
turbulent.Re_tau = turbulent.u_tau * LBM.Lref * LBM.denIn / LBM.Mu;
turbulent.y_plus = turbulent.u_tau * y_coor(1,:) * LBM.denIn / LBM.Mu;  % y*u_τ/ν
% Calculate first order statistic
turbulent.u_plus = meanData.u / turbulent.u_tau;
turbulent.v_plus = meanData.v / turbulent.u_tau;
turbulent.w_plus = meanData.w / turbulent.u_tau;
%% Write files
linear_law = turbulent.y_plus;
log_law    = 2.5 * log(turbulent.y_plus) + 5.5;
fileID = fopen([casePath '\DatInfo\turbulentFirst.plt'], 'w');
fprintf(fileID, 'variables= "y_plus" "u_plus" "v_plus" "w_plus" "linear_law" "log_law"\n');
for j = 1:length(turbulent.y_plus)
    fprintf(fileID, [repmat('%.8g ', 1, 6), '\n'], turbulent.y_plus(j),  turbulent.u_plus(j),  turbulent.v_plus(j),  turbulent.w_plus(j), linear_law(j), log_law(j));
end
fclose(fileID);
disp(turbulent.Re_tau)
