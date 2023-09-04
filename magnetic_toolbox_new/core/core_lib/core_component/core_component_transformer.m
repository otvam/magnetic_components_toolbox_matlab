% =================================================================================================
% Definition of a standard transformer with two windings.
% =================================================================================================
%
% Transformer with two windings.
% The windings are one the center limb.
% The current direction is defined with the same sign for the HV and LV winding.
% This means that the current excitation should features opposite signs.
%
% =================================================================================================
%
% See also:
%     - core_component_abstract (abtract class for the component defintion)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef core_component_transformer < core_component_abstract
    %% init
    methods (Access = public)
        function self = core_component_transformer(winding)
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
            
            type = 'transformer';
        end
        
        function source = get_source(self)
            % get the magnetic source for the defined component
            %     - source - struct with the definition of the magnetic sources
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            source.hv = struct('n', self.winding.hv, 'limb', 'center');
            source.lv = struct('n', self.winding.lv, 'limb', 'center');
        end
        
        function circuit = parse_circuit(self, inductance)
            % find the equivalent circuit from the inductance matrix
            %     - inductance - struct with the inductance matrix
            %     - circuit - struct with the equivalent circuit
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            circuit.type = 'transformer';
            circuit.is_valid = true;
            circuit.L_mag.hv = inductance.hv.hv;
            circuit.L_mag.lv = inductance.lv.lv;
        end
        
        function excitation = parse_excitation(self, n, current)
            % find the magnetic source from the current stress applied to the component
            %     - n - scalar with the size of the current vectors
            %     - stress - struct with the current stress applied to the component
            %     - excitation - struct with the current excitation of the magnetic sources
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            validateattributes(n, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(current.hv, {'double'},{'row', 'nonempty', 'nonnan','finite'});
            validateattributes(current.lv, {'double'},{'row', 'nonempty', 'nonnan','finite'});
            assert(length(current.hv)==n, 'invalid data');
            assert(length(current.lv)==n, 'invalid data');
            
            excitation.n = n;
            excitation.source.hv = current.hv;
            excitation.source.lv = current.lv;
        end
    end
end