function [] = writeSolidPLT(solid,writeFile,nSolid)
% file path
fileID = fopen(writeFile, 'w');
% Write tecplot file header
fprintf(fileID, 'VARIABLES = "x" "y" "z"\n');
% Write zones and data
for i=1:nSolid
    fprintf(fileID, ' ZONE T = "fish%03d" N = %d, E = %d, DATAPACKING=POINT, ZONETYPE=FEQUADRILATERAL\n',i,solid.nodesV,solid.nodesI);
    for j=1:solid.nodesV
    fprintf(fileID, ' %f    %f    %f\n',solid.coor{i}(j,1:3));
    end
    for j=1:solid.nodesI
    fprintf(fileID, ' %d    %d    %d    %d\n',solid.elem(j,1:4));
    end
end
% Close the file
fprintf('Writing ready : %s\n', writeFile)
fclose all;
end
