% =================================================================================================
% Compute geometry of round plain or round litz wire
% =================================================================================================
%
% Compute the geometry of a wire (plain or litz) with:
%     - copper area
%     - total area
%     - mass
%
% All parameters are computed for 1 m in the third dimension.
%
% =================================================================================================
%
% See also:
%     - conductor_losses (manage the losses of the wire)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef conductor_geom < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        conductor % struct with the material and geometrical parameters
    end
    
    %% init
    methods (Access = public)
        function self = conductor_geom(conductor)
            % create the object
            %     - conductor - struct with the material and geometrical parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set data
            self.conductor = conductor;
            
            % check data
            switch self.conductor.type
                case 'plain'
                    validateattributes(self.conductor.d_c, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
                    validateattributes(self.conductor.rho, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
                case 'litz'
                    validateattributes(self.conductor.d_c, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
                    validateattributes(self.conductor.rho, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
                    validateattributes(self.conductor.d_litz, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
                    validateattributes(self.conductor.n_litz, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
                otherwise
                    error('invalid type');
            end
        end
    end
    
    %% public api
    methods (Access = public)
        function conductor = get_conductor(self)
            % get the conductor parameter
            %     - conductor - struct with the material and geometrical parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            conductor = self.conductor;
        end
        
        function A = get_copper_area(self)
            % get the copper area of the wire
            %     - A - scalar with the area
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            switch self.conductor.type
                case 'plain'
                    A = pi.*(self.conductor.d_c./2.0).^2;
                case 'litz'
                    A = self.conductor.n_litz.*pi.*(self.conductor.d_litz./2.0).^2;
                otherwise
                    error('invalid type');
            end
        end
        
        function A = get_conductor_area(self)
            % get the total (copper and insulation) area of the wire
            %     - A - scalar with the area
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            A = pi.*(self.conductor.d_c./2.0).^2;
        end
        
        function m = get_mass(self)
            % get the mass of the wire
            %     - m - scalar with the mass
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            A = self.get_copper_area();
            m = self.conductor.rho.*A;
        end
        
        function d_c = get_diameter(self)
            % get the diameter of the wire
            %     - d_c - scalar with the diameter
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            d_c = self.conductor.d_c;
        end
    end
end
