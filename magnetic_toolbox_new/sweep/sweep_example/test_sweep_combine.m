function test_sweep_combine()
% Run a dummy simulation for multiple parameter combinations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');

%% data
fct_solve = @(param) get_fct_solve(param);

sweep = {};
sweep{end+1} = struct('param_1', [1 2 3 4 7 20]);
sweep{end+1} = struct('param_2', {{'a', 'b', 'c'}}, 'param_3', [1 2 3]);

flag.cst_1 = 1.0;
flag.cst_2 = pi;
flag.cst_3 = 'c';

%% run
data = get_sweep_combine('test / sweep', flag, sweep, fct_solve);

end