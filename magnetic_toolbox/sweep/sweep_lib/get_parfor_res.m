function [is_valid_vec, res_vec, param_vec] = get_parfor_res(n_sweep, param, fct_solve)
% Simulate the results using a parallel computations
%     - n_sweep - scalar with the number of combinations
%     - param - struct with the parameter combinations
%     - fct_solve - handle for solving the problem
%     - res_vec - cell of struct with the results
%     - is_valid_vec - vector with simulation validity information
%     - sweep_vec - cell of struct with the sweeps
%     - param_vec - cell of struct with the parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('solve problem')

parfor i=1:n_sweep
    disp(['    ' num2str(i) ' / ' num2str(n_sweep)])
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

param = get_extract_param(param, idx);
[is_valid, res] = fct_solve(param);

if is_valid==false
    res = struct();
    param = struct();
end

end


function param_idx = get_extract_param(param, idx)
% Select a specific parameter combination
%     - param - struct with the parameter combinations
%     - idx - scalar with the index of the combination to be computed
%     - param_idx - struct with the select parameter combination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

field = fieldnames(param);
param_idx = struct();
for i=1:length(field)
    value = param.(field{i});
    if isnumeric(value)||islogical(value)
        param_idx.(field{i}) = value(idx);
    elseif iscell(value)
        param_idx.(field{i}) = value{idx};
    else
        error('invalid type');
    end
end

end