function stress = get_transformer_stress(param, circuit)
% Compute the current waveform (transformer stress) for a SRC-DCX
%     - param - struct of scalar with parameter sweeps
%     - circuit - struct with the transformer equivalent circuit
%     - stress - struct with the transformer current stresses
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
[I_hv, I_lv] = get_transformer_stress_sub(f_sw, P_trf, V_lv, V_hv, circuit, 2.*n_freq);

stress.window.T = T_window;
stress.window.f_vec = get_f_vec(f_sw, n_freq);
stress.window.current.lv = get_fft(I_lv);
stress.window.current.hv = get_fft(I_hv);

% stress for the core (computation of the core losses / time domain)
[I_hv, I_lv] = get_transformer_stress_sub(f_sw, P_trf, V_lv, V_hv, circuit, n_time);

stress.core.T = T_core;
stress.core.f = f_sw;
stress.core.d_vec = get_d_vec(n_time);
stress.core.current.lv = I_lv;
stress.core.current.hv = I_hv;

end

function [I_hv, I_lv] = get_transformer_stress_sub(f_sw, P_trf, V_lv, V_hv, circuit, n_time)
% Compute the transformer currents
%     - f_sw - switching frequency
%     - P_trf - power rating
%     - V_lv - voltage of the LV bus
%     - V_hv - voltage of the HV bus
%     - circuit - struct with the transformer equivalent circuit
%     - n_time - scalar with the number of sample per period
%     - I_hv - vector with the HV winding current
%     - I_lv - vector with the LV winding current
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the (scaled) time vector
d_vec = get_d_vec(n_time);

% check circuit
assert(circuit.is_valid==true, 'invalid circuit')
assert(circuit.L_leak.hv>0, 'invalid circuit')
assert(circuit.L_leak.lv>0, 'invalid circuit')
assert(circuit.L_mag.hv>circuit.L_leak.hv, 'invalid circuit')
assert(circuit.L_mag.lv>circuit.L_leak.lv, 'invalid circuit')

% extract circuit
L_lv = circuit.L_mag.lv;
L_hv = circuit.L_mag.hv;
n = sqrt(L_hv./L_lv);

% check transfer ratio
assert(abs(n-(V_hv./V_lv))<eps, 'invalid circuit')

% magnetizing current (splitted between both sides)
I_lv_mag_peak = V_lv./(4.*f_sw.*L_lv);
I_hv_mag_peak = V_hv./(4.*f_sw.*L_hv);
I_lv_mag = (I_lv_mag_peak./2).*sawtooth(2.*pi.*d_vec, 0.5);
I_hv_mag = (I_hv_mag_peak./2).*sawtooth(2.*pi.*d_vec, 0.5);

% load current
I_lv_load_peak = (pi.*P_trf)./(2.*V_lv);
I_hv_load_peak = (pi.*P_trf)./(2.*V_hv);
I_lv_load = I_lv_load_peak.*sin(2.*pi.*d_vec);
I_hv_load = I_hv_load_peak.*sin(2.*pi.*d_vec);

% total current (magnetizing current flows on the feeder side)
I_lv = +I_lv_load+I_lv_mag;
I_hv = -I_hv_load+I_hv_mag;

end
