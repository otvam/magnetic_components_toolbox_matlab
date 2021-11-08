function material = get_material_core()
% Data and loss map for EPCOS N87 Ferrite
%     - material - struct with the core data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

material.losses_map = get_losses_map_N87();
material.mu_core = 2200;
material.mu_domain = 1;
material.rho = 4850;

end

function losses_map = get_losses_map_N87()
% Loss map for EPCOS N87 Ferrite
%     - losses_map - struct with the loss map data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% temperature
losses_map.T.vec = [25 60 80 100];
losses_map.T.range = [5 120];

% frequency
losses_map.f.vec = 1e3.*[10 30 90 270];
losses_map.f.range = 1e3.*[5 350];

% peak flux density
losses_map.B_peak.vec = 1e-3.*[25 50 100 150 200];
losses_map.B_peak.range = 1e-3.*[0 300];

% offset flux density
losses_map.B_dc.vec = 1e-3.*[0 100 200];
losses_map.B_dc.range = 1e-3.*[0 300];

% interpolation method for T and B_dc
losses_map.interp_T_B_dc.method = 'linear';
losses_map.interp_T_B_dc.extrap = 'linear';

% interpolation method for f and B_peak
losses_map.interp_f_B_peak.method = 'linear';
losses_map.interp_f_B_peak.extrap = 'nearest';

% data
P_f_B_peak_B_dc_T(1,1,1,1) = 3.256294e+02;
P_f_B_peak_B_dc_T(1,1,1,2) = 1.319612e+02;
P_f_B_peak_B_dc_T(1,1,1,3) = 8.259854e+01;
P_f_B_peak_B_dc_T(1,1,1,4) = 6.549094e+01;
P_f_B_peak_B_dc_T(1,1,2,1) = 4.673475e+02;
P_f_B_peak_B_dc_T(1,1,2,2) = 1.919809e+02;
P_f_B_peak_B_dc_T(1,1,2,3) = 1.158965e+02;
P_f_B_peak_B_dc_T(1,1,2,4) = 7.937324e+01;
P_f_B_peak_B_dc_T(1,1,3,1) = 7.134427e+02;
P_f_B_peak_B_dc_T(1,1,3,2) = 3.229636e+02;
P_f_B_peak_B_dc_T(1,1,3,3) = 1.884271e+02;
P_f_B_peak_B_dc_T(1,1,3,4) = 1.292155e+02;
P_f_B_peak_B_dc_T(1,2,1,1) = 1.913506e+03;
P_f_B_peak_B_dc_T(1,2,1,2) = 8.258293e+02;
P_f_B_peak_B_dc_T(1,2,1,3) = 5.158313e+02;
P_f_B_peak_B_dc_T(1,2,1,4) = 4.349746e+02;
P_f_B_peak_B_dc_T(1,2,2,1) = 2.752662e+03;
P_f_B_peak_B_dc_T(1,2,2,2) = 1.205868e+03;
P_f_B_peak_B_dc_T(1,2,2,3) = 7.299769e+02;
P_f_B_peak_B_dc_T(1,2,2,4) = 5.468349e+02;
P_f_B_peak_B_dc_T(1,2,3,1) = 4.522015e+03;
P_f_B_peak_B_dc_T(1,2,3,2) = 2.071238e+03;
P_f_B_peak_B_dc_T(1,2,3,3) = 1.266259e+03;
P_f_B_peak_B_dc_T(1,2,3,4) = 9.158663e+02;
P_f_B_peak_B_dc_T(1,3,1,1) = 9.993799e+03;
P_f_B_peak_B_dc_T(1,3,1,2) = 5.066993e+03;
P_f_B_peak_B_dc_T(1,3,1,3) = 3.387904e+03;
P_f_B_peak_B_dc_T(1,3,1,4) = 3.121833e+03;
P_f_B_peak_B_dc_T(1,3,2,1) = 1.511873e+04;
P_f_B_peak_B_dc_T(1,3,2,2) = 7.403707e+03;
P_f_B_peak_B_dc_T(1,3,2,3) = 4.499124e+03;
P_f_B_peak_B_dc_T(1,3,2,4) = 3.814422e+03;
P_f_B_peak_B_dc_T(1,3,3,1) = 2.222340e+04;
P_f_B_peak_B_dc_T(1,3,3,2) = 1.186774e+04;
P_f_B_peak_B_dc_T(1,3,3,3) = 7.384100e+03;
P_f_B_peak_B_dc_T(1,3,3,4) = 5.947204e+03;
P_f_B_peak_B_dc_T(1,4,1,1) = 2.559736e+04;
P_f_B_peak_B_dc_T(1,4,1,2) = 1.439206e+04;
P_f_B_peak_B_dc_T(1,4,1,3) = 1.093749e+04;
P_f_B_peak_B_dc_T(1,4,1,4) = 1.075929e+04;
P_f_B_peak_B_dc_T(1,4,2,1) = 3.605447e+04;
P_f_B_peak_B_dc_T(1,4,2,2) = 1.959932e+04;
P_f_B_peak_B_dc_T(1,4,2,3) = 1.346146e+04;
P_f_B_peak_B_dc_T(1,4,2,4) = 1.221802e+04;
P_f_B_peak_B_dc_T(1,4,3,1) = 4.680736e+04;
P_f_B_peak_B_dc_T(1,4,3,2) = 2.800000e+04;
P_f_B_peak_B_dc_T(1,4,3,3) = 1.857835e+04;
P_f_B_peak_B_dc_T(1,4,3,4) = 1.678730e+04;
P_f_B_peak_B_dc_T(1,5,1,1) = 5.083432e+04;
P_f_B_peak_B_dc_T(1,5,1,2) = 3.097151e+04;
P_f_B_peak_B_dc_T(1,5,1,3) = 2.517438e+04;
P_f_B_peak_B_dc_T(1,5,1,4) = 2.523356e+04;
P_f_B_peak_B_dc_T(1,5,2,1) = 6.335871e+04;
P_f_B_peak_B_dc_T(1,5,2,2) = 3.893303e+04;
P_f_B_peak_B_dc_T(1,5,2,3) = 2.884004e+04;
P_f_B_peak_B_dc_T(1,5,2,4) = 2.764161e+04;
P_f_B_peak_B_dc_T(1,5,3,1) = 7.900000e+04;
P_f_B_peak_B_dc_T(1,5,3,2) = 5.000000e+04;
P_f_B_peak_B_dc_T(1,5,3,3) = 3.400000e+04;
P_f_B_peak_B_dc_T(1,5,3,4) = 3.000000e+04;
P_f_B_peak_B_dc_T(2,1,1,1) = 1.074251e+03;
P_f_B_peak_B_dc_T(2,1,1,2) = 5.011043e+02;
P_f_B_peak_B_dc_T(2,1,1,3) = 3.153789e+02;
P_f_B_peak_B_dc_T(2,1,1,4) = 2.576425e+02;
P_f_B_peak_B_dc_T(2,1,2,1) = 1.768820e+03;
P_f_B_peak_B_dc_T(2,1,2,2) = 6.940679e+02;
P_f_B_peak_B_dc_T(2,1,2,3) = 4.244304e+02;
P_f_B_peak_B_dc_T(2,1,2,4) = 3.209081e+02;
P_f_B_peak_B_dc_T(2,1,3,1) = 2.551952e+03;
P_f_B_peak_B_dc_T(2,1,3,2) = 1.197026e+03;
P_f_B_peak_B_dc_T(2,1,3,3) = 6.216353e+02;
P_f_B_peak_B_dc_T(2,1,3,4) = 4.619696e+02;
P_f_B_peak_B_dc_T(2,2,1,1) = 6.245312e+03;
P_f_B_peak_B_dc_T(2,2,1,2) = 3.009202e+03;
P_f_B_peak_B_dc_T(2,2,1,3) = 1.956150e+03;
P_f_B_peak_B_dc_T(2,2,1,4) = 1.564315e+03;
P_f_B_peak_B_dc_T(2,2,2,1) = 9.651319e+03;
P_f_B_peak_B_dc_T(2,2,2,2) = 4.002707e+03;
P_f_B_peak_B_dc_T(2,2,2,3) = 2.695502e+03;
P_f_B_peak_B_dc_T(2,2,2,4) = 2.090810e+03;
P_f_B_peak_B_dc_T(2,2,3,1) = 1.492249e+04;
P_f_B_peak_B_dc_T(2,2,3,2) = 7.152823e+03;
P_f_B_peak_B_dc_T(2,2,3,3) = 4.388602e+03;
P_f_B_peak_B_dc_T(2,2,3,4) = 3.276217e+03;
P_f_B_peak_B_dc_T(2,3,1,1) = 3.427174e+04;
P_f_B_peak_B_dc_T(2,3,1,2) = 1.735507e+04;
P_f_B_peak_B_dc_T(2,3,1,3) = 1.288818e+04;
P_f_B_peak_B_dc_T(2,3,1,4) = 1.195326e+04;
P_f_B_peak_B_dc_T(2,3,2,1) = 5.139703e+04;
P_f_B_peak_B_dc_T(2,3,2,2) = 2.372097e+04;
P_f_B_peak_B_dc_T(2,3,2,3) = 1.723692e+04;
P_f_B_peak_B_dc_T(2,3,2,4) = 1.523298e+04;
P_f_B_peak_B_dc_T(2,3,3,1) = 7.376774e+04;
P_f_B_peak_B_dc_T(2,3,3,2) = 3.856847e+04;
P_f_B_peak_B_dc_T(2,3,3,3) = 2.671451e+04;
P_f_B_peak_B_dc_T(2,3,3,4) = 2.222230e+04;
P_f_B_peak_B_dc_T(2,4,1,1) = 8.929135e+04;
P_f_B_peak_B_dc_T(2,4,1,2) = 5.028773e+04;
P_f_B_peak_B_dc_T(2,4,1,3) = 4.107312e+04;
P_f_B_peak_B_dc_T(2,4,1,4) = 4.193429e+04;
P_f_B_peak_B_dc_T(2,4,2,1) = 1.233625e+05;
P_f_B_peak_B_dc_T(2,4,2,2) = 6.510464e+04;
P_f_B_peak_B_dc_T(2,4,2,3) = 4.995424e+04;
P_f_B_peak_B_dc_T(2,4,2,4) = 4.930765e+04;
P_f_B_peak_B_dc_T(2,4,3,1) = 1.574478e+05;
P_f_B_peak_B_dc_T(2,4,3,2) = 9.000000e+04;
P_f_B_peak_B_dc_T(2,4,3,3) = 6.500000e+04;
P_f_B_peak_B_dc_T(2,4,3,4) = 6.174804e+04;
P_f_B_peak_B_dc_T(2,5,1,1) = 1.766125e+05;
P_f_B_peak_B_dc_T(2,5,1,2) = 1.083591e+05;
P_f_B_peak_B_dc_T(2,5,1,3) = 9.374681e+04;
P_f_B_peak_B_dc_T(2,5,1,4) = 9.855395e+04;
P_f_B_peak_B_dc_T(2,5,2,1) = 2.120670e+05;
P_f_B_peak_B_dc_T(2,5,2,2) = 1.285921e+05;
P_f_B_peak_B_dc_T(2,5,2,3) = 1.059791e+05;
P_f_B_peak_B_dc_T(2,5,2,4) = 1.042916e+05;
P_f_B_peak_B_dc_T(2,5,3,1) = 2.550000e+05;
P_f_B_peak_B_dc_T(2,5,3,2) = 1.600000e+05;
P_f_B_peak_B_dc_T(2,5,3,3) = 1.200000e+05;
P_f_B_peak_B_dc_T(2,5,3,4) = 1.100000e+05;
P_f_B_peak_B_dc_T(3,1,1,1) = 4.195988e+03;
P_f_B_peak_B_dc_T(3,1,1,2) = 2.012818e+03;
P_f_B_peak_B_dc_T(3,1,1,3) = 1.457596e+03;
P_f_B_peak_B_dc_T(3,1,1,4) = 1.213902e+03;
P_f_B_peak_B_dc_T(3,1,2,1) = 5.404266e+03;
P_f_B_peak_B_dc_T(3,1,2,2) = 2.891100e+03;
P_f_B_peak_B_dc_T(3,1,2,3) = 2.076293e+03;
P_f_B_peak_B_dc_T(3,1,2,4) = 1.551416e+03;
P_f_B_peak_B_dc_T(3,1,3,1) = 9.017109e+03;
P_f_B_peak_B_dc_T(3,1,3,2) = 4.235122e+03;
P_f_B_peak_B_dc_T(3,1,3,3) = 3.373104e+03;
P_f_B_peak_B_dc_T(3,1,3,4) = 3.126324e+03;
P_f_B_peak_B_dc_T(3,2,1,1) = 2.425866e+04;
P_f_B_peak_B_dc_T(3,2,1,2) = 1.205436e+04;
P_f_B_peak_B_dc_T(3,2,1,3) = 8.565910e+03;
P_f_B_peak_B_dc_T(3,2,1,4) = 7.469614e+03;
P_f_B_peak_B_dc_T(3,2,2,1) = 3.175180e+04;
P_f_B_peak_B_dc_T(3,2,2,2) = 1.782807e+04;
P_f_B_peak_B_dc_T(3,2,2,3) = 1.255371e+04;
P_f_B_peak_B_dc_T(3,2,2,4) = 1.042712e+04;
P_f_B_peak_B_dc_T(3,2,3,1) = 5.266809e+04;
P_f_B_peak_B_dc_T(3,2,3,2) = 2.813227e+04;
P_f_B_peak_B_dc_T(3,2,3,3) = 2.235381e+04;
P_f_B_peak_B_dc_T(3,2,3,4) = 2.010540e+04;
P_f_B_peak_B_dc_T(3,3,1,1) = 1.296284e+05;
P_f_B_peak_B_dc_T(3,3,1,2) = 7.484412e+04;
P_f_B_peak_B_dc_T(3,3,1,3) = 5.923994e+04;
P_f_B_peak_B_dc_T(3,3,1,4) = 5.782516e+04;
P_f_B_peak_B_dc_T(3,3,2,1) = 1.816841e+05;
P_f_B_peak_B_dc_T(3,3,2,2) = 1.044386e+05;
P_f_B_peak_B_dc_T(3,3,2,3) = 8.257230e+04;
P_f_B_peak_B_dc_T(3,3,2,4) = 7.991677e+04;
P_f_B_peak_B_dc_T(3,3,3,1) = 2.427818e+05;
P_f_B_peak_B_dc_T(3,3,3,2) = 1.429947e+05;
P_f_B_peak_B_dc_T(3,3,3,3) = 1.185963e+05;
P_f_B_peak_B_dc_T(3,3,3,4) = 1.110413e+05;
P_f_B_peak_B_dc_T(3,4,1,1) = 3.434725e+05;
P_f_B_peak_B_dc_T(3,4,1,2) = 2.179975e+05;
P_f_B_peak_B_dc_T(3,4,1,3) = 1.908755e+05;
P_f_B_peak_B_dc_T(3,4,1,4) = 1.947954e+05;
P_f_B_peak_B_dc_T(3,4,2,1) = 4.314171e+05;
P_f_B_peak_B_dc_T(3,4,2,2) = 2.672018e+05;
P_f_B_peak_B_dc_T(3,4,2,3) = 2.296882e+05;
P_f_B_peak_B_dc_T(3,4,2,4) = 2.317571e+05;
P_f_B_peak_B_dc_T(3,4,3,1) = 5.137325e+05;
P_f_B_peak_B_dc_T(3,4,3,2) = 3.155433e+05;
P_f_B_peak_B_dc_T(3,4,3,3) = 2.720934e+05;
P_f_B_peak_B_dc_T(3,4,3,4) = 2.607043e+05;
P_f_B_peak_B_dc_T(3,5,1,1) = 6.610157e+05;
P_f_B_peak_B_dc_T(3,5,1,2) = 4.665022e+05;
P_f_B_peak_B_dc_T(3,5,1,3) = 4.280091e+05;
P_f_B_peak_B_dc_T(3,5,1,4) = 4.355425e+05;
P_f_B_peak_B_dc_T(3,5,2,1) = 7.508437e+05;
P_f_B_peak_B_dc_T(3,5,2,2) = 5.083728e+05;
P_f_B_peak_B_dc_T(3,5,2,3) = 4.583035e+05;
P_f_B_peak_B_dc_T(3,5,2,4) = 4.625736e+05;
P_f_B_peak_B_dc_T(3,5,3,1) = 8.530000e+05;
P_f_B_peak_B_dc_T(3,5,3,2) = 5.550000e+05;
P_f_B_peak_B_dc_T(3,5,3,3) = 5.000000e+05;
P_f_B_peak_B_dc_T(3,5,3,4) = 4.900000e+05;
P_f_B_peak_B_dc_T(4,1,1,1) = 1.805080e+04;
P_f_B_peak_B_dc_T(4,1,1,2) = 1.151151e+04;
P_f_B_peak_B_dc_T(4,1,1,3) = 1.206413e+04;
P_f_B_peak_B_dc_T(4,1,1,4) = 1.288729e+04;
P_f_B_peak_B_dc_T(4,1,2,1) = 2.735543e+04;
P_f_B_peak_B_dc_T(4,1,2,2) = 1.510325e+04;
P_f_B_peak_B_dc_T(4,1,2,3) = 1.343830e+04;
P_f_B_peak_B_dc_T(4,1,2,4) = 1.359842e+04;
P_f_B_peak_B_dc_T(4,1,3,1) = 4.038507e+04;
P_f_B_peak_B_dc_T(4,1,3,2) = 2.050009e+04;
P_f_B_peak_B_dc_T(4,1,3,3) = 1.709947e+04;
P_f_B_peak_B_dc_T(4,1,3,4) = 1.583101e+04;
P_f_B_peak_B_dc_T(4,2,1,1) = 1.098612e+05;
P_f_B_peak_B_dc_T(4,2,1,2) = 6.962870e+04;
P_f_B_peak_B_dc_T(4,2,1,3) = 6.371990e+04;
P_f_B_peak_B_dc_T(4,2,1,4) = 6.615230e+04;
P_f_B_peak_B_dc_T(4,2,2,1) = 1.695886e+05;
P_f_B_peak_B_dc_T(4,2,2,2) = 9.512615e+04;
P_f_B_peak_B_dc_T(4,2,2,3) = 7.967103e+04;
P_f_B_peak_B_dc_T(4,2,2,4) = 7.601217e+04;
P_f_B_peak_B_dc_T(4,2,3,1) = 2.511405e+05;
P_f_B_peak_B_dc_T(4,2,3,2) = 1.477033e+05;
P_f_B_peak_B_dc_T(4,2,3,3) = 1.181672e+05;
P_f_B_peak_B_dc_T(4,2,3,4) = 1.049992e+05;
P_f_B_peak_B_dc_T(4,3,1,1) = 5.991224e+05;
P_f_B_peak_B_dc_T(4,3,1,2) = 4.151149e+05;
P_f_B_peak_B_dc_T(4,3,1,3) = 3.740329e+05;
P_f_B_peak_B_dc_T(4,3,1,4) = 3.783469e+05;
P_f_B_peak_B_dc_T(4,3,2,1) = 8.151590e+05;
P_f_B_peak_B_dc_T(4,3,2,2) = 5.446505e+05;
P_f_B_peak_B_dc_T(4,3,2,3) = 4.705776e+05;
P_f_B_peak_B_dc_T(4,3,2,4) = 4.583487e+05;
P_f_B_peak_B_dc_T(4,3,3,1) = 1.105440e+06;
P_f_B_peak_B_dc_T(4,3,3,2) = 7.417217e+05;
P_f_B_peak_B_dc_T(4,3,3,3) = 6.301968e+05;
P_f_B_peak_B_dc_T(4,3,3,4) = 5.737115e+05;
P_f_B_peak_B_dc_T(4,4,1,1) = 1.513162e+06;
P_f_B_peak_B_dc_T(4,4,1,2) = 1.154496e+06;
P_f_B_peak_B_dc_T(4,4,1,3) = 1.069504e+06;
P_f_B_peak_B_dc_T(4,4,1,4) = 1.090058e+06;
P_f_B_peak_B_dc_T(4,4,2,1) = 1.990170e+06;
P_f_B_peak_B_dc_T(4,4,2,2) = 1.375387e+06;
P_f_B_peak_B_dc_T(4,4,2,3) = 1.245354e+06;
P_f_B_peak_B_dc_T(4,4,2,4) = 1.264981e+06;
P_f_B_peak_B_dc_T(4,4,3,1) = 2.306808e+06;
P_f_B_peak_B_dc_T(4,4,3,2) = 1.679721e+06;
P_f_B_peak_B_dc_T(4,4,3,3) = 1.467080e+06;
P_f_B_peak_B_dc_T(4,4,3,4) = 1.470000e+06;
P_f_B_peak_B_dc_T(4,5,1,1) = 2.905351e+06;
P_f_B_peak_B_dc_T(4,5,1,2) = 2.313183e+06;
P_f_B_peak_B_dc_T(4,5,1,3) = 2.174595e+06;
P_f_B_peak_B_dc_T(4,5,1,4) = 2.220768e+06;
P_f_B_peak_B_dc_T(4,5,2,1) = 3.400816e+06;
P_f_B_peak_B_dc_T(4,5,2,2) = 2.566682e+06;
P_f_B_peak_B_dc_T(4,5,2,3) = 2.380784e+06;
P_f_B_peak_B_dc_T(4,5,2,4) = 2.409792e+06;
P_f_B_peak_B_dc_T(4,5,3,1) = 3.981000e+06;
P_f_B_peak_B_dc_T(4,5,3,2) = 2.900000e+06;
P_f_B_peak_B_dc_T(4,5,3,3) = 2.620000e+06;
P_f_B_peak_B_dc_T(4,5,3,4) = 2.610000e+06;

losses_map.P_f_B_peak_B_dc_T = P_f_B_peak_B_dc_T;

end