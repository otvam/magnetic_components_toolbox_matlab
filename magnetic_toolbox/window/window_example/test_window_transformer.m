function test_window_transformer()
% Compute the leakage inductance, winding losses, and size of a transformer (core and winding head)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');

%% core
core.mu_core = 1000;
core.mu_domain = 1;
core.n_mirror = 1;
core.d_pole = 100e-3;
core.d_core = 2.0e-3;

%% window
window.d = 25e-3;
window.h = 60e-3;
window.z_mean = 20e-3;
window.z_top_left = 15e-3;
window.z_top_right = 25e-3;
window.z_bottom_left = 15e-3;
window.z_bottom_right = 25e-3;

%% winding
winding.lv.conductor = get_conductor_litz(100e-6, 2500, 0.5);
winding.lv.external = struct('type', 'left', 'd_shift', 3e-3, 'h_shift', 0.0);
winding.lv.internal = struct('n_winding', 6, 'n_par', 2, 't_layer', 1e-3, 't_turn', 0.5e-3, 'orientation', 'vertical');

winding.hv.conductor = get_conductor_litz(100e-6, 400, 0.5);
winding.hv.external = struct('type', 'right', 'd_shift', -3e-3, 'h_shift', 0.0);
winding.hv.internal = struct('n_winding', [12 12 12], 'n_par', 1, 't_layer', 1e-3, 't_turn', 0.5e-3, 'orientation', 'vertical');

%% stress
stress.f_vec = [10e3 20e3];
stress.T = 70;
stress.current.lv = [10 -20];
stress.current.hv = [4 -8];

%% create obj
window_geom_class = {@window_geom_core, @window_geom_core_head, @window_geom_head};
for i=1:length(window_geom_class)
    class.window_component_class = @window_component_transformer;
    class.window_geom_class = window_geom_class{i};
    test_obj(class, core, window, winding, stress);
end

end

function test_obj(class, core, window, winding, stress)
% Test a transformer window
%     - class - struct with the window
%     - core - struct with the window boundary condition
%     - window - struct with the window geometry
%     - winding - struct with the window winding definition
%     - stress - struct with the current stresses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

obj = window_class(class, core, window, winding);

V = obj.get_copper_volume();
V = obj.get_conductor_volume();
V = obj.get_window_volume();
m = obj.get_mass();
fig = obj.get_plot();

circuit = obj.get_circuit();
losses = obj.get_losses(stress);

end