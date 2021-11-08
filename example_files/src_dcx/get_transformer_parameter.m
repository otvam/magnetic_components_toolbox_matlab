function [class, core, winding] = get_transformer_parameter(param)
% Get the tranformer data with the given paramters (check the validity of the design)
%     - param - struct of scalar with parameter sweeps
%     - class - handler with the transformer type
%     - core - struct with the core data
%     - winding - struct with the winding data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract
r_gap = param.r_gap;
A_core = param.A_core;
r_core = param.r_core;
A_litz_lv = param.A_litz_lv;
A_litz_hv = param.A_litz_hv;
n_winding_lv = param.n_winding_lv;
n_winding_hv = param.n_winding_hv;

% core geometry
t_core = sqrt(A_core./r_core);
z_core = sqrt(A_core.*r_core);
d_gap = r_gap.*sqrt(A_core);

% core specifications
core.t_core = t_core;
core.z_core = z_core;
core.d_gap = d_gap;
core.r_window = 0.2.*t_core;
core.material = get_material_core();

% split the winding into two layers (HV side)
if mod(n_winding_hv, 2)==0
    n_winding_hv = [n_winding_hv./2 n_winding_hv./2];
else
    n_winding_hv = [(n_winding_hv+1)./2 (n_winding_hv-1)./2];
end

% winding specifications
winding.lv.conductor = get_material_litz(100e-6, A_litz_lv, 0.5);
winding.lv.n_winding = n_winding_lv;
winding.lv.n_par = 1;
winding.lv.t_layer = 1e-3;
winding.lv.t_turn = 0.5e-3;
winding.lv.t_core_x = 2e-3;
winding.lv.t_core_y = 2e-3;

winding.hv.conductor = get_material_litz(100e-6, A_litz_hv, 0.5);
winding.hv.n_winding = n_winding_hv;
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
