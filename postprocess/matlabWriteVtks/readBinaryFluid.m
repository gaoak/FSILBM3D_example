function [mesh] = readBinaryFluid(filePath,time,inflowVelocity,Uref,Lref,Tref)
% Open file
fileID = fopen(filePath,'r');
if fileID == -1
    error('Can not found fluid mesh files! : %s',filePath);
end
% Read paramters
mesh.nx   = fread(fileID, 1, 'int32' );
mesh.ny   = fread(fileID, 1, 'int32' );
mesh.nz   = fread(fileID, 1, 'int32' );
mesh.id   = fread(fileID, 1, 'int32' );
mesh.xmin = fread(fileID, 1, 'double') / Lref  - inflowVelocity(1) / Lref * time * Tref;  % dimensionless
mesh.ymin = fread(fileID, 1, 'double') / Lref  - inflowVelocity(2) / Lref * time * Tref;
mesh.zmin = fread(fileID, 1, 'double') / Lref  - inflowVelocity(3) / Lref * time * Tref;
mesh.dh   = fread(fileID, 1, 'double') / Lref ;
% Read pressure and velocities
p  = fread(fileID, mesh.nz * mesh.ny * mesh.nx, 'float32');
u  = fread(fileID, mesh.nz * mesh.ny * mesh.nx, 'float32') - inflowVelocity(1) / Uref; % k,j,i
v  = fread(fileID, mesh.nz * mesh.ny * mesh.nx, 'float32') - inflowVelocity(2) / Uref; % dimensionless
w  = fread(fileID, mesh.nz * mesh.ny * mesh.nx, 'float32') - inflowVelocity(3) / Uref;
mesh.p  = permute(reshape(p,  [mesh.nz mesh.ny mesh.nx]),[3 2 1]); % i,j,k
mesh.u  = permute(reshape(u,  [mesh.nz mesh.ny mesh.nx]),[3 2 1]);
mesh.v  = permute(reshape(v,  [mesh.nz mesh.ny mesh.nx]),[3 2 1]);
mesh.w  = permute(reshape(w,  [mesh.nz mesh.ny mesh.nx]),[3 2 1]);
% Read turbulent statistics
uu = fread(fileID, mesh.nz * mesh.ny * mesh.nx, 'float32'); 
if ~isempty(uu)
    vv = fread(fileID, mesh.nz * mesh.ny * mesh.nx, 'float32'); 
    ww = fread(fileID, mesh.nz * mesh.ny * mesh.nx, 'float32');
    uv = fread(fileID, mesh.nz * mesh.ny * mesh.nx, 'float32'); 
    uw = fread(fileID, mesh.nz * mesh.ny * mesh.nx, 'float32'); 
    vw = fread(fileID, mesh.nz * mesh.ny * mesh.nx, 'float32');
    mesh.uu = permute(reshape(uu, [mesh.nz mesh.ny mesh.nx]),[3 2 1]);
    mesh.vv = permute(reshape(vv, [mesh.nz mesh.ny mesh.nx]),[3 2 1]);
    mesh.ww = permute(reshape(ww, [mesh.nz mesh.ny mesh.nx]),[3 2 1]);
    mesh.uv = permute(reshape(uv, [mesh.nz mesh.ny mesh.nx]),[3 2 1]);
    mesh.uw = permute(reshape(uw, [mesh.nz mesh.ny mesh.nx]),[3 2 1]);
    mesh.vw = permute(reshape(vw, [mesh.nz mesh.ny mesh.nx]),[3 2 1]);
end
% Calculate max coordinates
mesh.xmax = mesh.xmin + (mesh.nx - 1) * mesh.dh;
mesh.ymax = mesh.ymin + (mesh.ny - 1) * mesh.dh;
mesh.zmax = mesh.zmin + (mesh.nz - 1) * mesh.dh;
% Calculate coordinates
array.x = mesh.xmin : mesh.dh : mesh.xmax;
array.y = mesh.ymin : mesh.dh : mesh.ymax;
array.z = mesh.zmin : mesh.dh : mesh.zmax;
[mesh.x, mesh.y, mesh.z] = ndgrid(array.x, array.y, array.z);
fclose(fileID);
end
