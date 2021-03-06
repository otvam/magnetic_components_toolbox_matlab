function conductor = get_conductor_litz(d_litz, n_litz, fill_factor)
% Data for a litz round copper conductor
%     - d_litz - diameter of the strands
%     - n_litz - number of strands
%     - fill_factor - fill factor of the wire
%     - conductor - struct with the conductor data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conductor.type = 'litz';

conductor.sigma.rho = 1.7241e-8;
conductor.sigma.alpha = 3.93e-3;
conductor.sigma.T_ref = 20.0;

conductor.mu = 1.0;
conductor.rho = 8960.0;

A_litz = n_litz.*pi.*(d_litz./2.0).^2;
A_wire = A_litz./fill_factor;
d_c = sqrt(4.0.*A_wire./pi);

conductor.d_c = d_c;
conductor.d_litz = d_litz;
conductor.n_litz = n_litz;


end