function f_vec = get_f_vec(f, n_freq)
% Get a frequency vector (including DC)
%     - f - scalar with the fundamental frequency
%     - n_freq - scalar with the number of frequencies
%     - f_vec - vector with the frequencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f_vec = f.*(0:(n_freq-1));

end
