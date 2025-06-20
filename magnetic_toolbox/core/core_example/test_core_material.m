function test_core_material()
% Test the loss map, SE, and IGSE for a typical magnetic core material
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');

%% create obj
material = get_material_N87();
obj = core_material(material.mu_core, material.mu_domain, material.rho, material.losses_map);

%% get data
rho = obj.get_rho();
mu_core = obj.get_mu_core();
mu_domain = obj.get_mu_domain();
losses_map = obj.get_losses_map();

%% get losses
f = 50e3;
T = 70;
B_peak = 125e-3;
B_dc = 50e-3;

d_vec = [0.25 0.75];
B_vec = B_dc+[-B_peak +B_peak];

param = obj.get_param(f, B_peak, B_dc, T);
losses = obj.get_losses_se(f, B_peak, B_dc, T);
losses = obj.get_losses_igse(f, d_vec, B_vec, T);

end
