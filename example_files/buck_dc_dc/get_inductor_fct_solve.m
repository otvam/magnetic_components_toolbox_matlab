function [is_valid, res] = get_inductor_fct_solve(param, is_verbose)
% Compute an inductor design and extract the figures of merit
%     - param - struct of scalar with parameter sweeps
%     - is_verbose - display (or not) the results and plots
%     - is_valid - boolean indicating the validity of the results
%     - res - struct of scalar with the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check if the design is reasonable
is_valid = get_inductor_validity(param);
if is_valid==false
    res = struct();
    return
end

% get the model data
[class, core, winding] = get_inductor_parameter(param);

% create the component
obj = component_class(class, core, winding);

% get the equivalent circuit and losses
circuit = obj.get_circuit();
stress = get_inductor_stress(param, circuit);
losses = obj.get_losses(stress);

% get the volume and mass
V = obj.get_box_volume();
A = obj.get_box_area();
m = obj.get_box_mass();

% assign results
res.V = V;
res.A = A;
res.m = m;
res.losses = losses;
res.circuit = circuit;

% plot the results
if is_verbose==true
    obj.get_plot();
    get_disp(param, res);
end

end

function get_disp(param, res)
% Display the resuts on the console
%     - param - struct of scalar with parameter sweeps
%     - res - struct of scalar with the results

fprintf('disp\n')
fprintf('    operating\n')
fprintf('        P_trf = %.3f kW\n', 1e-3.*param.P_trf)
fprintf('        V_lv = %.3f V\n', 1e0.*param.V_lv)
fprintf('        V_hv = %.3f V\n', 1e0.*param.V_hv)
fprintf('        f_sw = %.3f kHz\n', 1e-3.*param.f_sw)
fprintf('    geometry\n')
fprintf('        f_sw = %.3f kHz\n', 1e-3.*param.f_sw)
fprintf('        r_gap = %.3f %%\n', 1e2.*param.r_gap)
fprintf('        A_core = %.3f mm2\n', 1e6.*param.A_core)
fprintf('        r_core = %.3f %%\n', 1e2.*param.r_core)
fprintf('        A_litz = %.3f mm2\n', 1e6.*param.A_litz)
fprintf('        n_winding = %d\n', param.n_winding)
fprintf('    volume/mass\n')
fprintf('        V = %.3f dm3\n', 1e3.*res.V)
fprintf('        A = %.3f dm2\n', 1e2.*res.A)
fprintf('        m = %.3f kg\n', 1e0.*res.m)
fprintf('    circuit\n')
fprintf('        is_valid = %s\n', mat2str(res.circuit.is_valid))
fprintf('        L = %.3f uH\n', 1e6.*res.circuit.L)
fprintf('    core\n')
fprintf('        is_valid = %s\n', mat2str(res.losses.core.is_valid))
fprintf('        P = %.3f W\n', 1e0.*res.losses.core.P)
fprintf('    window\n')
fprintf('        is_valid = %s\n', mat2str(res.losses.window.is_valid))
fprintf('        P = %.3f W\n', 1e0.*res.losses.window.P)
fprintf('    losses\n')
fprintf('        is_valid = %s\n', mat2str(res.losses.is_valid))
fprintf('        P = %.3f W\n', 1e0.*res.losses.P)

end
