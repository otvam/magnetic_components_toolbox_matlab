% =================================================================================================
% Definition of a standard inductor with one winding.
% =================================================================================================
%
% Inductor with one winding.
% The inductance of the winding is invalid (no stray inductance).
%
% =================================================================================================
%
% See also:
%     - window_component_abstract (abtract class for the component defintion)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef window_component_inductor < window_component_abstract
    %% init
    methods (Access = public)
        function self = window_component_inductor(window, winding)
            % create the object
            %     - window - struct with the size of the window
            %     - winding - struct with the information about all the windings
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            self = self@window_component_abstract(window, winding);
            
            % init the winding_manager
            self.winding_manager_obj.winding = winding_manager(self.window, self.winding);
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
        
        function circuit = parse_circuit(self, inductance)
            % find the equivalent circuit from the inductance matrix
            %     - inductance - struct with the inductance matrix
            %     - circuit - struct with the equivalent circuit
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            circuit.type = 'inductor';
            circuit.is_valid = false;
            circuit.L_leak = inductance.winding.winding;
        end
        
        function excitation = parse_excitation(self, n, current)
            % find the current of the windings from the current stress applied to the component
            %     - n - scalar with the size of the current vectors
            %     - stress - struct with the current stress applied to the component
            %     - excitation - struct with the current excitation of the windings
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            validateattributes(n, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(current, {'double'},{'row', 'nonempty', 'nonnan','finite'});
            assert(length(current)==n, 'invalid data');
            
            n_par = self.winding_manager_obj.winding.get_n_par();
            excitation.winding = current./n_par;
        end
    end
end