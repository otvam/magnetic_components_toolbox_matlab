function run_2_src_dcx_combine()
% Run a Pareto optimization of a SRC-DCX transformer and store the results
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

sweep = {};
sweep{end+1} = struct('f_sw', 1e3.*(50:25:200)); % switching frequency
sweep{end+1} = struct('t_core', 1e-3.*(10:2.5:30)); % thickness of the core (one limb)
sweep{end+1} = struct('z_core', 1e-3.*(10:10:60)); % size of the core in the third dimension
sweep{end+1} = struct('n_litz_lv', 1500:250:2500); % number of strands (LV side)
sweep{end+1} = struct('n_litz_hv', 350:50:500); % number of strands (HV side)
sweep{end+1} = struct('n_lv', 3:8, 'n_hv', 12:4:32); % number of turns (LV and MV side) / 1:4 ratio

%% fct for analyzing a transformer design
fct_solve = @(flag, sweep) get_transformer_fct_solve(flag, sweep, false);

%% run
data = get_sweep_combine('SRC-DCX / single', flag, sweep, fct_solve);

%% save
save('src_dcx_example/src_dcx_data.mat', '-struct', 'data', '-v7.3');

end