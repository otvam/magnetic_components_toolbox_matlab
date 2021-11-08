function data = get_sweep_combine(name, flag, sweep, fct_solve)
% Run a simulation for multiple parameter combinations
%     - name - name of the simulation
%     - flag - struct with the parameters which are not part of the sweeps
%     - sweep - sweep - cell of struct with the parameter combination definition
%     - fct_solve - function handler for solving the problem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init the simulation
tic = sim_start(name);

% span the design parameters
[n_sweep, param] = get_sweep_span(flag, sweep);

% compute the designs
[is_valid_vec, res_vec, param_vec] = get_parfor_res(n_sweep, param, fct_solve);

% reorder the results
[n_valid, res] = get_res_assemble(is_valid_vec, res_vec, param_vec);

% end the simulation
duration = sim_end(name, tic);

% data
data.name = name;
data.flag = flag;
data.sweep = sweep;
data.n_sweep = n_sweep;
data.n_valid = n_valid;
data.param = param;
data.res = res;
data.duration = duration;

end