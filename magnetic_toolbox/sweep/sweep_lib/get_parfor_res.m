function [is_valid_vec, res_vec, param_vec] = get_parfor_res(n_sweep, n_split, param, fct_solve)
% Simulate the results using a parallel computations
%     - n_sweep - number of combinations
%     - n_split - number of data per chunk
%     - param - struct with the parameter combinations
%     - fct_solve - handle for solving the problem
%     - is_valid_vec - vector with simulation validity information
%     - res_vec - cell of struct with the results
%     - param_vec - cell of struct with the parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('create chunks')
[n_chunk, idx_chunk] = get_chunk(n_sweep, n_split);

disp('solve problems')
is_valid_vec = cell(1, n_chunk);
res_vec = cell(1, n_chunk);
param_vec = cell(1, n_chunk);
for i=1:n_chunk
    disp(['    ' num2str(i) ' / ' num2str(n_chunk)])

    n_sweep_tmp = length(idx_chunk{i});
    param_tmp = get_res_slice(param, idx_chunk{i}, false);
    [is_valid_vec{i}, res_vec{i}, param_vec{i}] = get_for_res(n_sweep_tmp, param_tmp, fct_solve);
end

disp('combine results')
is_valid_vec = [is_valid_vec{:}];
res_vec = [res_vec{:}];
param_vec = [param_vec{:}];

end

function [is_valid_vec, res_vec, param_vec] = get_for_res(n_sweep, param, fct_solve)
% Simulate the results using a simple loop
%     - n_sweep - number of combinations
%     - param - struct with the parameter combinations
%     - fct_solve - handle for solving the problem
%     - res_vec - cell of struct with the results
%     - is_valid_vec - vector with simulation validity information
%     - sweep_vec - cell of struct with the sweeps
%     - param_vec - cell of struct with the parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

is_valid_vec = false(1, n_sweep);
res_vec = cell(1, n_sweep);
param_vec = cell(1, n_sweep);
parfor i=1:n_sweep
    [is_valid_vec(i), res_vec{i}, param_vec{i}] = get_solve_design(param, fct_solve, i);
end

end

function [is_valid, res, param] = get_solve_design(param, fct_solve, idx)
% Simulate the results using a parallel computations
%     - param - struct with the parameter combinations
%     - fct_solve - handle for solving the problem
%     - idx - scalar with the index of the combination to be computed
%     - is_valid - boolean indicating the validity on the results
%     - res - struct with the results
%     - param - struct with the selected parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

param = get_res_slice(param, idx, true);
[is_valid, res] = fct_solve(param);

if is_valid==false
    res = struct();
    param = struct();
end

end

