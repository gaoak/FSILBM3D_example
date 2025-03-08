clear;clc;close all;format long
%% Case path
isOnlyWriteRootBlock = true;
casePath  = 'G:\TandemPlates\Validation\Comparison\Case3DTurbulent2';
%% Read key lines
readLine.ViscLine  = readKeyLines([casePath '\check.dat' ],'Nu'            ,1);
readLine.UrefLine  = readKeyLines([casePath '\check.dat' ],'Uref'          ,1);
readLine.TrefLine  = readKeyLines([casePath '\check.dat' ],'Tref'          ,1);
readLine.LrefLine  = readKeyLines([casePath '\check.dat' ],'Lref'          ,1);
readLine.blockLine = readKeyLines([casePath '\check.dat' ],'sonBlocks'     ,1);
readLine.densLine  = readKeyLines([casePath '\inFlow.dat'],'denIn'         ,1);
readLine.UVWlLine  = readKeyLines([casePath '\inFlow.dat'],'uvwIn'         ,1);
readLine.TimeLine  = readKeyLines([casePath '\inFlow.dat'],'timeWriteBegin',1);
readLine.TotalLine = readKeyLines([casePath '\inFlow.dat'],'timeSimTotal'  ,1);
readLine.deltaLine = readKeyLines([casePath '\inFlow.dat'],'timeWriteFlow' ,1); 
readLine.fluidLine = readKeyLines([casePath '\inFlow.dat'],'nblock'        ,1);
readLine.solidLine = readKeyLines([casePath '\inFlow.dat'],'nFish'         ,1);
if str2double(readLine.deltaLine{1}) ~= str2double(readLine.deltaLine{2})
    warning('solid writing interval %f does not equal fluid writing interval %f!',str2double(deltaLine{1}),str2double(deltaLine{2}))
end
%% Read key parameters
LBM.Nu     = str2double(readLine.ViscLine{3}); % viscosity
LBM.denIn  = str2double(readLine.densLine{2}); % fluid density
LBM.Uref   = str2double(readLine.UrefLine{3}); % reference velocity
LBM.Tref   = str2double(readLine.TrefLine{3}); % reference time
LBM.Lref   = str2double(readLine.LrefLine{3}); % reference length
LBM.sTime  = str2double(readLine.TimeLine{1}); % begine time for writing 
LBM.eTime  = min(str2double(readLine.TotalLine{1}),str2double(readLine.TimeLine{2})); % ending time for writing 
LBM.dTime  = str2double(readLine.deltaLine{1}); % writing intervl
LBM.nBlock = floor(str2double(readLine.fluidLine{1})); % the number of fluid blocks
LBM.nSolid = floor(str2double(readLine.solidLine{1})); % the number of solids
LBM.meshContain = cell(LBM.nBlock); % the contian relationship of the fluid blocks, the space means no son block
if LBM.nSolid == 0
    LBM.UVW    = [0 0 0]; % mesh moving velocity
else
    LBM.UVW    = [str2double(readLine.UVWlLine{1}) str2double(readLine.UVWlLine{2}) str2double(readLine.UVWlLine{3})]; % mehs moving velocity
end
for n = 1:LBM.nBlock
    blockLine = readKeyLines([casePath '\check.dat'],'sonBlocks',n);
    if length(blockLine) <= 2
        LBM.meshContain{n} = [];
    else
        for j = 1:length(blockLine)-2
        LBM.meshContain{n} = [LBM.meshContain{n} str2double(readLine.blockLine{2+j})];
        end
    end
end
%% Calculate key parameters
nfile  = (LBM.eTime - LBM.sTime) / LBM.dTime + 1;
