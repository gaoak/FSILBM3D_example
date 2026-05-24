clc; clear;

filename = 'DatInfo/Group001_lastNode.dat';  % your file pwd

fid = fopen(filename, 'r');
if fid < 0
    error('Cannot open file: %s', filename);
end

dx_first = [];

while ~feof(fid)
    line = strtrim(fgetl(fid));

    if startsWith(line, 'ZONE', 'IgnoreCase', true)
        dataLine = fgetl(fid);
        vals = sscanf(dataLine, '%f');
        dx_first(end+1,1) = vals(4);
    end
end

fclose(fid);

% display
disp(dx_first);

% save
writematrix(dx_first, 'dx_first.txt');