function stress = get_transformer_stress(f_sw, P_bus, V_bus, flow, circuit)
% Compute the current waveform (transformer stress) for a SRC-DCX
%     - f_sw - switching frequency
%     - P_bus - power rating
%     - V_bus - voltage of the feeder bus
%     - flow - power flow direction
%     - circuit - struct with the transformer equivalement circuit
%     - stress - struct with the transformer current stresses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% stress for the window (computation of the winding losses / frequency domain)
n_freq = 50;
[I_hv, I_lv] = get_transformer_stress_sub(f_sw, P_bus, V_bus, flow, circuit, 2.*n_freq);

stress.window.T = 110;
stress.window.f_vec = get_f_vec(f_sw, n_freq);
stress.window.current.lv = get_fft(I_lv);
stress.window.current.hv = get_fft(I_hv);

% stress for the core (computation of the core losses / time domain)
n_time = 100;
[I_hv, I_lv] = get_transformer_stress_sub(f_sw, P_bus, V_bus, flow, circuit, n_time);

stress.core.T = 80;
stress.core.f = f_sw;
stress.core.d_vec = get_d_vec(n_time);
stress.core.current.lv = I_lv;
stress.core.current.hv = I_hv;

end

function [I_hv, I_lv] = get_transformer_stress_sub(f_sw, P_bus, V_bus, flow, circuit, n_time)
% Compute the transformer currents
%     - f_sw - switching frequency
%     - P_bus - power rating
%     - V_bus - voltage of the feeder bus
%     - flow - power flow direction
%     - circuit - struct with the transformer equivalement circuit
%     - n_time - scalar with the number of sample per period
%     - I_hv - vector with the HV winding current
%     - I_lv - vector with the LV winding current
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the (scaled) time vector
d_vec = get_d_vec(n_time);

% get circuit
switch flow
    case 'hv_to_lv'
        L_mag = circuit.L_mag.hv;
        n = sqrt(circuit.L_mag.hv./circuit.L_mag.lv);
    case 'lv_to_hv'
        L_mag = circuit.L_mag.lv;
        n = sqrt(circuit.L_mag.lv./circuit.L_mag.hv);
    otherwise
        error('invalid power flow')
end

% magnetizing current
I_mag_peak = V_bus./(4.0.*f_sw.*L_mag);
I_mag = I_mag_peak.*sawtooth(2.0.*pi.*d_vec, 0.5);

% load current
I_load_peak = (pi.*P_bus)./(2.0.*V_bus);
I_load = I_load_peak.*sin(2.0.*pi.*d_vec);

% total current (magnetizing current flows on the feeder side)
switch flow
    case 'hv_to_lv'
        I_hv = +I_load+I_mag;
        I_lv = -I_load.*n;
    case 'lv_to_hv'
        I_lv = +I_load+I_mag;
        I_hv = -I_load.*n;
    otherwise
        error('invalid power flow')
end

end

function d_vec = get_d_vec(n_time)
% Get a normalized time vector
%     - n_time - scalar with the number of sample per period
%     - d_vec - vector the scaled sampling points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d_vec = (0:(n_time-1))./n_time;

end

function f_vec = get_f_vec(f, n_freq)
% Get a frequency vector (including DC)
%     - f - scalar with the fundamental frequency
%     - n_freq - scalar with the number of frequencies
%     - f_vec - vector with the frequencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f_vec = f.*(0:(n_freq-1));

end

function signal_f = get_fft(signal_t)
% Compute the Fourier series of a time signal (peak value coefficients)
%     - signal_t - vector with the time domain signal
%     - signal_f - vector with the frequency domain signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = length(signal_t);
idx = 1:ceil(n./2.0);

signal_f = 2.0.*fft(signal_t)./n;
signal_f = signal_f(:,idx);
signal_f(1) = 0.5*signal_f(1);

end