function [class, core, winding] = get_transformer_parameter(t_core, z_core, n_litz_lv, n_litz_hv, n_lv, n_hv)
% Get the tranformer data with the given paramters (check the validity of the design)
%     - t_core - thickness of the core (one limb)
%     - z_core - size of the core in the third dimension
%     - n_litz_lv - number of strands (LV side)
%     - n_litz_hv - number of strands (HV side)
%     - n_lv - number of turns (LV side)
%     - n_hv - number of turns (HV side)
%     - class - handler with the transformer type
%     - core - struct with the core data
%     - winding - struct with the winding data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% core specifications
core.t_core = t_core;
core.z_core = z_core;
core.d_gap = 100e-6;
core.r_window = 3e-3;
core.material = get_material_core();

% winding specifications
winding.lv.conductor = get_material_litz(100e-6, n_litz_lv, 0.5);
winding.lv.n_winding = n_lv;
winding.lv.n_par = 1;
winding.lv.t_layer = 1e-3;
winding.lv.t_turn = 0.5e-3;
winding.lv.t_core_x = 2e-3;
winding.lv.t_core_y = 2e-3;

winding.hv.conductor = get_material_litz(100e-6, n_litz_hv, 0.5);
if mod(n_hv, 2)==0
    winding.hv.n_winding = [n_hv./2 n_hv./2];
else
    winding.hv.n_winding = [(n_hv+1)./2 (n_hv-1)./2];
end
winding.hv.n_par = 1;
winding.hv.t_layer = 1e-3;
winding.hv.t_turn = 0.5e-3;
winding.hv.t_core_x = 2e-3;
winding.hv.t_core_y = 2e-3;

winding.t_winding_lv_hv = 2e-3;
winding.type_winding = 'lv_hv';
winding.d_window = NaN;
winding.h_window = NaN;
winding.n_mirror = 5;
winding.d_pole = 100e-3;

% magnetic component class to be used
class = @transformer_E_type;

end
