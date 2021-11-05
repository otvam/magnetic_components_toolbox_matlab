% =================================================================================================
% Definition of a window placed in a free space (no core).
% =================================================================================================
%
% Define the geometry of the window.
% Define the mirroring BC (none type).
%
% =================================================================================================
%
% See also:
%     - window_geom_abstract (abtract class for the window geometry)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef window_geom_head < window_geom_abstract
    %% init
    methods (Access = public)
        function self = window_geom_head(core, window)
            % create the object
            %     - core - struct with the boundary condition for the core
            %     - window - struct with the geometry of the window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % init superclass
            self = self@window_geom_abstract(core, window);
            
            % check data
            validateattributes(self.core.mu_domain, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.core.d_pole, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
        end
    end
    
    %% public abstract api
    methods (Access = public)
        function bc = get_bc(self)
            % get the bc condition used for stray field computation
            %     - bc - struct with the definition of the bc
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            bc.type = 'none';
            bc.mu_domain = self.core.mu_domain;
            bc.d_pole = self.core.d_pole;
            bc.z_size = self.window.z_mean;
        end
        
        function air_gap = get_air_gap(self)
            % get the air gaps used for stray field computation
            %     - air_gap - struct with air gaps definition
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % no air gap
            air_gap.x = [];
            air_gap.y = [];
            air_gap.weight = [];
        end
        
        function plot_data = get_plot_data_sub(self)
            % get the data for plotting the window (boundary condition and air gaps)
            %     - plot_data - struct with the data for plotting the window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            plot_data.type = 'no-plane';
            plot_data.x_gap = [];
            plot_data.y_gap = [];
            
            plot_data.sym = {};
        end
    end
end