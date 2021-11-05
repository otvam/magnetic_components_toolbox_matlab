% =================================================================================================
% Abstract class for defining magnetic core geometry and reluctance model.
% =================================================================================================
%
% Define an interface for:
%     - core mu (permeability)
%     - core geometry
%     - core reluctance model
%     - core volume
%
% =================================================================================================
%
% See also:
%     - core_class (main class)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef core_geom_abstract < handle
    %% properties
    properties (SetAccess = protected, GetAccess = protected)
        core % struct with the core geometry
        mu_core % permeability of the core
        mu_domain % permeability of the air
    end
    
    %% init
    methods (Access = public)
        function self = core_geom_abstract(core, mu_core, mu_domain)
            % create the object
            %     - core - struct with the core geometry
            %     - mu_core - permeability of the core
            %     - mu_domain - permeability of the air
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            self.core = core;
            self.mu_core = mu_core;
            self.mu_domain = mu_domain;
            
            validateattributes(self.mu_core, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.mu_domain, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
        end
    end
    
    %% public abstract api
    methods (Abstract, Access=public)
        limb = get_limb(self)
        % get the reluctance model (limbs composed of core elements and air gaps)
        %     - limb - struct with the definition of the limbs with the reluctances
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        V = get_core_volume(self)
        % get the core volume of the core (without window)
        %     - V - scalar with the volume of the core
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        V = get_box_volume(self)
        % get the box volume of the core (with window)
        %     - V - scalar with the box volume of the core
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        plot_data = get_plot_data(self)
        % get the data for plotting the core
        %     - plot_data - struct with the data for plotting the core
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end