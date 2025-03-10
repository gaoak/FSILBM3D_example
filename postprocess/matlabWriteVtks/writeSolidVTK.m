function [] = writeSolidVTK(solid,writeFile)
% file path
fileID = fopen(writeFile, 'w');
% Write VTK file header
fprintf(fileID, '# vtk DataFile Version 3.0\n');
fprintf(fileID, 'VTK file generated by MATLAB\n');
fprintf(fileID, 'ASCII\n');
fprintf(fileID, 'DATASET STRUCTURED_GRID\n');

% Write grid dimensions
fprintf(fileID, 'DIMENSIONS %d %d %d\n', solid.nx, solid.ny, solid.nz);

% Write point coordinates
fprintf(fileID, 'POINTS %d float\n', solid.nx * solid.ny * solid.nz);

% Write coordinates 
for i = 1:solid.nx
    fprintf(fileID, '%f %f %f\n', solid.xl(i), solid.yl(i), solid.zl(i));
end
for k = 1:solid.nx
    fprintf(fileID, '%f %f %f\n', solid.xr(k), solid.yr(k), solid.zr(k));
end
% Write point data
fprintf(fileID, 'POINT_DATA %d\n', solid.nx * solid.ny * solid.nz);

% Close the file
fprintf('Writing ready : %s\n', writeFile)
fclose all;
end
