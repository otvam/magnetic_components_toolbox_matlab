function run_buck_dcdc_3_plot()
% Plot the Pareto fronts of a Buck DC-DC inductor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');
addpath(genpath('example_files'))
addpath('magnetic_toolbox')
add_path_mag_tb(false)

%% load
data = load('example_files/data_buck_dcdc.mat');

%% extract the data
[fom, fct_disp] = get_extract_fom(data);

%% define the variables for plotting
f_sw = struct('name', 'f_{sw} [kHz]', 'scale', 1e-3, 'value', fom.f_sw, 'lim', [50e3 200e3]);
rho = struct('name', 'rho [kW/dm3]', 'scale', 1e-6, 'value', fom.rho, 'lim', [10e6 100e6]);
eta = struct('name', 'eta [%]', 'scale', 1e2, 'value', fom.eta, 'lim', [0.994 0.999]);

%% plot the Pareto fronts
fig = figure();
sca = get_plot_front(rho, eta, f_sw);
get_plot_cursor(fig, sca, fom, fct_disp);
title('Buck DC-DC / eta-rho')

end
