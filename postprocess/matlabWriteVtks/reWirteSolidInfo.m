run getParameters.m
% Set solid index
group.name = 'Group002';
group.nums = 270;  % how many solids in the group
group.indx = 1;  % the index of the extracting solid
% Get line numbers
filePath  = [casePath '\DatInfo\' group.name '_firstNode.plt'];
lineCount = length(readlines(filePath));
timeSteps = (lineCount - 2) / (group.nums + 1);
% Read time steps
times  = zeros(1,timeSteps);
fileID = fopen(filePath,'r');
if fileID == -1
    error('Cant found file : %s',filePath);
end
flag = 0;
while ~feof(fileID)
    keyLine = fgetl(fileID);
    % check the keyword
    if contains(keyLine, 'time')
        flag = flag + 1;
        times(flag) = str2double(keyLine(16:25))/1e5;
    end
end

% Rewrite forces
% keyLine = strrep(keyLine, 'D', 'E');
% keyLine = strrep(keyLine, 'd', 'E');
fclose all;