function test_sweep_single()
% Run a dummy simulation for a single parameter combination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');

%% data
fct_solve = @(param) get_fct_solve(param);

sweep = struct();
sweep.param_1 = 1;
sweep.param_2 = 'a';
sweep.param_3 = 1;

flag.cst_1 = 1.0;
flag.cst_2 = pi;
flag.cst_3 = 'a';

%% run
data = get_sweep_single('test / single', flag, sweep, fct_solve);

end