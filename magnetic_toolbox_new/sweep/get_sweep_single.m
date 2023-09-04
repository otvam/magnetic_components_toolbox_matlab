function data = get_sweep_single(name, flag, sweep, fct_solve)
% Run a simulation for a single parameter combination
%     - name - name of the simulation
%     - flag - struct with the parameters which are not part of the sweeps
%     - sweep - struct with the parameter definition (single combination)
%     - fct_solve - function handler for solving the problem
%     - data - struct with the simulation data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init the simulation
tic = sim_start(name);

% merge data
disp('create parameters')

field = [fieldnames(flag);fieldnames(sweep)];
value = [struct2cell(flag); struct2cell(sweep)];
param = cell2struct(value, field);

% solve the design
disp('solve problem')

[is_valid, res] = fct_solve(param);

n_sweep = 1;
n_valid = 1;

% end the simulation
duration = sim_end(name, tic);

% data
data.name = name;
data.flag = flag;
data.sweep = sweep;
data.n_sweep = n_sweep;
data.n_valid = n_valid;
data.param = param;
data.is_valid = is_valid;
data.res = res;
data.duration = duration;

end