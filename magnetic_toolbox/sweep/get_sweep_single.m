function data = get_sweep_single(name, flag, param, fct_solve)
% Run a simulation for a single parameter combination
%     - name - name of the simulation
%     - flag - struct with the parameters which are not part of the sweeps
%     - param - struct with the parameter definition (single combination)
%     - fct_solve - function handler for solving the problem
%     - data - struct with the simulation data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init the simulation
tic = sim_start(name);

% solve the design
disp('solve')

res = fct_solve(flag, param);

% end the simulation
duration = sim_end(name, tic);

% data
data.name = name;
data.flag = flag;
data.param = param;
data.res = res;
data.duration = duration;

end