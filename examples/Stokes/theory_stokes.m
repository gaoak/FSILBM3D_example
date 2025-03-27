clear
clc
%% initial parameters
rho = 1;
Re = 10;
Lref = 1;
Uref = 0.0625;
LBMnu = Uref*Lref/Re;
LBMmu = rho*LBMnu;
h = 20;
f = 0.00125;
omega = 2*pi*f;
delta_s = (2*LBMnu/omega)^0.5;
%% read file
LBMt = 50;
folder = ' casePath /FSILBM3D_example/examples/Stokes/DatFlow/';
    filename = sprintf('%s%s%s%s',folder,'Flow0',num2str(LBMt,'%04d'),'00000_b001');
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
t = 0:1/f/8:1/f;
y = 0:0.1:20;
u = zeros(length(y),length(t));
hold on
for i = 1:9
    u(:,i) = Uref*cos(-omega*t(i))-Uref*exp(-y/delta_s).*cos(y/delta_s-omega*t(i));
end
delta_s_x = -0.2:0.1:0.2;
delta_s_y = repelem(delta_s,length(delta_s_x));
plot(delta_s_x,delta_s_y,'--',u(:,6),y,u(:,7),y,u(:,8),y,u(:,9),y);
axis([-0.07 0.07 0 20])
%% FSILBM3D
ymin = xyzmin(2);
ydim = xyzdim(2);
dh = xyzmin(4);
plot(reshape(u_dns(floor((xyzdim(3)+1)/2),1:xyzdim(2),floor((xyzdim(1)+1)/2)),xyzdim(2),1)*Uref,ymin:dh:ymin+dh*(ydim-1),'r-o')
legend('delta_s','5\pi/4','6\pi/4','7\pi/4','8\pi/4','FSILBM3D')