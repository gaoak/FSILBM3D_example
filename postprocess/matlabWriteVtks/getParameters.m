clear;clc;close all;format long
%% Case path
isOnlyWriteRootBlock = true;
isUseMovingGridPost  = true;  
% only for moving girds
isHalfWayBounceBack  = false;
isGiveCalculateTime  = [8 0.125 10];  
% empty means using the parameters in inflow.dat
casePath = 'H:\FishNearFlexibleGround\SourceData3D_2026\Re100H0.50A0.25AR1.00';
%% Read key lines
if isfile([casePath '\check.dat'])
    file.check = '\check.dat';
elseif isfile([casePath '\Check.dat'])
    file.check = '\Check.dat';
else
    error('Can not found check file!');
end
if isfile([casePath '\inFlow.dat'])
    file.inflow = '\inFlow.dat';
else
    error('Can not found inflow file! : %s',[casePath '\inFlow.dat']);
end
readLine.ViscLine  = readAscallLines([casePath file.check ],'Mu'            ,1);
readLine.UrefLine  = readAscallLines([casePath file.check ],'Uref'          ,1);
readLine.TrefLine  = readAscallLines([casePath file.check ],'Tref'          ,1);
readLine.LrefLine  = readAscallLines([casePath file.check ],'Lref'          ,1);
readLine.PresLine  = readAscallLines([casePath file.check ],'Pref'          ,1);
readLine.blockLine = readAscallLines([casePath file.check ],'sonBlocks'     ,1);
readLine.densLine  = readAscallLines([casePath file.inflow],'denIn'         ,1);
readLine.UVWlLine  = readAscallLines([casePath file.inflow],'uvwIn'         ,1);
readLine.solidLine = readAscallLines([casePath file.inflow],'nFish'         ,1);
readLine.fluidLine = readAscallLines([casePath file.inflow],'nblock'        ,1);
readLine.TimeLine  = readAscallLines([casePath file.inflow],'timeWriteBegin',1);
readLine.TotalLine = readAscallLines([casePath file.inflow],'timeSimTotal'  ,1);
readLine.deltaLine = readAscallLines([casePath file.inflow],'timeWriteFlow' ,1); 
if str2double(readLine.deltaLine{1}) ~= str2double(readLine.deltaLine{2})
    warning('solid writing interval %f does not equal fluid writing interval %f!',str2double(deltaLine{1}),str2double(deltaLine{2}))
end
%% Read key parameters
LBM.Mu     = str2double(readLine.ViscLine{3}); % viscosity
LBM.denIn  = str2double(readLine.densLine{2}); % fluid density
LBM.Uref   = str2double(readLine.UrefLine{3}); % reference velocity
LBM.Tref   = str2double(readLine.TrefLine{3}); % reference time
LBM.Lref   = str2double(readLine.LrefLine{3}); % reference length
LBM.Pref   = str2double(readLine.PresLine{3}); % reference pressure
LBM.nBlock = floor(str2double(readLine.fluidLine{1})); % the number of fluid blocks
LBM.nSolid = floor(str2double(readLine.solidLine{1})); % the number of solids
LBM.meshContain = cell(LBM.nBlock); % the contian relationship of the fluid blocks, the space means no son block
if isUseMovingGridPost
    LBM.UVW    = [str2double(readLine.UVWlLine{1}) str2double(readLine.UVWlLine{2}) str2double(readLine.UVWlLine{3})]; % mehs moving velocity
else
    LBM.UVW    = [0 0 0];
end
if ~isempty(isGiveCalculateTime)
    LBM.sTime = isGiveCalculateTime(1);
    LBM.dTime = isGiveCalculateTime(2);
    LBM.eTime = isGiveCalculateTime(3);
else
    LBM.sTime  = str2double(readLine.TimeLine{1}); % begine time for writing 
    LBM.eTime  = min(str2double(readLine.TotalLine{1}),str2double(readLine.TimeLine{2})); % ending time for writing 
    LBM.dTime  = str2double(readLine.deltaLine{1}); % writing intervl
end
for n = 1:LBM.nBlock
    blockLine = readAscallLines([casePath '\check.dat'],'sonBlocks',n);
    if length(blockLine) <= 2
        LBM.meshContain{n} = [];
    else
        for j = 1:length(blockLine)-2
        LBM.meshContain{n} = [LBM.meshContain{n} str2double(readLine.blockLine{2+j})];
        end
    end
end
%% Calculate key parameters
nfile = round((LBM.eTime - LBM.sTime) / LBM.dTime) + 1;
%% Set my color map
color.Map1 = zeros(256,3);
for n = 1:128
   color.Map1(n,:)     = [0,0,1] + [1,1,0]*n/128;
end
for n = 1:128
   color.Map1(n+128,:) = [1,1,1] - [0,1,1]*n/128;
end