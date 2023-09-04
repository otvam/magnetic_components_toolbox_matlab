function test_sweep_combine()
% Run a dummy simulation for multiple parameter combinations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');

%% data

% function solving the problem
fct_solve = @(param) get_fct_solve(param);

% sweep data
sweep = {};
sweep{end+1} = struct('param_0', 1:10);
sweep{end+1} = struct('param_1', 10:20);
sweep{end+1} = struct('param_2i', [1 2 3], 'param_2c', {{'a', 'b', 'c'}});

% constant data
flag.cst_0 = 1.0;
flag.cst_1 = 2.0;
flag.cst_2i = pi;
flag.cst_2c = 'cst';

% number of data per chunk
n_split = 10;

%% run
data = get_sweep_combine('test / sweep', n_split, flag, sweep, fct_solve);

end