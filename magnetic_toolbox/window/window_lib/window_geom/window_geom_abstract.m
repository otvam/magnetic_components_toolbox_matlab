% =================================================================================================
% Abstract class for defining magnetic core geometry and reluctance model.
% =================================================================================================
%
% Define an interface for:
%     - winding window geometry
%     - bc condition for stray field computation
%     - air gap for stray field computation
%
% =================================================================================================
%
% See also:
%     - window_class (main class)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef window_geom_abstract < handle
    %% properties
    properties (SetAccess = protected, GetAccess = protected)
        core % struct with the boundary condition
        window % struct with the core geometry
        z_size % struct with the size in the third dimension
    end
    
    %% init
    methods (Access = public)
        function self = window_geom_abstract(core, window)
            % create the object
            %     - core - struct with the boundary condition for the core
            %     - window - struct with the geometry of the window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set the data
            self.core = core;
            self.window = window;
            
            % check the validity of the geometry
            validateattributes(self.window.d, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.window.h, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.window.z_mean, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.window.z_top_right, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.window.z_top_left, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.window.z_bottom_right, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.window.z_bottom_left, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
        end
    end
    
    %% public api
    methods (Access=public)
        function plot_data = get_plot_data(self)
            % get the data for plotting the window
            %     - plot_data - struct with the data for plotting the window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            plot_data.d = self.window.d;
            plot_data.h = self.window.h;
            plot_data.z = self.window.z_mean;
        end
        
        function window = get_window(self)
            % get the size of the window (window geometry)
            %     - window - struct with the geometry of the window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            window = self.window;
        end
    end
    
    %% public abstract api
    methods (Abstract, Access=public)
        bc = get_bc(self)
        % get the bc condition used for stray field computation
        %     - bc - struct with the definition of the bc
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        air_gap = get_air_gap(self)
        % get the air gaps used for stray field computation
        %     - air_gap - struct with air gaps definition
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        plot_data = get_plot_data_sub(self)
        % get the data for plotting the window (boundary condition and air gaps)
        %     - plot_data - struct with the data for plotting the window
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end