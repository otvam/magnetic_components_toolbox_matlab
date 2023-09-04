function test_mirroring_inductor_core()
% Test the mirroring method for an gapped inductor core (compare with FEM)
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
bc.x_min = -10e-3;
bc.x_max = 10e-3;
bc.y_min = -25e-3;
bc.y_max = 25e-3;

conductor.y = [linspace(-10e-3, 10e-3, 4) 0.0 0.0];
conductor.x = [-3e-3.*ones(1,4) -10e-3 10e-3];
conductor.d_c = [4e-3.*ones(1,4) 0.0 0.0];
conductor.n_conductor = 6;

I_vec = [5.*ones(1,4) -10.0 -10.0].';

%% obj
obj = mirroring_method(bc, conductor);

%% field
y =  conductor.y(1:end-2);

H_mirror = obj.get_H_norm_conductor(I_vec);
H_mirror = H_mirror(1:end-2);

H_fem = [43.10098359010993 178.76805769542216 178.8043667302538 43.09237638382891];

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