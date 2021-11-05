function res_vec = get_parfor_res(n_sweep, param, flag, fct_solve)
% Simulate the results using a parallel computations
%     - n_sweep - scalar with the number of combinations
%     - param - struct with the parameter combinations
%     - flag - struct with the parameters which are not part of the sweeps
%     - fct_solve - handle for solving the problem
%     - res_vec - cell of struct with the results
%     - sweep_vec - cell of struct with the sweeps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('solve')

parfor i=1:n_sweep
    disp(['    ' num2str(i) ' / ' num2str(n_sweep)])
    res_vec{i} = get_solve_design(param, flag, fct_solve, i);
end

end

function res = get_solve_design(param, flag, fct_solve, idx)
% Simulate the results using a parallel computations
%     - param - struct with the parameter combinations
%     - flag - struct with the parameters which are not part of the sweeps
%     - fct_solve - handle for solving the problem
%     - idx - scalar with the index of the combination to be computed
%     - res - struct with the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

param_idx = get_extract_param(param, idx);
res = fct_solve(flag, param_idx);

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