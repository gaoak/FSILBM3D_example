function [meshFather] = finerToCoarse(meshson,meshFather)
% get indexs
nz1 = round((meshson.zmin - meshFather.zmin) / meshFather.dh) + 1;
nz2 = nz1 + floor((meshson.nz - 1)/2);      % if son block used periodic boundary, the son block is one grid more than the father block
ny1 = round((meshson.ymin - meshFather.ymin) / meshFather.dh) + 1;
ny2 = ny1 + floor((meshson.ny - 1)/2);
nx1 = round((meshson.xmin - meshFather.xmin) / meshFather.dh) + 1;
nx2 = nx1 + floor((meshson.nx - 1)/2);
% update date in coarse mesh
meshFather.u(nx1:nx2,ny1:ny2,nz1:nz2) = meshson.u(1:2:meshson.nx,1:2:meshson.ny,1:2:meshson.nz);
meshFather.v(nx1:nx2,ny1:ny2,nz1:nz2) = meshson.v(1:2:meshson.nx,1:2:meshson.ny,1:2:meshson.nz);
meshFather.w(nx1:nx2,ny1:ny2,nz1:nz2) = meshson.w(1:2:meshson.nx,1:2:meshson.ny,1:2:meshson.nz);
if exist('meshFather.uu','var')
    meshFather.uu(nx1:nx2,ny1:ny2,nz1:nz2) = meshson.uu(1:2:meshson.nx,1:2:meshson.ny,1:2:meshson.nz);
    meshFather.vv(nx1:nx2,ny1:ny2,nz1:nz2) = meshson.vv(1:2:meshson.nx,1:2:meshson.ny,1:2:meshson.nz);
    meshFather.ww(nx1:nx2,ny1:ny2,nz1:nz2) = meshson.ww(1:2:meshson.nx,1:2:meshson.ny,1:2:meshson.nz);
    meshFather.uv(nx1:nx2,ny1:ny2,nz1:nz2) = meshson.uv(1:2:meshson.nx,1:2:meshson.ny,1:2:meshson.nz);
    meshFather.uw(nx1:nx2,ny1:ny2,nz1:nz2) = meshson.uw(1:2:meshson.nx,1:2:meshson.ny,1:2:meshson.nz);
    meshFather.vw(nx1:nx2,ny1:ny2,nz1:nz2) = meshson.vw(1:2:meshson.nx,1:2:meshson.ny,1:2:meshson.nz);
end
end
