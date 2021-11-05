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
[n_sweep, param] = get_sweep_span(sweep);

% compute the designs
res_vec = get_parfor_res(n_sweep, param, flag, fct_solve);

% reorder the results
res = get_res_assemble(res_vec);

% end the simulation
duration = sim_end(name, tic);

% data
data.name = name;
data.sweep = sweep;
data.n_sweep = n_sweep;
data.flag = flag;
data.param = param;
data.res = res;
data.duration = duration;

end