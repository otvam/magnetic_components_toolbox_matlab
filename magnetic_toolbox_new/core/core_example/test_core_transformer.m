function test_core_transformer()
% Compute the magnetizing inductance, core losses, and size of a transformer (E and C cores)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');

%% material
material = get_material_N87();

%% geom
geom.d_window = 25e-3;
geom.h_window = 60e-3;
geom.t_core = 20e-3;
geom.z_core = 20e-3;
geom.d_gap = 1e-3;

%% winding
winding.lv = 10;
winding.hv = 20;

%% stress
stress.d_vec = [0.25 0.75];
stress.f = 50e3;
stress.T = 70;
stress.current.lv = [10 -20];
stress.current.hv = [4 -8];

%% create obj
class.core_component_class = @core_component_transformer;
class.core_geom_class = @core_geom_C_type;
test_obj(class, material, geom, winding, stress);

class.core_component_class = @core_component_transformer;
class.core_geom_class = @core_geom_E_type;
test_obj(class, material, geom, winding, stress);

end

function test_obj(class, material, geom, winding, stress)
% Test a transformer core
%     - class - struct with the core type
%     - material - struct with the core material
%     - geom - struct with the core geometry
%     - winding - struct with the winding definition
%     - stress - struct with the current stresses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

obj = core_class(class, material, geom, winding);

V = obj.get_core_volume();
V = obj.get_box_volume();
m = obj.get_mass();
fig = obj.get_plot();

circuit = obj.get_circuit();
losses = obj.get_losses(stress);

end