function res = get_res_assemble(res_vec)
% Reorder the results (from cell of struct to struct of arrays)
%     - res_vec - cell of struct with the results
%     - res - struct of arrays with the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('assemble res')

% transform the cell to an array
res_vec = [res_vec{:}];

% reorder the array
res = get_struct_sub(res_vec);

end

function res = get_struct_sub(res_vec)
% Reorder the results (from array of struct to struct of arrays)
%     - res_vec - array of struct with the results
%     - res - struct of arrays with the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

field = fieldnames(res_vec);
for i=1:length(field)
    value_array = [res_vec.(field{i})];
    value_cell = {res_vec.(field{i})};
    
    if isnumeric(value_array)||islogical(value_array)
        res.(field{i}) = value_array;
    elseif isstruct(value_array)
        res.(field{i}) = get_struct_sub(value_array);
    else
        res.(field{i}) = value_cell;
    end
end

end
