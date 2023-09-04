function [is_valid, res] = get_fct_solve(param)
% Test routine for solving the problem
%     - param - struct of scalar with parameter combination
%     - is_valid - boolean indicating the validity on the results
%     - res - struct of scalar with the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

res.add_0 = param.param_0+param.cst_0;
res.add_1 = param.param_1+param.cst_1;
res.add_2 = param.param_2i+param.cst_2i;
res.sub.add_param = param.param_2c;
res.sub.add_cst = param.cst_2c;
res.sub.add_cat = [param.param_2c, '_', param.cst_2c];

is_valid = (param.param_0<5)&(param.param_1<15);

end