% =================================================================================================
% Definition of a standard inductor with one winding.
% =================================================================================================
%
% Inductor with one winding.
% The winding is one the center limb.
%
% =================================================================================================
%
% See also:
%     - core_component_abstract (abtract class for the component defintion)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef core_component_inductor < core_component_abstract
    %% init
    methods (Access = public)
        function self = core_component_inductor(winding)
            % create the object
            %     - winding - struct with the number of turns
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            self = self@core_component_abstract(winding);
        end
    end
    
    %% public abstract api
    methods (Access = public)
        function type = get_type(self)
            % get the component type
            %     - type - str with the component type
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            type = 'inductor';
        end
        
        function source = get_source(self)
            % get the magnetic source for the defined component
            %     - source - struct with the definition of the magnetic sources
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            source.winding = struct('n', self.winding, 'limb', 'center');
        end
        
        function circuit = parse_circuit(self, inductance)
            % find the equivalent circuit from the inductance matrix
            %     - inductance - struct with the inductance matrix
            %     - circuit - struct with the equivalent circuit
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            circuit.type = 'inductor';
            circuit.is_valid = true;
            circuit.L_mag = inductance.winding.winding;
        end
        
        function excitation = parse_excitation(self, n, current)
            % find the magnetic source from the current stress applied to the component
            %     - n - scalar with the size of the current vectors
            %     - stress - struct with the current stress applied to the component
            %     - excitation - struct with the current excitation of the magnetic sources
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            validateattributes(n, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(current, {'double'},{'row', 'nonempty', 'nonnan','finite'});
            assert(length(current)==n, 'invalid data');
            
            excitation.n = n;
            excitation.source.winding = current;
        end
    end
end