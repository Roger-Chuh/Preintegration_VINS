function [duvd] = fnuvd5xyz_dr(p3d, f, N)
%% Compute the gradients of u(x,y,z) and v(x,y,z) in one go.
% [u, v, 1]' = K * X: u = f * x / z + x0, v = f * y / z + y0
% du = f * dx / z - f * x / z^2 * dz, 
% dv = f / z * dy - f * y / z^2 * dz

x = (p3d(1,:))';
y = (p3d(2,:))';
z = (p3d(3,:))';
du = [f./z, zeros(N,1), -f*x./(z.*z)];% Nx3
dv = [zeros(N,1), f./z, -f*y./(z.*z)];
dd = repmat([0, 0, 1], N, 1);
duvd = [du'; dv'; dd'];%9xN
duvd = (reshape(duvd, 3, []))';%3Nx3
