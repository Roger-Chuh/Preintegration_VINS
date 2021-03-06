function [] = fnShowFeaturesnPoses_general(X_obj, nIMUdata, stitle)
%% Show the postions of features and poses according to the state vector x.
%% Input: 
% x: composed of nPoses poses, nPts 3D features and others. 
global PreIntegration_options

R_cell = [];
T_cell = [];
R_cell{1} = eye(3);
T_cell{1} = zeros(3,1);


pid = 1;
ratio = 0.2;
fh = figure; 
%set(gcf, 'Position', get(0, 'ScreenSize'));
title(stitle); hold on;
quiver3(T_cell{pid}(1), T_cell{1}(2), T_cell{1}(3), R_cell{pid}(1,1), R_cell{pid}(1,2), R_cell{pid}(1,3), ratio);
quiver3(T_cell{pid}(1), T_cell{1}(2), T_cell{1}(3), R_cell{pid}(2,1), R_cell{pid}(2,2), R_cell{pid}(2,3), ratio);
quiver3(T_cell{pid}(1), T_cell{1}(2), T_cell{1}(3), R_cell{pid}(3,1), R_cell{pid}(3,2), R_cell{pid}(3,3), ratio);

nMax = length( X_obj.pose )+1;   
nPts = length( X_obj.feature );

for pid=2:nMax
    R_cell{pid} = fn_RFromAngVec( X_obj.pose(pid-1).ang.val );
    T_cell{pid} = X_obj.pose(pid-1).trans.xyz;
    pc(:, pid) = T_cell{pid};
    figure(fh);
    quiver3( T_cell{pid}(1), T_cell{pid}(2), T_cell{pid}(3), R_cell{pid}(1,1), R_cell{pid}(1,2), R_cell{pid}(1,3), ratio);
    quiver3( T_cell{pid}(1), T_cell{pid}(2), T_cell{pid}(3), R_cell{pid}(2,1), R_cell{pid}(2,2), R_cell{pid}(2,3), ratio);
    quiver3( T_cell{pid}(1), T_cell{pid}(2), T_cell{pid}(3), R_cell{pid}(3,1), R_cell{pid}(3,2), R_cell{pid}(3,3), ratio);
    pause(0.1);
end


for pid=1:nPts
    p(:, pid) = X_obj.feature(pid).xyz;
end

figure(fh);
plot3(pc(1,:), pc(2,:), pc(3,:),'--o');%b

if(nPts > 0)
    plot3(p(1,:), p(2,:), p(3,:),'p');%r
end
grid on;
view(-45, 20);

nfontsize = 25;%22;%18;
sDir = 'xyz';
figure(); 
set(gcf, 'Position', get(0, 'ScreenSize'));

Vx = []; Vy = []; Vz= [];

for p=1:length(X_obj.velocity)
    Vx(end+1) = X_obj.velocity(p).xyz(1);
    Vy(end+1) = X_obj.velocity(p).xyz(2);
    Vz(end+1) = X_obj.velocity(p).xyz(3);
end
tv = [ Vx; Vy; Vz ];

for(i=1:3)
    subplot(3,1,i);hold all; 
    set(gca,'FontSize', nfontsize);
    set(get(gca,'XLabel'), 'FontSize', nfontsize);
    set(get(gca,'YLabel'), 'FontSize', nfontsize);
    plot((tv(i,:))', '*:'); 
    legend(sprintf('V%c', sDir(i)));    
end
subplot(3,1,1);
title('IMU Velocity');
    
    
