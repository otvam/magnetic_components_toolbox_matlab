function run_src_dcx_1_single()
% Compute a SRC-DCX transformer design and display the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');
addpath(genpath('example_files'))
addpath('magnetic_toolbox')
add_path_mag_tb(false)

%% data
flag = get_spec_flag(); % converter specifications

param.f_sw = 100e3; % switching frequency
param.r_gap = 0.005; % relative air gap length
param.A_core = 600e-6; % core cross section
param.r_core = 2.0; % core aspect ratio
param.A_litz_lv = 10.0e-6; % wire copper area (LV side)
param.A_litz_hv = 2.5e-6;  % wire copper area (HV side)
param.n_winding_lv = 4;  % number of turns (LV side)
param.n_winding_hv = 16;  % number of turns (HV side)

%% fct for analyzing a transformer design
fct_solve = @(param) get_transformer_fct_solve(param, true);

%% run
data = get_sweep_single('SRC-DCX / single', flag, param, fct_solve);

end
