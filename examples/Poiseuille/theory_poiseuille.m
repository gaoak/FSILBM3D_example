clear
clc
%% initial parameters
rho = 1;
Re = 5;
Lref = 1;
Uref = 0.1;
LBMnu = Uref*Lref/Re;
LBMmu = rho*LBMnu;
h = 5;
P = 1;
%% read file
t = 120;
folder = ' casePath /FSILBM3D_example/examples/Poiseuille/DatFlow/';
    filename = sprintf('%s%s%s%s',folder,'Flow0',num2str(t,'%04d'),'00000_b001');
    fileID = fopen(filename,"rb");
    if fileID == -1
        error('no file')
    end
    xyzdim = fread(fileID,4,'int32');
    xyzmin = fread(fileID,4,'float64');
    u_data = fread(fileID,xyzdim(1)*xyzdim(2)*xyzdim(3),'float32');
    u_dns = reshape(u_data,[xyzdim(3),xyzdim(2),xyzdim(1)]);
    v_data = fread(fileID,xyzdim(1)*xyzdim(2)*xyzdim(3),'float32');
    v_dns = reshape(v_data,[xyzdim(3),xyzdim(2),xyzdim(1)]);
    w_data = fread(fileID,xyzdim(1)*xyzdim(2)*xyzdim(3),'float32');
    w_dns = reshape(w_data,[xyzdim(3),xyzdim(2),xyzdim(1)]);
fclose(fileID);
%% theory
dpdx = -P*2*LBMmu*Uref/h^2;
y = -5:0.25:5;
u = P*(1-(y/h).^2)*Uref;
hold on
plot(u,y,'k')
%% FSILBM3D
ymin = xyzmin(2);
ydim = xyzdim(2);
dh = xyzmin(4);
plot(reshape(u_dns(floor((xyzdim(3)+1)/2),1:xyzdim(2),floor((xyzdim(1)+1)/2)),xyzdim(2),1)*Uref,ymin:dh:ymin+dh*(ydim-1),'r-o')
legend('theory','FSILBM3D')