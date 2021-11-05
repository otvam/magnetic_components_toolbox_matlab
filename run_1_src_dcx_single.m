function run_1_src_dcx_single()
% Compute a SRC-DCX transformer design and display the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');
addpath('src_dcx_example')
addpath('magnetic_toolbox')
add_path_toolbox(false)

%% data
flag.P_bus = 5e3; % power rating
flag.V_bus = 400.0; % voltage of the feeder bus
flag.flow = 'hv_to_lv'; % power flow direction

param.f_sw = 100e3; % switching frequency
param.t_core = 15e-3; % thickness of the core (one limb)
param.z_core = 30e-3; % size of the core in the third dimension
param.n_litz_lv = 2500; % number of strands (LV side)
param.n_litz_hv = 500;  % number of strands (HV side)
param.n_lv = 6;  % number of turns (LV side)
param.n_hv = 24;  % number of turns (HV side)

%% fct for analyzing a transformer design
fct_solve = @(flag, param) get_transformer_fct_solve(flag, param, true);

%% run
data = get_sweep_single('SRC-DCX / single', flag, param, fct_solve);

end
