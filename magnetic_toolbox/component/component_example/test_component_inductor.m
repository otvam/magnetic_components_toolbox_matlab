function test_component_inductor()
% Compute the equivalent circuit, losses, and size of an inductor (E-core, C-core)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');

%% core
core.t_core = 20e-3;
core.z_core = 20e-3;
core.d_gap = 1e-3;
core.r_window = 10e-3;
core.material = get_material_N87();

%% winding
winding.winding.conductor = get_conductor_litz(100e-6, 2500, 0.5);
winding.winding.n_winding = 6;
winding.winding.n_par = 2;
winding.winding.t_layer = 1e-3;
winding.winding.t_turn = 0.5e-3;
winding.winding.t_core_x = 2e-3;
winding.winding.t_core_y = 2e-3;

winding.d_window = 12e-3;
winding.h_window = 50e-3;
winding.n_mirror = 5;
winding.d_pole = 100e-3;

%% stress
stress.window.f_vec = [10e3 20e3];
stress.window.T = 70;
stress.window.current = [10 -20];

stress.core.d_vec = [0.25 0.75];
stress.core.f = 50e3;
stress.core.T = 70;
stress.core.current = [10 -20];

%% create obj
test_obj(@inductor_C_type, core, winding, stress);
test_obj(@inductor_E_type, core, winding, stress);

end

function test_obj(class, core, winding, stress)
% Test an inductor
%     - class - type of the inductor
%     - core - struct with the core definition
%     - winding - struct with the winding definition
%     - stress - struct with the current stresses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

obj = component_class(class, core, winding);

type = obj.get_type();
V = obj.get_active_volume();
V = obj.get_box_volume();
m = obj.get_box_mass();
m = obj.get_active_mass();
fig = obj.get_plot();

circuit = obj.get_circuit();
losses = obj.get_losses(stress);

end