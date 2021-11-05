function [n_sweep, param] = get_sweep_span(sweep)
% Get (all combinations) of the specified parameter sweeps
%     - sweep - struct of array with parameter sweeps
%     - n_sweep - scalar with the number of combinations
%     - param - struct with the parameter combinations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('create sweep')

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
param = struct();
for i=1:length(sweep)
    idx = mat{i}(:).';
    field = fieldnames(sweep{i});
    
    % add the parameter for a specific sweep
    for j=1:length(field)
        value = sweep{i}.(field{j});
        assert(isfield(param, field{j})==false, 'invalid data')
        param.(field{j}) = value(idx);
    end
end

% display the number of designs
field = fieldnames(param);
disp(['    n_field = ' num2str(length(field))])
disp(['    n_sweep = ' num2str(n_sweep)])

end
