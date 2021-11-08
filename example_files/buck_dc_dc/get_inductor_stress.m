function stress = get_inductor_stress(param, circuit)
% Compute the current waveform (inductor stress) for a SRC-DCX
%     - param - struct of scalar with parameter sweeps
%     - circuit - struct with the inductor equivalent circuit
%     - stress - struct with the inductor current stresses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract
f_sw = param.f_sw;
P_trf = param.P_trf;
V_lv = param.V_lv;
V_hv = param.V_hv;

% number of frequencies for the winding losses
n_freq = 50;

% number of time samples for the core losses
n_time = 100;

% temperatures of the winding window and the core
T_window = 110;
T_core = 80;

% stress for the window (computation of the winding losses / frequency domain)
I_winding = get_inductor_stress_sub(f_sw, P_trf, V_lv, V_hv, circuit, 2.*n_freq);

stress.window.T = T_window;
stress.window.f_vec = get_f_vec(f_sw, n_freq);
stress.window.current = get_fft(I_winding);

% stress for the core (computation of the core losses / time domain)
I_winding = get_inductor_stress_sub(f_sw, P_trf, V_lv, V_hv, circuit, n_time);

stress.core.T = T_core;
stress.core.f = f_sw;
stress.core.d_vec = get_d_vec(n_time);
stress.core.current = I_winding;

end

function I_winding = get_inductor_stress_sub(f_sw, P_trf, V_lv, V_hv, circuit, n_time)
% Compute the inductor current
%     - f_sw - switching frequency
%     - P_trf - power rating
%     - V_lv - voltage of the LV bus
%     - V_hv - voltage of the HV bus
%     - circuit - struct with the inductor equivalent circuit
%     - n_time - scalar with the number of sample per period
%     - I_winding - vector with the winding current
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the (scaled) time vector
d_vec = get_d_vec(n_time);

% check circuit
assert(circuit.is_valid==true, 'invalid circuit')
assert(circuit.L>0, 'invalid circuit')

% extract circuit
L = circuit.L;

% ripple current
duty = V_lv./V_hv;
V_inductor = V_hv-V_lv;
I_ac_peak = (duty.*V_inductor)./(2.*f_sw.*L);
I_ac = I_ac_peak.*sawtooth(2.*pi.*d_vec, duty);

% dc current
I_dc = P_trf./V_lv;

% total current
I_winding = +I_ac+I_dc;

end
