function [readName,writeName] = generateSolidPath(readPath,writePath,nTime,id)
% Convert input numbers to strings
numStr1 = num2str(nTime * 1e5);
numStr2 = num2str(id);
% Calculate the number of zeros that need to be filled in the first place
zeroNumber1 = 10 - length(numStr1);
zeroNumber2 = 3  - length(numStr2);
% If zero is required
if zeroNumber1 > 0
    % Make up zeros in front
    newStr1 = [repmat('0', 1, zeroNumber1), numStr1];
else
    % If the length is sufficient, return directly
    newStr1 = numStr1;
end
if zeroNumber2 > 0
    % Make up zeros in front
    newStr2 = [repmat('0', 1, zeroNumber2), numStr2];
else
    % If the length is sufficient, return directly
    newStr2 = numStr2;
end
readName  = [readPath  'BodyFake' newStr2 '_' newStr1 '.dat'];
writeName = [writePath 'BodyFake' newStr2 '_' newStr1 '.vtk'];
end
