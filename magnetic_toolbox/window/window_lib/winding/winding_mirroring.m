% =================================================================================================
% Manage the mirroring method for winding (group of conductors) and air gaps
% =================================================================================================
%
% Manage and compute the following properties:
%     - create all the conductors (windings and equivalent air gaps currents)
%     - get the external magnetic field inside the conductors
%     - get the inductance matrix between the windings
%
% This class provide an additional abstraction layer for the raw implementation of the mirroring method.
%
% =================================================================================================
%
% See also:
%     - mirroring_method (implementation of the mirroring method)
%     - window_class (main class)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef winding_mirroring < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        air_gap % struct with the defining of the air gaps
        winding_conductor % struct with the conductors composing the different windings
        winding_conductor_field % cell with the name of the windings
        conductor_idx % cell with the index of the windings with respect to the conductor property
        conductor % struct with all the conductors (windings and air gaps)
    end
    
    %% init
    methods (Access = public)
        function self = winding_mirroring(air_gap, winding_conductor)
            % create the object
            %     - air_gap - struct with air gaps definition
            %     - winding_conductor - struct with the definition of the different windings
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set the data
            self.air_gap = air_gap;
            self.winding_conductor = winding_conductor;
            
            % init the struct for mapping the struct to vectors
            self.winding_conductor_field = fieldnames(self.winding_conductor);
            self.conductor_idx = {};
            
            % init the data
            self.init_data();
        end
    end
    
    %% public api
    methods (Access = public)
        function conductor = get_conductor(self)
            % get the all the conductors (windings and air gaps)
            %     - conductor - struct with the position of the conductors
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            conductor = self.conductor;
        end
        
        function inductance = parse_inductance(self, L)
            % find the inductance between windings (without air gaps) from the complete inductance matrix
            %     - L - inductance matrix between all the conductors
            %     - inductance - struct with the inductance between the windings
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            for i=1:length(self.winding_conductor_field)
                idx_row = self.conductor_idx{i};
                
                for j=1:length(self.winding_conductor_field)
                    idx_col = self.conductor_idx{j};
                    
                    L_tmp = sum(sum(L(idx_row, idx_col)));
                    inductance.(self.winding_conductor_field{i}).(self.winding_conductor_field{j}) = L_tmp;
                end
            end
        end
        
        function I_vec = parse_excitation(self, excitation)
            % find the current of the conductors and air gaps
            %     - excitation - struct with the winding currents
            %     - I_vec - matrix with the current of the conductors and air gaps
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % find the winding conductor current
            I_winding = [];
            for i=1:length(self.winding_conductor_field)
                n = length(self.winding_conductor.(self.winding_conductor_field{i}).d_c);
                I_winding = [I_winding ; repmat(excitation.(self.winding_conductor_field{i}), n, 1)];
            end
            
            % add air gap currents
            if isempty(self.air_gap.weight)
                I_vec = I_winding;
            else
                % find the air gap current
                I_gap = sum(I_winding, 1);
                I_gap = -self.air_gap.weight.'*I_gap;
                
                % total current
                I_vec = [I_winding ; I_gap];
            end
        end
        
        function magnetic_field = parse_magnetic_field(self, H)
            % find RMS magnetic field for the winding from the complete magnetic field matrix
            %     - H - matrix with the magnetic field all all conductors
            %     - magnetic_field - struct with the value of the field for the windings
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            for i=1:length(self.winding_conductor_field)
                idx = self.conductor_idx{i};
                magnetic_field.(self.winding_conductor_field{i}) = H(idx,:);
            end
        end
    end
    
    %% private api
    methods (Access = private)
        function init_data(self)
            % compute the struct with the position of the conductors (windings air air gaps)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % init the data
            self.conductor.x = [];
            self.conductor.y = [];
            self.conductor.d_c = [];
            
            % add the windings
            for i=1:length(self.winding_conductor_field)
                winding_tmp = self.winding_conductor.(self.winding_conductor_field{i});
                
                idx = self.add_conductor(winding_tmp);
                self.conductor_idx{i} = idx;
            end
            
            % add the air gaps
            self.conductor.x = [self.conductor.x self.air_gap.x];
            self.conductor.y = [self.conductor.y self.air_gap.y];
            self.conductor.d_c = [self.conductor.d_c zeros(1, length(self.air_gap.weight))];
            
            % number of conductors
            self.conductor.n_conductor = length(self.conductor.d_c);
        end
        
        function idx = add_conductor(self, data_tmp)
            % add the conductors of a particular winding
            %     - data_tmp - struct with the conductors composing the winding to be added
            %     - idx - vector with the index of the added conductors with respect to the conductor property
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % find the index
            idx = (length(self.conductor.d_c)+1):(length(self.conductor.d_c)+length(data_tmp.d_c));
            
            % add the conductors
            self.conductor.x = [self.conductor.x data_tmp.x];
            self.conductor.y = [self.conductor.y data_tmp.y];
            self.conductor.d_c = [self.conductor.d_c data_tmp.d_c];
        end
    end
end