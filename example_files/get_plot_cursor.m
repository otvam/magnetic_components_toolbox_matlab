function get_plot_cursor(fig, sca, fom, fct_disp)
% Plot the a Pareto front
%     - fig - handle for the figure
%     - sca - handle for the scatter plot
%     - fom - struct with the figures of merit
%     - fct_disp - function handle for displaying the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dcm = datacursormode(fig);
dcm.UpdateFcn = @(obj, event) get_callback(obj, event, sca, fom, fct_disp);
dcm.Interpreter = 'none';
dcm.Enable = 'on';

end

function txt = get_callback(obj, event, sca, fom, fct_disp)
% Callback for the data cursor
%     - obj - data tip object
%     - event - data event object
%     - sca - handle for the scatter plot
%     - fom - struct with the figures of merit
%     - fct_disp - function handle for displaying the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check data
assert(isobject(obj), 'invalid callback')
assert(isobject(event), 'invalid callback')

% get data
target = event.Target;
select = event.DataIndex;

% display tip
if sca==target
    % slice data
    fom_tmp = get_res_slice(fom, select, true);

    % get data cursor
    txt = fct_disp(fom_tmp);

    % display design
    fprintf('================================\n')
    for i=1:length(txt)
        fprintf('%s\n', txt{i})
    end
    fprintf('================================\n')
else
    txt = {};
end

end