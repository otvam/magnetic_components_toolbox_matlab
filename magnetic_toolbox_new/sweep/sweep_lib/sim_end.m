function duration = sim_end(name, tic)
% Start a simulation
%     - name - string with the simulation name
%     - tic - datetime with a timestamp
%     - duration - struct with the name and duration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% simulation time
toc = datetime('now');
diff = toc-tic;

duration.num = seconds(diff);
duration.str = char(diff);
duration.name = name;

% end the simulation
disp(['============= ' name ' / ' char(diff)]);

end
