function res = get_fct_solve(flag, param)
% Test routine for solving the problem
%     - flag - struct with the parameters which are not part of the sweeps
%     - param - struct of scalar with parameter combination
%     - res - struct of scalar with the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

res.add_1 = param.param_1+flag.cst_1;
res.add_2 = param.param_3+flag.cst_2;
res.sub.add_1 = param.param_2;
res.sub.add_2 = flag.cst_2;

end