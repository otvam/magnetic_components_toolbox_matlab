function res = get_transformer_fct_solve(flag, param, is_verbose)
% Compute a transformer design and extract the figures of merit
%     - flag - struct with the parameters which are not part of the sweeps
%     - param - struct of scalar with parameter sweeps
%     - is_verbose - display (or not) the results and plots
%     - res - struct of scalar with the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract
f_sw = param.f_sw;
t_core = param.t_core;
z_core = param.z_core;
n_litz_lv = param.n_litz_lv;
n_litz_hv = param.n_litz_hv;
n_lv = param.n_lv;
n_hv = param.n_hv;

% constant
P_bus = flag.P_bus;
V_bus = flag.V_bus;
flow = flag.flow;

% get the data
[class, core, winding] = get_transformer_parameter(t_core, z_core, n_litz_lv, n_litz_hv, n_lv, n_hv);

% create the component
obj = component_class(class, core, winding);

% get the losses
circuit = obj.get_circuit();
stress = get_transformer_stress(f_sw, P_bus, V_bus, flow, circuit);
losses = obj.get_losses(stress);

% get the volume and mass
V = obj.get_box_volume();
m = obj.get_box_mass();

% assign results
res.V = V;
res.m = m;
res.losses = losses;
res.circuit = circuit;

% plot the results
if is_verbose==true
    obj.get_plot();
    get_disp(flag, param, res);
end

end

function get_disp(flag, param, res)
% Display the resuts on the console
%     - flag - struct with the parameters which are not part of the sweeps
%     - param - struct of scalar with parameter sweeps
%     - res - struct of scalar with the results

fprintf('disp\n')
fprintf('    flag\n')
fprintf('        P_bus = %.3f kW\n', 1e-3.*flag.P_bus)
fprintf('        V_bus = %.3f V\n', 1e0.*flag.V_bus)
fprintf('        flow = %s\n', flag.flow)
fprintf('    flag\n')
fprintf('        f_sw = %.3f kHz\n', 1e-3.*param.f_sw)
fprintf('        t_core = %.3f mm\n', 1e3.*param.t_core)
fprintf('        z_core = %.3f mm\n', 1e3.*param.z_core)
fprintf('        n_litz_lv = %d\n', param.n_litz_lv)
fprintf('        n_litz_hv = %d\n', param.n_litz_hv)
fprintf('        n_lv = %d\n', param.n_lv)
fprintf('        n_hv = %d\n', param.n_hv)
fprintf('    volume/mass\n')
fprintf('        V = %.3f dm3\n', 1e3.*res.V)
fprintf('        m = %.3f kg\n', 1e0.*res.m)
fprintf('    circuit\n')
fprintf('        type = %s\n', res.circuit.type)
fprintf('        is_valid = %s\n', mat2str(res.circuit.is_valid))
fprintf('        L_leak_lv = %.3f uH\n', 1e6.*res.circuit.L_leak.lv)
fprintf('        L_leak_hv = %.3f uH\n', 1e6.*res.circuit.L_leak.hv)
fprintf('        L_mag_lv = %.3f uH\n', 1e6.*res.circuit.L_mag.lv)
fprintf('        L_mag_hv = %.3f uH\n', 1e6.*res.circuit.L_mag.hv)
fprintf('    core\n')
fprintf('        is_valid = %s\n', mat2str(res.losses.core.is_valid))
fprintf('        P = %.3f W\n', 1e0.*res.losses.core.P)
fprintf('    window\n')
fprintf('        is_valid = %s\n', mat2str(res.losses.window.is_valid))
fprintf('        P = %.3f W\n', 1e0.*res.losses.window.P)
fprintf('        P_lv = %.3f W\n', 1e0.*res.losses.window.P_lv)
fprintf('        P_hv = %.3f W\n', 1e0.*res.losses.window.P_hv)
fprintf('    losses\n')
fprintf('        is_valid = %s\n', mat2str(res.losses.is_valid))
fprintf('        P = %.3f W\n', 1e0.*res.losses.P)

end
