% =================================================================================================
% Definition of a standard transformer with two windings.
% =================================================================================================
%
% Transformer with two windings.
% The current direction is defined with the same sign for the HV and LV winding.
% This means that the current excitation should features opposite signs.
% The stray inductance is computed without magnetizing current.
%
% =================================================================================================
%
% See also:
%     - window_component_abstract (abtract class for the component defintion)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef window_component_transformer < window_component_abstract
    %% init
    methods (Access = public)
        function self = window_component_transformer(window, winding)
            % create the object
            %     - window - struct with the size of the window
            %     - winding - struct with the information about all the windings
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            self = self@window_component_abstract(window, winding);
            
            % init the winding_manager
            self.winding_manager_obj.lv = winding_manager(self.window, self.winding.lv);
            self.winding_manager_obj.hv = winding_manager(self.window, self.winding.hv);
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
        
        function circuit = parse_circuit(self, inductance)
            % find the equivalent circuit from the inductance matrix
            %     - inductance - struct with the inductance matrix
            %     - circuit - struct with the equivalent circuit
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get the number of turns
            n_winding_lv = self.winding_manager_obj.lv.get_n_winding();
            n_winding_hv = self.winding_manager_obj.hv.get_n_winding();
            
            % construct the inductance matrix
            L_mat = [inductance.lv.lv inductance.lv.hv ; inductance.hv.lv inductance.hv.hv];
            
            % hv side related stray inductance
            I = [1 -n_winding_lv./n_winding_hv];
            L_lv = I*L_mat*I.';
            
            % lv side related stray inductance
            I = [-n_winding_hv./n_winding_lv 1];
            L_hv = I*L_mat*I.';
            
            % set the circuit
            circuit.type = 'transformer';
            circuit.is_valid = true;
            
            n_par = self.winding_manager_obj.hv.get_n_par();
            circuit.L_leak.hv = L_hv./(n_par.^2);
            
            n_par = self.winding_manager_obj.lv.get_n_par();
            circuit.L_leak.lv = L_lv./(n_par.^2);
        end
        
        function excitation = parse_excitation(self, n, current)
            % find the current of the windings from the current stress applied to the component
            %     - n - scalar with the size of the current vectors
            %     - stress - struct with the current stress applied to the component
            %     - excitation - struct with the current excitation of the windings
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            validateattributes(n, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(current.hv, {'double'},{'row', 'nonempty', 'nonnan','finite'});
            validateattributes(current.lv, {'double'},{'row', 'nonempty', 'nonnan','finite'});
            assert(length(current.hv)==n, 'invalid data');
            assert(length(current.lv)==n, 'invalid data');
            
            n_par = self.winding_manager_obj.hv.get_n_par();
            excitation.hv = current.hv./n_par;
            
            n_par = self.winding_manager_obj.lv.get_n_par();
            excitation.lv = current.lv./n_par;
        end
    end
end