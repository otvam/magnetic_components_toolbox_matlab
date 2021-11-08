function run_src_dcx_2_combine()
% Run a Pareto optimization of a SRC-DCX transformer and store the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');
addpath(genpath('example_files'))
addpath('magnetic_toolbox')
add_path_mag_tb(false)

%% data
flag = get_spec_flag(); % converter specifications

sweep = {};
sweep{end+1} = struct('f_sw', logspace(log10(50e3), log10(250e3), 10)); % switching frequency
sweep{end+1} = struct('r_gap', 0.005); % relative air gap length
sweep{end+1} = struct('A_core', logspace(log10(25e-6), log10(1000e-6), 15)); % core cross section
sweep{end+1} = struct('r_core', logspace(log10(1.0), log10(3.0), 6)); % core aspect ratio
sweep{end+1} = struct('A_litz_lv', logspace(log10(5e-6), log10(20e-6), 8)); % wire copper area (LV side)
sweep{end+1} = struct('A_litz_hv', logspace(log10(1.5e-6), log10(5e-6), 8)); % wire copper area (HV side)
sweep{end+1} = struct('n_winding_lv', 2:10, 'n_winding_hv', 8:4:40); % number of turns (LV and MV side) / 1:4 ratio

%% fct for analyzing a transformer design
fct_solve = @(param) get_transformer_fct_solve(param, false);

%% run
data = get_sweep_combine('SRC-DCX / combine', flag, sweep, fct_solve);

%% save
save('example_files/data_src_dcx.mat', '-struct', 'data', '-v7.3');

end