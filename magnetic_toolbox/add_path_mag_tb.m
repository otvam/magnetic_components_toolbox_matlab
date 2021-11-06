function add_path_mag_tb(add_examples)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add the magnetic toolbox to the MATLAB path
%     - add_path_toolbox(false) - add the toolbox path
%     - add_path_toolbox(true) - add the toolbox and examples path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 2021, T. Guillod, BSD License
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get path
folder = fileparts(which(mfilename()));

% add toolbox
addpath([folder '/core']);
addpath([folder '/window']);
addpath([folder '/sweep']);
addpath([folder '/component']);
addpath(genpath([folder '/core/core_lib']));
addpath(genpath([folder '/window/window_lib']));
addpath(genpath([folder '/sweep/sweep_lib']));
addpath(genpath([folder '/component/component_lib']));

% add examples
if add_examples==true
    addpath(genpath([folder '/core/core_example']));
    addpath(genpath([folder '/window/window_example']));
    addpath(genpath([folder '/sweep/sweep_example']));
    addpath(genpath([folder '/component/component_example']));
end

end