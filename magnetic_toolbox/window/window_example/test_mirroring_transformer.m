function test_mirroring_transformer()
% Test the mirroring method for a transformer winding window (compare with FEM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');

%% param
bc.type = 'xy';
bc.mu_core = 5;
bc.mu_domain = 1;
bc.n_mirror = 5;
bc.d_pole = 1.0;

bc.z_size = 1.0;
bc.x_min = -7.5e-3;
bc.x_max = 7.5e-3;
bc.y_min = -15e-3;
bc.y_max = 15e-3;

y_lv = linspace(-10e-3, 10e-3, 4);
x_lv = -3e-3.*ones(1,4);
d_c_lv = 4e-3.*ones(1,4);
I_lv = 5.*ones(1,4);

y_hv = linspace(-12e-3, 12e-3, 8);
x_hv = 3e-3.*ones(1,8);
r_hv = 2e-3.*ones(1,8);
I_hv = -2.5.*ones(1,8);

conductor.x = [x_lv x_hv];
conductor.y = [y_lv y_hv];
conductor.d_c = [d_c_lv r_hv];
conductor.n_conductor = 4+8;

idx_lv = logical([ones(1,4), zeros(1,8)]);
idx_hv = logical([zeros(1,4), ones(1,8)]);

I_vec = [I_lv I_hv].';

%% obj
obj = mirroring_method(bc, conductor);

%% field
H_mirror = obj.get_H_norm_conductor(I_vec);
H_fem_lv = [329.1910515106164 354.49456151297335 354.49465529324493 329.1929824930109];
H_fem_hv = [312.7347963690875 336.78671237401153 351.44643455664885 358.50563115674737 358.4996092274907 351.44127306569345 336.7815537151253 312.76549027585213];
H_fem = [H_fem_lv H_fem_hv];

disp(['H_mirror / ' mat2str(H_mirror)])
disp(['H_fem / ' mat2str(H_fem)])

%% plot field inside conductor
figure()

subplot(2,1,1)
plot(1e3.*y_lv, H_fem_lv, 'r')
hold('on');
plot(1e3.*y_lv, H_mirror(idx_lv), '--b')
xlabel('y [mm]')
ylabel('H [A/m]')
title('LV field')

subplot(2,1,2)
plot(1e3.*y_hv, H_fem_hv, 'r')
hold('on');
plot(1e3.*y_hv, H_mirror(idx_hv), '--b')
xlabel('y [mm]')
ylabel('H [A/m]')
title('HV field')

%% inductance
L = obj.get_L();

figure();
imagesc(1:12, 1:12, 1e6.*L);
hold('on');
plot([4.5 4.5], [0.5 12.5], 'w')
plot([0.5 12.5], [4.5 4.5], 'w')
xlabel('conductor [#]')
ylabel('conductor [#]')
set(gca,'xticklabel',[])
set(gca,'yticklabel',[])
colorbar();
title('Inductance Matrix [uH]')

%% energy
E_mirror = obj.get_E(I_vec);
E_fem = 4.7052688052270205E-5;

disp(['E_mirror / ' mat2str(E_mirror)])
disp(['E_fem / ' mat2str(E_fem)])

%% plot the magnetic field
x = linspace(bc.x_min, bc.x_max, 100);
y = linspace(bc.y_min, bc.y_max, 100);

[x_vec, y_vec] = meshgrid(x, y);
x_vec = x_vec(:).';
y_vec = y_vec(:).';

H = obj.get_H_norm_position(x_vec, y_vec, I_vec);
H_mat = reshape(H, length(y), length(x));

figure();
contourf(1e3.*x, 1e3.*y, H_mat, 200, 'edgecolor','none');
hold('on');
for i=1:conductor.n_conductor
    plot_conductor(1e3.*conductor.x(i), 1e3.*conductor.y(i), 1e3.*conductor.d_c(i), 100);
end
axis ('equal')
xlabel('x [mm]')
ylabel('y [mm]')
colorbar();
title('H [A/m]')

end

function plot_conductor(x, y, d_c, n)
% Plot a conductor
%     - x - x position
%     - y - y position
%     - d_c - diameter
%     - n - number of points for the discretization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

phi = linspace(0.0, 2.0.*pi, n);
x_vec = x+(d_c./2.0).*sin(phi);
y_vec = y+(d_c./2.0).*cos(phi);

plot(x_vec, y_vec, 'w');

end