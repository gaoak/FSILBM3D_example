run getParameters.m
% Set solid index
group.name = 'Group002';
group.nums = 270;  % how many solids in the group
group.indx = 1;  % the index of the extracting solid
% file paths
readPath   = [casePath '\DatInfo\'  group.name '_firstNode.dat'];
writePath  = [casePath '\DatInfo\T' group.name '_firstNode.dat'];
% check parameters 
if group.indx > group.nums
    error('group.indx must less then group.nums')
end
% Get line numbers
realLines = readlines(readPath);
lineCount = length(realLines);
timeSteps = (lineCount - 2) / (group.nums + 1);
% Read time steps
times  = zeros(1,timeSteps);
fileID = fopen(readPath,'r');
if fileID == -1
    error('Cant found file : %s',readPath);
end
flag = 0;
variables = strsplit(strtrim(fgetl(fileID)));
while ~feof(fileID)
    keyLine = fgetl(fileID);
    % check the keyword
    if contains(keyLine, 'time')
        flag = flag + 1;
        times(flag) = str2double(keyLine(16:25))/1e5;
    end
end
indexNum = length(strsplit(strtrim(keyLine)));  % get variable numbers
dataMarx = zeros(timeSteps,indexNum);
for step=1:timeSteps
    lines = (step - 1) * (group.nums + 1) + group.indx + 2;
    dataMarx(step,:) = str2num(realLines(lines));
end
% Rewrite data
fileID = fopen(writePath,'w');
fprintf(fileID, ' VARIABLES = "t"');
for j=1:indexNum-3
    fprintf(fileID, '  %s',variables{j+5});
end
fprintf(fileID, '\n');
for k=1:timeSteps
    fprintf(fileID, [repmat('%.8f ', 1, indexNum-2), '\n'], times(k), dataMarx(k,4:indexNum));
end
fprintf('Writing file ready : %s\n', writePath)
fclose all;