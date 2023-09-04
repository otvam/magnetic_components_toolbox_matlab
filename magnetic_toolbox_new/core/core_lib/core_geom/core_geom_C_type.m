% =================================================================================================
% Geometry of a C shaped core.
% =================================================================================================
%
% Define the geometry of a C-core.
% Standard C-core or U-core.
% Arbitrary dimension are accepted.
%
% =================================================================================================
%
% See also:
%     - core_geom_abstract (abtract class for the core geometry)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef core_geom_C_type < core_geom_abstract
    %% init
    methods (Access = public)
        function self = core_geom_C_type(core, mu_core, mu_domain)
            % create the object
            %     - core - struct with the core geometry
            %     - mu_core - permeability of the core
            %     - mu_domain - permeability of the air
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % init superclass
            self = self@core_geom_abstract(core, mu_core, mu_domain);
            
            % check data
            validateattributes(self.core.d_window, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.core.h_window, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.core.t_core, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.core.z_core, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.core.d_gap, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
        end
    end
    
    %% public abstract api
    methods (Access = public)
        function limb = get_limb(self)
            % get the reluctance model (limbs composed of core elements and air gaps)
            %     - limb - struct with the definition of the limbs with the reluctances
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set the top and bottom stabs
            element_tmp = struct('d_l', self.core.d_window, 'd_stab', self.core.t_core, 'z_core', self.core.z_core, 'mu', self.mu_core);
            center.stab_top = struct('type', 'stab', 'data', element_tmp);
            center.stab_bottom = struct('type', 'stab', 'data', element_tmp);
            
            % set the right and left stabs
            element_tmp = struct('d_l', self.core.h_window, 'd_stab', self.core.t_core, 'z_core', self.core.z_core, 'mu', self.mu_core);
            center.stab_right = struct('type', 'stab', 'data', element_tmp);
            center.stab_left = struct('type', 'stab', 'data', element_tmp);
            
            % set the four corners
            element_tmp = struct('d_a', self.core.t_core, 'd_b', self.core.t_core, 'z_core', self.core.z_core, 'mu', self.mu_core);
            center.corner_top_left = struct('type', 'corner', 'data', element_tmp);
            center.corner_top_right = struct('type', 'corner', 'data', element_tmp);
            center.corner_bottom_left = struct('type', 'corner', 'data', element_tmp);
            center.corner_bottom_right = struct('type', 'corner', 'data', element_tmp);
            
            % set the two air gaps
            element_tmp = struct('d_gap', self.core.d_gap, 'd_stab', self.core.t_core, 'd_corner', self.core.h_window./2.0, 'z_core', self.core.z_core, 'mu', self.mu_domain);
            center.gap_right = struct('type', 'gap_stab_stab', 'data', element_tmp);
            center.gap_left = struct('type', 'gap_stab_stab', 'data', element_tmp);
            
            % core has only one limb
            limb.center = center;
        end
        
        function V = get_core_volume(self)
            % get the volume of the core (without window)
            %     - V - scalar with the volume of the core
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            A_stab_d = 2.0.*self.core.d_window.*self.core.t_core;
            A_stab_h = 2.0.*self.core.h_window.*self.core.t_core;
            A_corner = 4.0.*self.core.t_core.^2;
            V = self.core.z_core.*(A_stab_d+A_stab_h+A_corner);
        end
        
        function V = get_box_volume(self)
            % get the box volume of the core (with window)
            %     - V - scalar with the box volume of the core
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            h = self.core.h_window+2.0.*self.core.t_core;
            d = self.core.d_window+2.0.*self.core.t_core;
            V = self.core.z_core.*h.*d;
        end
        
        function plot_data = get_plot_data(self)
            % get the data for plotting the core
            %     - plot_data - struct with the data for plotting the core
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            plot_data.d_gap = self.core.d_gap;
            plot_data.A_mag = self.core.t_core.*self.core.z_core;
            plot_data.z_core = self.core.z_core;
            plot_data.name = 'C-core';
            
            h_ext = self.core.h_window+2.0.*self.core.t_core;
            d_ext = self.core.d_window+2.0.*self.core.t_core;
            h_int = self.core.h_window;
            d_int = self.core.d_window;
            d_gap = self.core.d_gap;
            
            plot_data.core{1} = struct('x_min', -d_ext./2.0, 'x_max', +d_ext./2.0, 'y_min', -h_ext./2.0, 'y_max', +h_ext./2.0);
            plot_data.window{1} = struct('x_min', -d_int./2.0, 'x_max', +d_int./2.0, 'y_min', -h_int./2.0, 'y_max', +h_int./2.0);
            plot_data.window{2} = struct('x_min', -d_ext./2.0, 'x_max', +d_ext./2.0, 'y_min', -d_gap./2.0, 'y_max', +d_gap./2.0);
        end
    end
end