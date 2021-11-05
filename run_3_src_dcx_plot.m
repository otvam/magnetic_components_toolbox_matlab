function run_3_src_dcx_plot()
% Plot the Pareto fronts of a SRC-DCX transformer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');

%% load
data = load('src_dcx_example/src_dcx_data.mat');

%% extract the data
fom = extract_fom(data);

%% define the variables for plotting
f_sw = struct('name', 'f_{sw} [kHz]', 'scale', 1e-3, 'value', fom.f_sw);
rho_volume = struct('name', 'rho_{volume} [kW/dm3]', 'scale', 1e-6, 'value', fom.rho_volume);
rho_mass = struct('name', 'rho_{mass} [kW/kg]', 'scale', 1e-3, 'value', fom.rho_mass);
eta = struct('name', 'eta [%]', 'scale', 1e2, 'value', fom.eta);

%% plot the Pareto fronts
figure()
plot_front(rho_volume, eta, f_sw);
title('eta-rho / volume')

figure()
plot_front(rho_mass, eta, f_sw);
title('eta-rho / mass')

end

function fom = extract_fom(data)
% Extract the figures of merit from the dataset
%     - data - struct with the solution data
%     - fom - struct with the figures of merit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract the variables
P_bus = data.flag.P_bus;
f_sw = data.param.f_sw;
V = data.res.V;
m = data.res.m;
P_tot = data.res.losses.P;
is_valid_circuit = data.res.circuit.is_valid;
is_valid_losses = data.res.losses.is_valid;

% get the figures of merit
eta = 1.0-(P_tot./P_bus);
rho_volume = P_bus./V;
rho_mass = P_bus./m;

% filter invalid designs
is_valid = is_valid_circuit&is_valid_losses;
is_valid = is_valid&(eta>0.995);
is_valid = is_valid&(rho_volume>5e6);
is_valid = is_valid&(rho_mass>3e3);

% count the valid designs
disp('plot')
disp(['    n_sweep = ' num2str(length(is_valid))])
disp(['    n_valid = ' num2str(nnz(is_valid))])

% assign the valid designs
fom.f_sw = f_sw(is_valid);
fom.rho_volume = rho_volume(is_valid);
fom.rho_mass = rho_mass(is_valid);
fom.eta = eta(is_valid);

end

function plot_front(x_axis, y_axis, c_axis)
% Plot the a Pareto front
%     - x_axis - struct with the x axis data
%     - y_axis - struct with the y axis data
%     - c_axis - struct with the color axis data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract and scale the data
x = x_axis.value.*x_axis.scale;
y = y_axis.value.*y_axis.scale;
c = c_axis.value.*c_axis.scale;

% random order
idx = randperm(length(c));
c = c(idx);
x = x(idx);
y = y(idx);

% get the concex hull
idx = convhull(x, y);
x_hull = x(idx);
y_hull = y(idx);

% plot the data
scatter(x, y, 30, c, 'filled')
hold('on')
plot(x_hull, y_hull, 'r', 'LineWidth', 2)
grid('on')
xlabel(x_axis.name)
ylabel(y_axis.name)
h = colorbar();
set(get(h, 'label'), 'string', c_axis.name);

end