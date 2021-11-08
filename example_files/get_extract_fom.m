function fom = get_extract_fom(data)
% Extract the figures of merit from the dataset
%     - data - struct with the solution data
%     - fom - struct with the figures of merit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract the variables
n_sweep = data.n_sweep;
n_valid = data.n_valid;
P_trf = data.param.P_trf;
f_sw = data.param.f_sw;
V = data.res.V;
m = data.res.m;
P_losses = data.res.losses.P;
is_valid_circuit = data.res.circuit.is_valid;
is_valid_losses = data.res.losses.is_valid;

% get the figures of merit
eta = 1.0-(P_losses./P_trf);
rho = P_trf./V;
gamma = P_trf./m;

% very simple thermal stress
l_box = V.^(1/3);
A_box = 6.*l_box.^2;
h_box = P_losses./A_box;

% filter invalid designs
is_filter = is_valid_circuit&is_valid_losses;
is_filter = is_filter&(eta>0.994);
is_filter = is_filter&(rho>10e6);
is_filter = is_filter&(gamma>2e3);
is_filter = is_filter&(h_box<0.2e4);

% count the valid designs
disp('plot')
disp(['    n_sweep = ' num2str(n_sweep)])
disp(['    n_valid = ' num2str(n_valid)])
disp(['    n_valid = ' num2str(nnz(is_filter))])

% assign the valid designs
fom.f_sw = f_sw(is_filter);
fom.rho = rho(is_filter);
fom.eta = eta(is_filter);

end
