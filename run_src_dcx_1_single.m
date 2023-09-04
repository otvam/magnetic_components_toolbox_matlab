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
param.A_core = 750e-6; % core cross section
param.r_core = 3.0; % core aspect ratio
param.A_litz_lv = 14.0e-6; % wire copper area (LV side)
param.A_litz_hv = 3.0e-6;  % wire copper area (HV side)
param.n_winding_lv = 3;  % number of turns (LV side)
param.n_winding_hv = 12;  % number of turns (HV side)

%% fct for analyzing a transformer design
fct_solve = @(param) get_transformer_fct_solve(param, true);

%% run
data = get_sweep_single('SRC-DCX / single', flag, param, fct_solve);

end

function txt = get_disp(fom)
% Plot the a Pareto front
%     - fom - struct with the figures of merit
%     - txt - cell with the data cursor content
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

txt = {};
txt{end+1} = sprintf('f_sw = %.3f kHz', 1e-3.*fom.f_sw);
txt{end+1} = sprintf('rho = %.3f kW/dm3', 1e-6.*fom.rho);
txt{end+1} = sprintf('eta = %.3f %%', 1e2.*fom.eta);

end