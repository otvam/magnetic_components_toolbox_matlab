function is_valid = get_inductor_validity(param)
% Check if an inductor design is reasonable (current density and flux density)
%     - param - struct of scalar with parameter sweeps
%     - is_valid - boolean indicating the validity of the design
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract
f_sw = param.f_sw;
r_gap = param.r_gap;
A_core = param.A_core;
A_litz = param.A_litz;
n_winding = param.n_winding;
P_trf = param.P_trf;
V_lv = param.V_lv;
V_hv = param.V_hv;

% get magnetizing inductance
mu0 = 4*pi*1e-7;
d_gap = 2.*r_gap.*sqrt(A_core);

% modulation
duty = V_lv./V_hv;
V_inductor = V_hv-V_lv;

% inductance
L = (n_winding.^2).*(mu0.*A_core./d_gap);

% get currents
I_ac_pk = (duty.*V_inductor)./(2.*f_sw.*L);
I_dc = P_trf./V_lv;

% current density and ripple
ripple = (2.*I_ac_pk)./I_dc;
I_rms = hypot(I_dc, I_ac_pk./sqrt(3));
J_rms = I_rms./A_litz;

% flux densities
B_dc = (mu0.*n_winding./d_gap).*I_dc;
B_ac_pk = (duty.*V_inductor)./(2.*f_sw.*n_winding.*A_core);
B_max = B_dc+B_ac_pk;

% check validity
is_valid = true;
is_valid = is_valid&&(J_rms>2e6);
is_valid = is_valid&&(J_rms<20e6);
is_valid = is_valid&&(ripple<3.0);
is_valid = is_valid&&(B_ac_pk>5e-3);
is_valid = is_valid&&(B_ac_pk<3000e-3);
is_valid = is_valid&&(B_max>100e-3);
is_valid = is_valid&&(B_max<350e-3);

end