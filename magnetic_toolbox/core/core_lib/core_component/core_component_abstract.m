% =================================================================================================
% Abstract class for defining magnetic components (winding, circuit, etc.).
% =================================================================================================
%
% Define an interface for:
%     - winding that are on the core (magnetic source)
%     - find the equivalent circuit from the inductance matrix
%     - get the excitation of the windings (source)
%
% =================================================================================================
%
% See also:
%     - core_class (main class)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef core_component_abstract < handle
    %% properties
    properties (SetAccess = protected, GetAccess = protected)
        winding % struct with the number of turns
    end
    
    %% init
    methods (Access = public)
        function self = core_component_abstract(winding)
            % create the object
            %     - winding - struct with the number of turns
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            self.winding = winding;
        end
    end
    
    %% public abstract api
    methods (Abstract, Access=public)
        type = get_type(self)
        % get the component type
        %     - type - str with the component type
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        source = get_source(self)
        % get the magnetic source for the defined component
        %     - source - struct with the definition of the magnetic sources
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        circuit = parse_circuit(self, inductance)
        % find the equivalent circuit from the inductance matrix
        %     - inductance - struct with the inductance matrix
        %     - circuit - struct with the equivalent circuit
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        excitation = parse_excitation(self, n, current)
        % find the magnetic source from the current stress applied to the component
        %     - n - scalar with the size of the current vectors
        %     - stress - struct with the current stress applied to the component
        %     - excitation - struct with the current excitation of the magnetic sources
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end