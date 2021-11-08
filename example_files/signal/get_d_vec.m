function d_vec = get_d_vec(n_time)
% Get a normalized time vector
%     - n_time - scalar with the number of sample per period
%     - d_vec - vector the scaled sampling points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d_vec = (0:(n_time-1))./n_time;

end
