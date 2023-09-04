function test_conductor()
% Test the geometry and losses produces by a plain and a litz conductor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');

%% data
conductor_litz = get_conductor_litz(100e-6, 2500, 0.5);
conductor_plain = get_conductor_plain(7e-3);

%% data
f_vec = 10e-3;
T = 70;
I_peak_vec = sqrt(2).*100;
H_peak_vec = 0.0;

f_vec = 0;
T = 70;
I_peak_vec = 100;
H_peak_vec = 0.0;


%% plain
test_obj(conductor_plain, f_vec, T, I_peak_vec, H_peak_vec);

%% litz
test_obj(conductor_litz, f_vec, T, I_peak_vec, H_peak_vec);

end

function test_obj(conductor, f_vec, T, I_peak_vec, H_peak_vec)

obj = conductor_losses(conductor);
conductor = obj.get_conductor();
P = obj.get_losses(f_vec, T, I_peak_vec, H_peak_vec);

obj = conductor_geom(conductor);
conductor = obj.get_conductor();
A = obj.get_copper_area();
A = obj.get_conductor_area();
m = obj.get_mass();
d_c = obj.get_diameter();

end