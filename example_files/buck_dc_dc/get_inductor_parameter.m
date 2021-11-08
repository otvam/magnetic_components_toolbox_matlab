function [class, core, winding] = get_inductor_parameter(param)
% Get the tranformer data with the given paramters (check the validity of the design)
%     - param - struct of scalar with parameter sweeps
%     - class - handler with the inductor type
%     - core - struct with the core data
%     - winding - struct with the winding data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract
r_gap = param.r_gap;
A_core = param.A_core;
r_core = param.r_core;
A_litz = param.A_litz;
n_winding = param.n_winding;

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

% split the winding into two layers
if mod(n_winding, 2)==0
    n_winding = [n_winding./2 n_winding./2];
else
    n_winding = [(n_winding+1)./2 (n_winding-1)./2];
end

% winding specifications
winding.winding.conductor = get_material_litz(100e-6, A_litz, 0.5);
winding.winding.n_winding = n_winding;
winding.winding.n_par = 1;
winding.winding.t_layer = 1e-3;
winding.winding.t_turn = 0.5e-3;
winding.winding.t_core_x = 2e-3;
winding.winding.t_core_y = 2e-3;

winding.d_window = NaN;
winding.h_window = NaN;
winding.n_mirror = 5;
winding.d_pole = 100e-3;

% magnetic component class to be used
class = @inductor_E_type;

end
