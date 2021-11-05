function test_mirroring_inductor_head()
% Test the mirroring method for an gapped inductor winding head (compare with FEM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');

%% param
bc.type = 'x';
bc.mu_core = 5;
bc.mu_domain = 1;
bc.d_pole = 1.0;

bc.z_size = 1.0;
bc.x = -30e-3;

conductor.y = [linspace(-10e-3, 10e-3, 4) 0.0];
conductor.x = [-43e-3.*ones(1,4) -30e-3];
conductor.d_c = [4e-3.*ones(1,4) 0.0];
conductor.n_conductor = 5;

I_vec = [5.*ones(1,4) -10.0].';

%% obj
obj = mirroring_method(bc, conductor);

%% field
y =  conductor.y(1:end-1);

H_mirror = obj.get_H_norm_conductor(I_vec);
H_mirror = H_mirror(1:end-1);

H_fem = [145.29681018836334 121.0448991487139 121.0366519214935 145.28815347072384];

disp(['H_mirror / ' mat2str(H_mirror)])
disp(['H_fem / ' mat2str(H_fem)])

%% plot
figure()
plot(1e3.*y, H_fem, 'r')
hold('on');
plot(1e3.*y, H_mirror, '--b')
xlabel('y [mm]')
ylabel('H [A/m]')
title('LV field')

end