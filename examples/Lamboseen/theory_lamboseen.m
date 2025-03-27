%% https://doi.org/10.1063/1.3220173
clear
clc
%% LBM parameters setting
dh = 0.025d0;
Lref = 1d0;
Uref = 0.1d0;
gammaref = 0.1d0;
w_init = gammaref/2/pi;
%% theory parameters setting
x  = -5:0.01:5;
y  = 0d0;
z  = 0d0;
Re = 2400d0;
gamma = 1d0;
t  = 18d0;%6*pi/gamma;
nu = gamma/Re;
a0 = 0.1d0;
a  = sqrt(a0*a0+4*nu*t);
x0 = 0.5d0;
%% read file
LBMt = 180;
LBMt = LBMt*1000;
folder = ' casePath /FSILBM3D_example/examples/Lamboseen/DatFlow/';
    filename = sprintf('%s%s%s%s',folder,'Flow0',num2str(LBMt,'%07.0f'),'00_b001');
    fileID = fopen(filename,"rb");
    if fileID == -1
        error('no file')
    end
    xyzdim = fread(fileID,4,'int32');
    xyzmin = fread(fileID,4,'float64');
    u_data = fread(fileID,xyzdim(1)*xyzdim(2)*xyzdim(3),'float32');
    u_dns = reshape(u_data,[xyzdim(3),xyzdim(2),xyzdim(1)])*Uref;
    v_data = fread(fileID,xyzdim(1)*xyzdim(2)*xyzdim(3),'float32');
    v_dns = reshape(v_data,[xyzdim(3),xyzdim(2),xyzdim(1)])*Uref;
    w_data = fread(fileID,xyzdim(1)*xyzdim(2)*xyzdim(3),'float32');
    w_dns = reshape(w_data,[xyzdim(3),xyzdim(2),xyzdim(1)])*Uref;
    fclose(fileID);
%% LBM vorticity
oy =    reshape((u_dns(floor((xyzdim(3)+1)/2)+1,3,2:xyzdim(1)-1) ...
                -u_dns(floor((xyzdim(3)+1)/2)-1,3,2:xyzdim(1)-1)) ...
                /(dh*2),xyzdim(1)-2,1);
oy = oy-reshape((w_dns(floor((xyzdim(3)+1)/2)  ,3,3:xyzdim(1)) ...
                -w_dns(floor((xyzdim(3)+1)/2)  ,3,1:xyzdim(1)-2)) ...
                /(dh*2),xyzdim(1)-2,1);
%% theory velocity and vorticity
u(length(x),length(y),length(z)) = 0d0;
v(length(x),length(y),length(z)) = 0d0;
w(length(x),length(y),length(z)) = 0d0;
omega(length(x),length(y),length(z)) = 0d0;
for k = 1:length(z)
     for j = 1:length(y)
        for i = 1:length(x)
           r1 = sqrt((x(i) - x0)^2 + z(k)^2);
           theta1 = atan2(z(k), x(i) - x0);
           r2 = sqrt((x(i) + x0)^2 + z(k)^2);
           theta2 = atan2(z(k), x(i) + x0);
           if (r1 > 0.0001)
              v_theta1 = (gamma / (2 * pi * r1)) * (1.0d0 - exp(-r1^2 / (a^2)));
              omega_y1 = (gamma / (pi * a^2)) * exp(-r1^2 / (a^2));
           else
                 v_theta1 = 0.0d0;
                 omega_y1 = gamma / (pi * a^2);
           end
           if (r2 > 0.0001)
                 v_theta2 = (-gamma / (2 * pi * r2)) * (1.0d0 - exp(-r2^2 / (a^2)));
                 omega_y2 = (-gamma / (pi * a^2)) * exp(-r2^2 / (a^2));
           else
                 v_theta2 = 0.0d0;
                 omega_y2 = -gamma / (pi * a^2);
           end
           u(i, j, k) = -v_theta1 * sin(theta1)+(-v_theta2 * sin(theta2))+u(i, j, k);
           v(i, j, k) = 0+v(i, j, k);
           w(i, j, k) = v_theta1 * cos(theta1)+(v_theta2 * cos(theta2))+w(i, j, k);
           omega(i, j, k) = omega_y1 + omega_y2 + omega(i, j, k);
       end
    end
end
%% plot
hold on
plot(x,w(:,1,1)/(Lref*gamma),'k--',-5+dh:dh:5-dh,(reshape(w_dns(floor((xyzdim(3)+1)/2),3,2:xyzdim(1)-1),xyzdim(1)-2,1)-w_init)/(Lref*gammaref),'r')%velocity w
plot(x,omega(:,1,1)/gamma,'k--',-5+dh:dh:5-dh,-oy/gammaref,'b')%vorticity y
xlabel('x')
ylabel('w & \omega_y')
legend('theory-w','LBM-w','theory-\omega_y','LBM-\omega_y')