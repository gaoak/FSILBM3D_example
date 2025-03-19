clear,clc,close all
% Convert the continue file from the old format to the new format
% Setting parameters
nblocks = 1;        % number of fluid blocks
Tref    = 1000;     % the reference time in computing
xDim    = [315];    % the grids of each fluid block
yDim    = [100];
zDim    = [158];
xMin    = [0.0];
yMin    = [0.0];
zMin    = [0.0];
dh      = [1.0];
lbmDim  = 19;       % D3Q19 model
oldFile = 'G:\TandemPlates\Validation\Comparison\Case3DTurbulentReTau180\DatContinue\continue0420000000';
newFile = 'G:\TandemPlates\Validation\Comparison\Case3DTurbulentReTau180\DatContinue\continue';
% Declare variables
step = zeros(nblocks);
time = zeros(nblocks);
fIns = cell (nblocks);
% Read old continue file
fileID = fopen(oldFile,'r');
if fileID == -1
    error('Can not found fluid mesh files! : %s',filePath);
end
for n=1:nblocks
    step(n) = fread(fileID, 1, 'int32' );
    time(n) = fread(fileID, 1, 'double');
    fIns{n} = fread(fileID, zDim(n) * yDim(n) * xDim(n) * lbmDim, 'double');
end
% write new continue file
fileID = fopen(newFile, 'wb');
fwrite(fileID, nblocks, 'int32');
fwrite(fileID, step(1), 'int32');
fwrite(fileID, time(1)/Tref, 'double');
for n=1:nblocks
    fwrite(fileID, xMin(n), 'double');
    fwrite(fileID, yMin(n), 'double');
    fwrite(fileID, zMin(n), 'double');
    fwrite(fileID, dh(n)  , 'double');
    fwrite(fileID, xDim(n), 'int32' );
    fwrite(fileID, yDim(n), 'int32' );
    fwrite(fileID, zDim(n), 'int32' );
    fwrite(fileID, fIns{n}, 'double');
end
fclose all;