function flag = get_spec_flag()
% Get a structure with the converter specifications
%     - flag - struct with the parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

flag.P_trf = 5e3; % power rating
flag.V_hv = 400.0; % voltage of the HV bus
flag.V_lv = 100.0; % voltage of the LV bus

end