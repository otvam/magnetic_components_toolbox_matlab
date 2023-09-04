function [n_valid, res, param] = get_res_assemble(is_valid_vec, res_vec, param_vec)
% Reorder the results (from cell of struct to struct of arrays)
%     - is_valid_vec - vector with simulation validity information
%     - res_vec - cell of struct with the results
%     - param_vec - cell of struct with the parameters
%     - n_valid - number of valid results
%     - res - struct of arrays with the results
%     - param - struct with the parameter combinations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('assemble results')

% count and filter
n_sweep = length(is_valid_vec);
n_valid = nnz(is_valid_vec);
res_vec = res_vec(is_valid_vec);
param_vec = param_vec(is_valid_vec);

% transform the cell to an array
res_vec = [res_vec{:}];
param_vec = [param_vec{:}];

% reorder the array
if n_valid==0
    res = struct();
    param = struct();
else
    res = get_struct_sub(res_vec);
    param = get_struct_sub(param_vec);
end

% display
disp(['    n_sweep = ' num2str(n_sweep)])
disp(['    n_valid = ' num2str(n_valid)])

end

function data = get_struct_sub(data_vec)
% Reorder the data structure (from array of struct to struct of arrays)
%     - data_vec - array of struct with the data
%     - data - struct of arrays with the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

field = fieldnames(data_vec);
for i=1:length(field)
    value_array = [data_vec.(field{i})];
    value_cell = {data_vec.(field{i})};
    
    if isnumeric(value_array)||islogical(value_array)
        data.(field{i}) = value_array;
    elseif isstruct(value_array)
        data.(field{i}) = get_struct_sub(value_array);
    else
        data.(field{i}) = value_cell;
    end
end

end
