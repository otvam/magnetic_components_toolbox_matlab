function [fom, fct_disp] = get_extract_fom(data)
% Extract the figures of merit from the dataset
%     - data - struct with the solution data
%     - fom - struct with the figures of merit
%     - fct_disp - function handle for displaying the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract the variables
n_sweep = data.n_sweep;
n_valid = data.n_valid;
P_trf = data.param.P_trf;
f_sw = data.param.f_sw;
V = data.res.V;
A = data.res.A;
m = data.res.m;
P_losses = data.res.losses.P;
is_valid_circuit = data.res.circuit.is_valid;
is_valid_losses = data.res.losses.is_valid;

% get the figures of merit
eta = 1.0-(P_losses./P_trf);
rho = P_trf./V;
gamma = P_trf./m;

% very simple thermal stress
cooling = P_losses./A;

% filter invalid designs
is_filter = is_valid_circuit&is_valid_losses;
is_filter = is_filter&(eta>0.994);
is_filter = is_filter&(rho>10e6);
is_filter = is_filter&(gamma>2e3);
is_filter = is_filter&(cooling<0.2e4);

% count
n_plot = nnz(is_filter);

% count the valid designs
fprintf('================================\n')
disp(['n_sweep = ' num2str(n_sweep)])
disp(['n_valid = ' num2str(n_valid)])
disp(['n_plot = ' num2str(n_plot)])
fprintf('================================\n')

% assign the valid designs
fom.f_sw = f_sw(is_filter);
fom.rho = rho(is_filter);
fom.eta = eta(is_filter);
fom.gamma = gamma(is_filter);
fom.cooling = cooling(is_filter);

% random permutation
idx = randperm(n_plot);
fom = get_res_slice(fom, idx, false);

% define the data cursor
fct_disp = @(fom) get_disp(fom);

end

function txt = get_disp(fom)
% Plot the a Pareto front
%     - fom - struct with the figures of merit
%     - txt - cell with the data cursor content
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

txt = {};
txt{end+1} = sprintf('f_sw = %.3f kHz', 1e-3.*fom.f_sw);
txt{end+1} = sprintf('eta = %.3f %%', 1e2.*fom.eta);
txt{end+1} = sprintf('rho = %.3f kW/dm3', 1e-6.*fom.rho);
txt{end+1} = sprintf('gamma = %.3f kW/kg', 1e-3.*fom.gamma);
txt{end+1} = sprintf('cooling = %.3f W/cm3', 1e-4.*fom.cooling);

end
