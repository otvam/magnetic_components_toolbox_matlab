function signal_f = get_fft(signal_t)
% Compute the Fourier series of a time signal (peak value coefficients)
%     - signal_t - vector with the time domain signal
%     - signal_f - vector with the frequency domain signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = length(signal_t);
idx = 1:ceil(n./2.0);

signal_f = 2.0.*fft(signal_t)./n;
signal_f = signal_f(:,idx);
signal_f(1) = 0.5*signal_f(1);

end