% =================================================================================================
% Adapater class for core computations.
% =================================================================================================
%
% Parse the data for the core solver.
% For transformer and inductor.
% For C-type and E-type cores.
%
% =================================================================================================
%
% See also:
%     - component_type_abstract (main class)
%     - core_class (class for core geometry, losses, circuit, etc.)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef core_adapter < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        core % struct with the core data
        winding % struct with the winding data
        data_add % struct with the data which are component specific
        core_class_obj % instance of core_class
    end
    
    %% init
    methods (Access = public)
        function self = core_adapter(core, winding, data_add)
            % create the object
            %     - core - struct with the core geometry and material
            %     - winding - struct with the winding geometry and material
            %     - data_add - struct with the data which are component specific
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set the data
            self.core = core;
            self.winding = winding;
            self.data_add = data_add;
            
            % parse the data
            [class_tmp, winding_tmp] = self.get_data_class_winding();
            [material_tmp, geom_tmp] = self.get_data_material_geom();
            
            % create the instance
            self.core_class_obj = core_class(class_tmp, material_tmp, geom_tmp, winding_tmp);
        end
    end
    
    %% public api
    methods (Access = public)
        function core_class_obj = get_core_class_obj(self)
            % get the instance of core_class
            %     - core_class_obj - instance of core_class
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            core_class_obj = self.core_class_obj;
        end
        
        function circuit = parse_circuit(self, circuit_raw)
            % parse and initialize the equivalent circuit structure for the core
            %     - circuit_raw - struct created by core_class
            %     - circuit - struct with the parsed circuit data
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            switch self.data_add.type
                case 'inductor'
                    circuit.is_valid = circuit_raw.is_valid;
                    circuit.L = circuit_raw.L_mag;
                case 'transformer'
                    circuit.is_valid = circuit_raw.is_valid;
                    circuit.L_mag.lv = circuit_raw.L_mag.lv;
                    circuit.L_mag.hv = circuit_raw.L_mag.hv;
                    circuit.L_leak.lv = 0.0;
                    circuit.L_leak.hv = 0.0;
                otherwise
                    error('invalid data')
            end
        end
    end
    
    %% private api
    methods (Access = private)
        function [class_tmp, winding_tmp] = get_data_class_winding(self)
            % parse the data for the component type and the winding
            %     - class_tmp - struct with the component type
            %     - winding_tmp - struct with winding definition
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            switch self.data_add.type
                case 'inductor'
                    % inductor with one winding
                    winding_tmp = sum(self.winding.winding.n_winding)./self.winding.winding.n_par;
                    class_tmp.core_component_class = @core_component_inductor;
                case 'transformer'
                    % transformer with two windings
                    winding_tmp.lv = sum(self.winding.lv.n_winding)./self.winding.lv.n_par;
                    winding_tmp.hv = sum(self.winding.hv.n_winding)./self.winding.hv.n_par;
                    class_tmp.core_component_class = @core_component_transformer;
                otherwise
                    error('invalid data')
            end
            
            switch self.data_add.geom
                case 'C_type'
                    % C-core geometry
                    class_tmp.core_geom_class = @core_geom_C_type;
                case 'E_type'
                    % E-core geometry
                    class_tmp.core_geom_class = @core_geom_E_type;
                otherwise
                    error('invalid data')
            end
        end
        
        function [material_tmp, geom_tmp] = get_data_material_geom(self)
            % parse the data for the material and the core geometry
            %     - material_tmp - struct with material
            %     - geom_tmp - struct with geometry
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            material_tmp = self.core.material;
            
            geom_tmp.d_window = self.data_add.d_window;
            geom_tmp.h_window = self.data_add.h_window;
            geom_tmp.t_core = self.core.t_core;
            geom_tmp.z_core = self.core.z_core;
            geom_tmp.d_gap = self.core.d_gap;
        end
    end
end