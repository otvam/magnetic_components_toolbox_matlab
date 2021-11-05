function test_sweep_single()
% Run a dummy simulation for a single parameter combination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');

%% data
fct_solve = @(flag,sweep) get_fct_solve(flag, sweep);

param = struct();
param.param_1 = 1;
param.param_2 = 'a';
param.param_3 = 1;

flag.cst_1 = 1.0;
flag.cst_2 = pi;

%% run
data_single = get_sweep_single('test / single', flag, param, fct_solve);

end