% =================================================================================================
% Definition of a window fully enclosed by a core.
% =================================================================================================
%
% Define the geometry of the window.
% Define the mirroring BC (xy type).
% Define the two air gaps.
%
% =================================================================================================
%
% See also:
%     - window_geom_abstract (abtract class for the window geometry)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef window_geom_core < window_geom_abstract
    %% init
    methods (Access = public)
        function self = window_geom_core(core, window)
            % create the object
            %     - core - struct with the boundary condition for the core
            %     - window - struct with the geometry of the window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % init superclass
            self = self@window_geom_abstract(core, window);
            
            % check data
            validateattributes(self.core.mu_core, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.core.mu_domain, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.core.n_mirror, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.core.d_pole, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.core.d_core, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
        end
    end
    
    %% public abstract api
    methods (Access = public)
        function bc = get_bc(self)
            % get the bc condition used for stray field computation
            %     - bc - struct with the definition of the bc
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            bc.type = 'xy';
            bc.mu_core = self.core.mu_core;
            bc.mu_domain = self.core.mu_domain;
            bc.n_mirror = self.core.n_mirror;
            bc.d_pole = self.core.d_pole;
            
            bc.z_size = self.window.z_mean;
            bc.x_min = -self.window.d./2.0-self.core.d_core;
            bc.x_max = self.window.d./2.0+self.core.d_core;
            bc.y_min = -self.window.h./2.0-self.core.d_core;
            bc.y_max = self.window.h./2.0+self.core.d_core;
        end
        
        function air_gap = get_air_gap(self)
            % get the air gaps used for stray field computation
            %     - air_gap - struct with air gaps definition
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % air gap position
            air_gap.x = [-self.window.d./2.0-self.core.d_core self.window.d./2.0+self.core.d_core];
            air_gap.y = [0.0 0.0];
            
            % two air gap with the same size
            air_gap.weight = [0.5 0.5];
        end
        
        function plot_data = get_plot_data_sub(self)
            % get the data for plotting the window (boundary condition and air gaps)
            %     - plot_data - struct with the data for plotting the window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            plot_data.type = 'full-plane';
            plot_data.x_gap = [-self.window.d./2.0-self.core.d_core self.window.d./2.0+self.core.d_core];
            plot_data.y_gap = [0.0 0.0];
            
            d = self.window.d./2.0+self.core.d_core;
            h = self.window.h./2.0+self.core.d_core;
            plot_data.sym{1} = struct('x', [+d +d], 'y', [-h +h]);
            plot_data.sym{2} = struct('x', [-d -d], 'y', [-h +h]);
            plot_data.sym{3} = struct('x', [-d +d], 'y', [-h -h]);
            plot_data.sym{4} = struct('x', [-d +d], 'y', [+h +h]);
        end
    end
end