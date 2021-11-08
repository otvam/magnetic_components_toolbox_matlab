function is_valid = get_transformer_validity(param)
% Check if a transformer design is reasonable (current density and flux density)
%     - param - struct of scalar with parameter sweeps
%     - is_valid - boolean indicating the validity of the design
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract
f_sw = param.f_sw;
r_gap = param.r_gap;
A_core = param.A_core;
A_litz_lv = param.A_litz_lv;
A_litz_hv = param.A_litz_hv;
n_winding_lv = param.n_winding_lv;
n_winding_hv = param.n_winding_hv;
P_trf = param.P_trf;
V_lv = param.V_lv;
V_hv = param.V_hv;

% get magnetizing inductance
mu0 = 4*pi*1e-7;
d_gap = r_gap.*sqrt(A_core);
L_norm = mu0.*A_core./(2.*d_gap);
L_lv = (n_winding_lv.^2).*L_norm;
L_hv = (n_winding_hv.^2).*L_norm;

% peak currents
I_mag_lv_pk = V_lv./(4.*f_sw.*L_lv);
I_mag_hv_pk = V_hv./(4.*f_sw.*L_hv);
I_load_lv_pk = (pi.*P_trf)./(2.*V_lv);
I_load_hv_pk = (pi.*P_trf)./(2.*V_hv);

% rms currents
I_lv_rms = hypot(I_mag_lv_pk./(2.*sqrt(3)), I_load_lv_pk./sqrt(2));
I_hv_rms = hypot(I_mag_hv_pk./(2.*sqrt(3)), I_load_hv_pk./sqrt(2));

% current densities
J_lv_rms = I_lv_rms./A_litz_lv;
J_hv_rms = I_hv_rms./A_litz_hv;

% flux densities
B_lv_pk = V_lv./(4.*f_sw.*n_winding_lv.*A_core);
B_hv_pk = V_hv./(4.*f_sw.*n_winding_hv.*A_core);

% check validity
is_valid = true;
is_valid = is_valid&&(min(J_lv_rms, J_hv_rms)>2e6);
is_valid = is_valid&&(max(J_lv_rms, J_hv_rms)<20e6);
is_valid = is_valid&&(min(B_lv_pk, B_hv_pk)>50e-3);
is_valid = is_valid&&(max(B_lv_pk, B_hv_pk)<300e-3);

end