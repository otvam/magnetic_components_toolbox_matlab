function run_buck_dcdc_1_single()
% Compute a Buck DC-DC inductor design and display the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');
addpath(genpath('example_files'))
addpath('magnetic_toolbox')
add_path_mag_tb(false)

%% data
flag = get_spec_flag(); % converter specifications

param.f_sw = 175e3; % switching frequency
param.r_gap = 0.1; % relative air gap length
param.A_core = 600e-6; % core cross section
param.r_core = 3.0; % core aspect ratio
param.A_litz = 11e-6; % wire copper area
param.n_winding = 12;  % number of turns

%% fct for analyzing an inductor design
fct_solve = @(param) get_inductor_fct_solve(param, true);

%% run
data = get_sweep_single('Buck DC-DC / single', flag, param, fct_solve);

end
