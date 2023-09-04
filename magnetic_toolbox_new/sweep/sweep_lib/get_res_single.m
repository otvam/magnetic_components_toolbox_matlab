function data = get_res_single(data, idx)
% Reorder the data structure (from array of struct to struct of arrays)
%     - data_vec - array of struct with the data
%     - data - struct of arrays with the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

field = fieldnames(data);
for i=1:length(field)
    value = data.(field{i});

    if isnumeric(value)||islogical(value)
        data.(field{i}) = value(idx);
    elseif isstruct(value)
        data.(field{i}) = get_res_single(value, idx);
    else
        data.(field{i}) = value{idx};
    end
end

end
