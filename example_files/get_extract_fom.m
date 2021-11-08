function fom = get_extract_fom(data)
% Extract the figures of merit from the dataset
%     - data - struct with the solution data
%     - fom - struct with the figures of merit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract the variables
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
is_valid = is_valid_circuit&is_valid_losses;
is_valid = is_valid&(eta>0.994);
is_valid = is_valid&(rho>10e6);
is_valid = is_valid&(gamma>2e3);
is_valid = is_valid&(h_box<0.2e4);

% count the valid designs
disp('plot')
disp(['    n_sweep = ' num2str(length(is_valid))])
disp(['    n_valid = ' num2str(nnz(is_valid))])

% assign the valid designs
fom.f_sw = f_sw(is_valid);
fom.rho = rho(is_valid);
fom.eta = eta(is_valid);

end
