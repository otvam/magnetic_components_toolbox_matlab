function sca = get_plot_front(x_axis, y_axis, c_axis)
% Plot the a Pareto front
%     - x_axis - struct with the x axis data
%     - y_axis - struct with the y axis data
%     - c_axis - struct with the color axis data
%     - sca - handle for the scatter plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract and scale the data
x = x_axis.value.*x_axis.scale;
y = y_axis.value.*y_axis.scale;
c = c_axis.value.*c_axis.scale;

% plot the data
sca = scatter(x, y, 30, c, 'filled');

% set axis
grid('on')
set(gca,'xscale','log')
set(gca,'yscale','lin')
xlim(x_axis.scale.*x_axis.lim)
ylim(y_axis.scale.*y_axis.lim)
clim(c_axis.scale.*c_axis.lim)

% set labels
xlabel(x_axis.name)
ylabel(y_axis.name)
h = colorbar();
set(get(h, 'label'), 'string', c_axis.name);

end