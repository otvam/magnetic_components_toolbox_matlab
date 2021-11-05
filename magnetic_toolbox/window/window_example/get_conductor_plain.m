function conductor = get_conductor_plain(d_c)
% Data for a plain round copper conductor
%     - d_c - diameter of the conductor
%     - conductor - struct with the conductor data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conductor.type = 'plain';

conductor.sigma.rho = 1.7241e-8;
conductor.sigma.alpha = 3.93e-3;
conductor.sigma.T_ref = 20.0;

conductor.mu = 1.0;
conductor.d_c = d_c;

conductor.rho = 8960.0;

end