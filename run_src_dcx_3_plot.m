function run_src_dcx_3_plot()
% Plot the Pareto fronts of a SRC-DCX transformer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');
addpath(genpath('example_files'))
addpath('magnetic_toolbox')
add_path_mag_tb(false)

%% load
data = load('example_files/data_src_dcx.mat');

%% extract the data
fom = get_extract_fom(data);

%% define the variables for plotting
f_sw = struct('name', 'f_{sw} [kHz]', 'scale', 1e-3, 'value', fom.f_sw, 'lim', [50e3 200e3]);
rho = struct('name', 'rho [kW/dm3]', 'scale', 1e-6, 'value', fom.rho, 'lim', [10e6 100e6]);
eta = struct('name', 'eta [%]', 'scale', 1e2, 'value', fom.eta, 'lim', [0.994 0.999]);

%% plot the Pareto fronts
figure()
get_plot_front(rho, eta, f_sw);
title('SRC-DCX / eta-rho / volume')

end
