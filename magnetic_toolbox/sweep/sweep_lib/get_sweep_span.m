function [n_sweep, param] = get_sweep_span(flag, sweep)
% Get (all combinations) of the specified parameter sweeps
%     - flag - struct with the parameters which are not part of the sweeps
%     - sweep - struct of array with parameter sweeps
%     - n_sweep - scalar with the number of combinations
%     - param - struct with the parameter combinations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('create parameters')

% span the combinations
[n_sweep, sweep_out] = get_sweep_sub(sweep);

% repeat the constant data
flag_out = get_flag_sub(n_sweep, flag);

% merge data
field = [fieldnames(flag_out);fieldnames(sweep_out)];
value = [struct2cell(flag_out); struct2cell(sweep_out)];
param = cell2struct(value, field);

% field count
n_field = length(fieldnames(param));

% display the number of designs
disp(['    n_field = ' num2str(n_field)])
disp(['    n_sweep = ' num2str(n_sweep)])

end


function [n_sweep, sweep_out] = get_sweep_sub(sweep)
% Get (all combinations) of the specified parameter sweeps
%     - sweep - struct of array with parameter sweeps
%     - n_sweep - scalar with the number of combinations
%     - sweep_out - struct with the parameter combinations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('create parameters')

% get the sweep indexes
for i=1:length(sweep)
    field = fieldnames(sweep{i});
    
    n_vec = [];
    for j=1:length(field)
        value = sweep{i}.(field{j});
        n_vec(j) = length(value);
    end
    assert(length(unique(n_vec))==1, 'invalid data');
    n_vec = mean(n_vec);
    
    n_sweep(i) = n_vec;
    vec{i} = 1:n_vec;
end

% compute all combinations
n_sweep = prod(n_sweep);
mat = cell(1,length(vec));
[mat{:}] = ndgrid(vec{:});

% store the results
sweep_out = struct();
for i=1:length(sweep)
    idx = mat{i}(:).';
    field = fieldnames(sweep{i});
    
    % add the parameter for a specific sweep
    for j=1:length(field)
        value = sweep{i}.(field{j});
        assert(isfield(sweep_out, field{j})==false, 'invalid data')
        sweep_out.(field{j}) = value(idx);
    end
end

end

function flag_out = get_flag_sub(n_sweep, flag)
% Repeat the content of a struct of scalars
%     - n_sweep - scalar with the number of repetition
%     - flag - struct of scalars
%     - flag_out - struct of vectors/cells
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

field = fieldnames(flag);
for i=1:length(field)
   value = flag.(field{i});
   
   if isnumeric(value)||islogical(value)
       value = repmat(value, 1, n_sweep);
   else
       value = repmat({value}, 1, n_sweep);
   end
    
   flag_out.(field{i}) = value;
end

end