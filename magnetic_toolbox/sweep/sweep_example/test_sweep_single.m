function test_sweep_single()
% Run a dummy simulation for a single parameter combination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');

%% data

% function solving the problem
fct_solve = @(param) get_fct_solve(param);

% sweep data
sweep = struct();
sweep.param_0 = 2;
sweep.param_1 = 11;
sweep.param_2i = 2;
sweep.param_2c = 'a';

% constant data
flag.cst_0 = 1.0;
flag.cst_1 = 2.0;
flag.cst_2i = pi;
flag.cst_2c = 'cst';

%% run
data = get_sweep_single('test / single', flag, sweep, fct_solve);

end