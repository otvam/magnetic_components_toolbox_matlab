function test_reluctance_method()
% Test the reluctance method for a core with three limbs and four windings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');

%% source
source.lv = struct('n', 10.0, 'limb', 'center');
source.hv = struct('n', 20.0, 'limb', 'center');
source.right = struct('n', 1.0, 'limb', 'right');
source.left = struct('n', 1.0, 'limb', 'left');

%% limb
element_tmp = struct('d_l', 50e-3, 'd_stab', 20e-3, 'z_core', 20e-3, 'mu', 2200);
limb_tmp.stab = struct('type', 'stab', 'data', element_tmp);

element_tmp = struct('d_a', 20e-3, 'd_b', 20e-3, 'z_core', 20e-3, 'mu', 2200);
limb_tmp.corner = struct('type', 'corner', 'data', element_tmp);

element_tmp = struct('d_gap', 1e-3, 'd_stab', 20e-3, 'd_corner', 20e-3, 'z_core', 20e-3, 'mu', 1);
limb_tmp.gap_stab_stab = struct('type', 'gap_stab_stab', 'data', element_tmp);
limb_tmp.gap_stab_half_plane = struct('type', 'gap_stab_half_plane', 'data', element_tmp);
limb_tmp.gap_stab_full_plane = struct('type', 'gap_stab_full_plane', 'data', element_tmp);

element_tmp = struct('d_gap', 1e-3, 'd_stab', 20e-3, 'z_core', 20e-3, 'mu', 1);
limb_tmp.gap_simple = struct('type', 'gap_simple', 'data', element_tmp);

limb.left = limb_tmp;
limb.right = limb_tmp;
limb.center = limb_tmp;

%% current
excitation.n = 2;
excitation.source.lv = [1.0 2.0];
excitation.source.hv = [-2.0 -4.0];
excitation.source.right = [-0.1 -0.1];
excitation.source.left = [-0.1 -0.1];

%% test
obj = reluctance_method(limb, source);

limb = obj.get_limb();
source = obj.get_source();
limb_element = obj.get_limb_element();
limb_element_sum = obj.get_limb_element_sum();
inductance = obj.get_inductance();

phi_limb = obj.get_phi_limb(excitation);
psi_source = obj.get_psi_source(excitation);

end
