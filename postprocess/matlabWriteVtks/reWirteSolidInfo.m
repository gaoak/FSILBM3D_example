run getParameters.m
% Set solid index
group.name = 'Group002';
group.info = 'lastNode';
% which file to extract
readPath   = [casePath '\DatInfo\' group.name '_' group.info '.dat'];
timePath   = [casePath '\DatInfo\' group.name '_' group.info '_time.dat'];
meanPath   = [casePath '\DatInfo\' group.name '_' group.info '_mean.dat'];
% Read time steps
fileID1 = fopen(readPath,'r');
if fileID1 == -1
    error('Cant found file : %s',readPath);
end
variables.name = strsplit(strtrim(fgetl(fileID1)));
variables.name = variables.name(3:end);
variables.nums = length(variables.name);  % get variable numbers
% Get line numbers and time steps
timeStep = 0;
lineNums = 0;
while ~feof(fileID1)
    keyLine  = fgetl(fileID1);
    % check the keyword
    if contains(keyLine, 'time')
        timeStep = timeStep + 1;
        times(timeStep) = str2double(keyLine(16:25))/1e5;
    end
    lineNums = lineNums + 1;
end
group.nums = floor(lineNums/timeStep) - 1;
% Read data
group.line = readlines(readPath);
group.data = cell(timeStep,group.nums);
for i=1:timeStep
    for j=1:group.nums
        dataLine = (i - 1)*(group.nums + 1) + j + 2;
        group.data{i,j} = str2num(group.line(dataLine));
    end
end
% Write time data
fileID2 = fopen(timePath,'w');
fprintf(fileID2, 'VARIABLES = "t"');
for n=1:variables.nums
    fprintf(fileID2, '  %s',variables.name{n});
end
fprintf(fileID2, '\n');
for i=1:group.nums
    fprintf(fileID2, '    ZONE T = "fish%03d"\n',i);
    for j=1:timeStep
        fprintf(fileID2, [repmat('    %.8e', 1, variables.nums + 1), '\n'], times(j), group.data{j,i});
    end
end
fprintf('Writing file ready : %s\n', timePath)
% Write mean data
fileID3 = fopen(meanPath,'w');
fprintf(fileID3, 'VARIABLES = "t"');
for n=1:variables.nums
    fprintf(fileID3, '  %s',variables.name{n});
end
fprintf(fileID3, '\n');
group.mean = zeros(timeStep,variables.nums);
for i=1:timeStep
    for j=1:group.nums
        group.mean(i,:) = group.mean(i,:) + group.data{i,j};
    end
end
for k=1:timeStep
    fprintf(fileID3, [repmat('    %.8e', 1, variables.nums + 1), '\n'], times(k), group.mean(k,:)/group.nums);
end
fprintf('Writing file ready : %s\n', meanPath)
fclose all;