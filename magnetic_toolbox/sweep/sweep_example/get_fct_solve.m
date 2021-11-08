function [is_valid, res] = get_fct_solve(param)
% Test routine for solving the problem
%     - param - struct of scalar with parameter combination
%     - is_valid - boolean indicating the validity on the results
%     - res - struct of scalar with the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

res.add_1 = param.param_1+param.cst_1;
res.add_2 = param.param_3+param.cst_2;
res.sub.add_1 = param.param_2;
res.sub.add_2 = param.cst_2;
res.sub.add_3 = param.cst_3;

is_valid = (param.param_1<10);

end