run getParameters.m
% Set solid index
group.name = 'Group002';
% which file to extract
readPath   = [casePath '\DatInfo\' group.name '_lastNode.dat'];
% Read time steps
fileID = fopen(readPath,'r');
if fileID == -1
    error('Cant found file : %s',readPath);
end
% Get line numbers and time steps
timeStep = 0;
tmpLine  = fgetl(fileID);
while ~feof(fileID)
    keyLine  = fgetl(fileID);
    % check the keyword
    if contains(keyLine, 'time')
        timeStep = timeStep + 1;
        times(timeStep) = str2double(keyLine(16:25))/1e5;
        zoneTitle = keyLine;
    end
end
keyCell    = strsplit(strtrim(zoneTitle));
group.nx   = str2double(strrep(keyCell(7 ),',',''));
group.nz   = str2double(strrep(keyCell(13),',',''));
group.nums = group.nx * group.nz;
% Read data
group.xlim = zeros(group.nx,1);
group.zlim = zeros(group.nz,1);
group.dx   = zeros(group.nz,group.nx,timeStep);
group.dy   = zeros(group.nz,group.nx,timeStep);
group.dz   = zeros(group.nz,group.nx,timeStep);
group.line = readlines(readPath);
% Read coordinates
for j=1:group.nz
    for k=1:group.nx
        dataLine = (j - 1)*group.nx + k + 2;
        tmpData  = str2num(group.line(dataLine));
        group.xlim(k) = tmpData(1);
    end
    group.zlim(j) = tmpData(3);
end
% Read displacments
for i=1:timeStep
    for j=1:group.nz
        for k=1:group.nx
            dataLine = (i - 1)*(group.nums + 1) + (j - 1)*group.nx + k + 2;
            tmpData  = str2num(group.line(dataLine));
            group.dx(j,k,i) = tmpData(4);
            group.dy(j,k,i) = tmpData(5) - 1;
            group.dz(j,k,i) = tmpData(6);
        end
    end
end
%% Fourier transform sampling interval for x,y,t
group.ds = sqrt(group.dx.*group.dx + group.dy.*group.dy + group.dz.*group.dz);
temp.deltax = group.xlim(2) - group.xlim(1);
temp.deltaz = group.zlim(2) - group.zlim(1);
temp.deltat = times(2) - times(1);                   
temp.xCoord = (-group.nx:group.nx-1)/(temp.deltax*group.nx*2);  % add zero elements
temp.zCoord = (-group.nz:group.nz-1)/(temp.deltaz*group.nz*2);
temp.times  = (-timeStep:timeStep-1)/(temp.deltat*timeStep*2);
% Creat folder
if ~exist([casePath '\DatFigures\PostFFT2D'],'dir')
    mkdir([casePath '\DatFigures\PostFFT2D'])
    mkdir([casePath '\DatFigures\Qcriterion'])
    mkdir([casePath '\DatFigures\Deformation'])
end
%% FFT2D in space (x,z)
timeNumber = 600;  % space data in which time
fourier.spaceData  = zeros(group.nz*2,group.nx*2);
fourier.spaceData(1:group.nz,1:group.nx) = group.ds(:,:,timeNumber)-mean(mean(group.ds(:,:,timeNumber))); % remove zero frequency components
fourier.spaceTrans = fft2(fourier.spaceData);
fourier.spaceShift = fftshift(fourier.spaceTrans);
fourier.spaceMag   = abs(fourier.spaceShift);
% plot
figure('Position', [400, 200, 1200, 600]);
imagesc(temp.xCoord, temp.zCoord, fourier.spaceMag); 
xlim([-1.0 1.0]);ylim([-1.0 1.0]);xticks(-1.0:1:1.0);yticks(-1.0:1:1.0);
set(gca, 'FontSize', 24, 'FontName', 'Times New Roman');
xlabel('\it k_x ', 'FontName', 'Times New Roman', 'FontSize', 24);
ylabel('\it k_z ', 'FontName', 'Times New Roman', 'FontSize', 24);
colormap sky; colorbar; clim([0, 1.2]); colorbar('Ticks', (0:0.3:1.2));
% saveas(gcf, [casePath '\DatFigures\PostFFT2D\FFT2D_X_Z.png']);
%% FFT2D in space and time (x,t)
fourier.timeData = zeros(group.nx*2,timeStep*2);
temp.timeData    = zeros(group.nx,timeStep);
for t=1:timeStep
    temp.timeData(:,t)    = mean(group.dx(:,:,t),1);
    fourier.timeData(1:group.nx,t) = mean(group.dx(:,:,t),1) - mean(mean(group.dx(:,:,t)));  % averaeing in z direction
end
fourier.timeTrans = fft2(fourier.timeData);
fourier.timeShift = fftshift(fourier.timeTrans);
fourier.timeMag   = abs(fourier.timeShift);
% plot
figure('Position', [400, 200, 1200, 600]);
imagesc(group.xlim, times, temp.timeData);
xlim([5 11]);ylim([0 10]);xticks(5:2:11);yticks(0:2:10);
set(gca, 'FontSize', 24, 'FontName', 'Times New Roman');
xlabel('\it x ', 'FontName', 'Times New Roman', 'FontSize', 24);
ylabel('\it t ', 'FontName', 'Times New Roman', 'FontSize', 24);
colormap(color.Map1); colorbar; clim([-0.008, 0.008]); colorbar('Ticks', (-0.008:0.004:0.008));
% saveas(gcf, [casePath '\DatFigures\PostFFT2D\Displacement_X_T.png']);
% plot
figure('Position', [400, 200, 1200, 600]);
imagesc(temp.xCoord, temp.times, fourier.timeMag'); 
xlim([-2 2]);ylim([-0.5 0.5]);xticks(-2:1:2);yticks(-1:0.5:1);
set(gca, 'FontSize', 24, 'FontName', 'Times New Roman');
xlabel('\it k_x ', 'FontName', 'Times New Roman', 'FontSize', 24);
ylabel('\it f ', 'FontName', 'Times New Roman', 'FontSize', 24);
colormap sky; colorbar; clim([0, 40]); colorbar('Ticks', (0:10:40));
% saveas(gcf, [casePath '\DatFigures\PostFFT2D\FFT2D_X_T.png']);
% calculate wave speed
[temp.maxVal, temp.index0] = max(fourier.timeMag(:));
[temp.index1, temp.index2] = ind2sub(size(fourier.timeShift), temp.index0);
fourier.waveSpeed          = (1/temp.xCoord(temp.index1)) / (1/temp.times(temp.index2))
fclose all;
% %% FFT2D in space and time (z,t)
% fourier.timeData = zeros(group.nz*2,timeStep*2);
% temp.timeData    = zeros(group.nz,timeStep);
% for t=1:timeStep
%     temp.timeData(:,t)    = mean(group.dx(:,:,t),2);
%     fourier.timeData(1:group.nz,t) = mean(group.dx(:,:,t),2) - mean(mean(group.dx(:,:,t)));  % averaeing in z direction
% end
% fourier.timeTrans = fft2(fourier.timeData);
% fourier.timeShift = fftshift(fourier.timeTrans);
% fourier.timeMag   = abs(fourier.timeShift);
% % plot
% figure('Position', [400, 200, 1200, 600]);
% imagesc(group.zlim, times, temp.timeData);
% xlim([0.5 4.5]);ylim([0 10]);xticks(0.5:1:4.5);yticks(0:2:8);
% set(gca, 'FontSize', 24, 'FontName', 'Times New Roman');
% xlabel('\it z ', 'FontName', 'Times New Roman', 'FontSize', 24);
% ylabel('\it t ', 'FontName', 'Times New Roman', 'FontSize', 24);
% colormap(color.Map1); colorbar; clim([-0.002, 0.002]); colorbar('Ticks', (-0.002:0.001:0.002));
% saveas(gcf, [casePath '\DatFigures\PostFFT2D\Displacement_Z_T.png']);
% % plot
% figure('Position', [400, 200, 1200, 600]);
% imagesc(temp.zCoord, temp.times, fourier.timeMag'); 
% xlim([-2 2]);ylim([-0.5 0.5]);xticks(-2:1:2);yticks(-1:0.5:1);
% set(gca, 'FontSize', 24, 'FontName', 'Times New Roman');
% xlabel('\it k_x ', 'FontName', 'Times New Roman', 'FontSize', 24);
% ylabel('\it f ', 'FontName', 'Times New Roman', 'FontSize', 24);
% colormap sky; colorbar; clim([0, 5]); colorbar('Ticks', (0:1:5));
% saveas(gcf, [casePath '\DatFigures\PostFFT2D\FFT2D_Z_T.png']);


% fprintf('Estimated k: %.2f rad/m, ω: %.2f rad/s\n', temp.xCoord(temp.index1), temp.times(temp.index2));
% fprintf('Phase velocity: %.2f m/s\n', fourier.velocity);
% figure('Position', [400, 200, 1000, 600]);    
% hold on;box on;
% for i = 1:timeStep
%     b = bar(temp.timeSteps(i),fourier.magnitude(i),0.01,'stacked');  
%     set(b(1),'facecolor',[0,0,0]/255)
% end
% scatter(temp.timeSteps,fourier.magnitude,32,'filled','r')
% xlim([0 4]);ylim([0 3]);xticks(0:1:10);yticks(0:1:4);
% set(gca, 'FontSize', 16, 'FontName', 'Times New Roman');
% xlabel('\itf', 'FontName', 'Times New Roman', 'FontSize', 16);
% ylabel('\itA', 'FontName', 'Times New Roman', 'FontSize', 16);
