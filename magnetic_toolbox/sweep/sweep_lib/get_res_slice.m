function data = get_res_slice(data, idx, is_single)
% Reorder the data structure (from array of struct to struct of arrays)
%     - data_vec - array of struct with the data (original)
%     - idx - indices to be extracted during the slicing
%     - is_single - flag indicating to extract a scalar index
%     - data - struct of arrays with the data (sliced)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check data
if is_single==true
    assert(isscalar(idx), 'invalid slicing index')
end

% extract data
field = fieldnames(data);
for i=1:length(field)
    value = data.(field{i});

    if isnumeric(value)||islogical(value)
        data.(field{i}) = value(idx);
    elseif isstruct(value)
        data.(field{i}) = get_res_slice(value, idx, is_single);
    elseif iscell(value)
        if is_single==true
            data.(field{i}) = value{idx};
        else
            data.(field{i}) = value(idx);
        end
    else
        error('invalid data type')
    end
end

end
