function test_component_transformer()
% Compute the equivalent circuit, losses, and size of a transformer (E-core and C-core)
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
winding.lv.conductor = get_conductor_litz(100e-6, 2500, 0.5);
winding.lv.n_winding = 6;
winding.lv.n_par = 1;
winding.lv.t_layer = 1e-3;
winding.lv.t_turn = 0.5e-3;
winding.lv.t_core_x = 3e-3;
winding.lv.t_core_y = 3e-3;

winding.hv.conductor = get_conductor_litz(100e-6, 400, 0.5);
winding.hv.n_winding = [13 12 13];
winding.hv.n_par = 1;
winding.hv.t_layer = 1e-3;
winding.hv.t_turn = 0.5e-3;
winding.hv.t_core_x = 3e-3;
winding.hv.t_core_y = 3e-3;

winding.t_winding_lv_hv = 5e-3;
winding.type_winding = 'lv_hv';
winding.d_window = NaN;
winding.h_window = NaN;
winding.n_mirror = 5;
winding.d_pole = 100e-3;

%% stress
stress.window.f_vec = [10e3 20e3];
stress.window.T = 70;
stress.window.current.lv = [10 -20];
stress.window.current.hv = [4 -8];

stress.core.d_vec = [0.25 0.75];
stress.core.f = 50e3;
stress.core.T = 70;
stress.core.current.lv = [10 -20];
stress.core.current.hv = [4 -8];

%% create obj
test_obj(@transformer_C_type, core, winding, stress);
test_obj(@transformer_E_type, core, winding, stress);

end

function test_obj(class, core, winding, stress)
% Test a transformer
%     - class - type of the transformer
%     - core - struct with the core definition
%     - winding - struct with the winding definition
%     - stress - struct with the current stresses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

obj = component_class(class, core, winding);

type = obj.get_type();
V = obj.get_active_volume();
V = obj.get_box_volume();
A = obj.get_box_area();
m = obj.get_box_mass();
m = obj.get_active_mass();
fig = obj.get_plot();

circuit = obj.get_circuit();
losses = obj.get_losses(stress);

end