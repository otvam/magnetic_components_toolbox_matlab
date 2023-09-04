% =================================================================================================
% Class for computing geometrical properties, the equivalent circuit, and the losses of componenets.
% =================================================================================================
%
% Define an interface for:
%     - active/box volume
%     - mass
%     - equivalent circuit
%     - losses
%
% Handle the following components:
%     - inductor
%     - transformer
%
% =================================================================================================
%
% Warning: The core and window models have some limitations.
%          Please check the corresponding documentation in order to check the validy of the computation.
%
% =================================================================================================
%
% See also:
%     - core_adapter (class for managing the core)
%     - window_adapter (class for managing the window)
%     - core_class (class for computing the core)
%     - window_class (class for computing the window)
%     - component_type_obj (abtract class for the different component types)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef component_class < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        component_type_obj % instance of component_type
        core_class_obj  % instance of core_class
        window_class_obj % struct with instances of window_class
        core_adapter_obj  % instance of core_adapter
        window_adapter_obj % struct with instances of window_adapter
    end
    
    %% init
    methods (Access = public)
        function self = component_class(class, core, winding)
            % get the core geometrical data
            %     - class - string with the name of the component_type class
            %     - core - struct with the core data
            %     - winding - struct with the winding data
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % create an instance of component_type_obj
            self.component_type_obj = class(core, winding);
            
            % get the classes
            self.core_class_obj = self.component_type_obj.get_core_class_obj();
            self.window_class_obj = self.component_type_obj.get_window_class_obj();
            self.core_adapter_obj = self.component_type_obj.get_core_adapter_obj();
            self.window_adapter_obj = self.component_type_obj.get_window_adapter_obj();
        end
    end
    
    %% public api
    methods (Access = public)
        function type = get_type(self)
            % get component type
            %     - type - str with the component type
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            type = self.component_type_obj.get_type();
        end
        
        function V = get_active_volume(self)
            % get the volume of active material (core and winding)
            %     - V - struct with the volume
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            V.core = self.core_class_obj.get_core_volume();
            field = fieldnames(self.window_class_obj);
            
            V.window = 0.0;
            V.copper = 0.0;
            V.conductor = 0.0;
            for i=1:length(field)
                V.window = V.window+self.window_class_obj.(field{i}).get_window_volume();
                V.copper = V.copper+self.window_class_obj.(field{i}).get_copper_volume();
                V.conductor = V.conductor+self.window_class_obj.(field{i}).get_conductor_volume();
            end
            V.active = V.core+V.window;
        end
        
        function V = get_box_volume(self)
            % get the box volume of the component
            %     - V - scalar with the box volume
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            V = self.component_type_obj.get_box_volume();
        end

        function A = get_box_area(self)
            % get the box area of the component
            %     - A - scalar with the box area
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            A = self.component_type_obj.get_box_area();
        end

        function m = get_box_mass(self)
            % get the box mass of the component
            %     - mass - scalar with the box mass
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            m = self.core_class_obj.get_mass();
            field = fieldnames(self.window_class_obj);
            for i=1:length(field)
                m = m+self.window_class_obj.(field{i}).get_mass();
            end
        end

        function m = get_active_mass(self)
            % get the mass of the core and winding
            %     - m - struct with the mass
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            m.core = self.core_class_obj.get_mass();
            field = fieldnames(self.window_class_obj);
            m.window = 0.0;
            for i=1:length(field)
                m.window = m.window+self.window_class_obj.(field{i}).get_mass();
            end
            m.active = m.core+m.window;
        end
        
        function fig = get_plot(self)
            % make plots with the core and winding geometry
            %     - fig - array of handler of the created figures
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fig = [];
            fig(end+1) = self.core_class_obj.get_plot();
            field = fieldnames(self.window_class_obj);
            for i=1:length(field)
                fig(end+1) = self.window_class_obj.(field{i}).get_plot();
            end
        end
        
        function circuit = get_circuit(self)
            % get the equivalent circuit of the components
            %     - circuit - struct with the equivalent circuit
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get the core circuit
            circuit_raw = self.core_class_obj.get_circuit();
            circuit = self.core_adapter_obj.parse_circuit(circuit_raw);
            
            % add the winding windows circuit
            field = fieldnames(self.window_class_obj);
            for i=1:length(field)
                circuit_raw = self.window_class_obj.(field{i}).get_circuit();
                circuit = self.window_adapter_obj.(field{i}).parse_circuit(circuit, circuit_raw);
            end
        end
        
        function losses = get_core_losses(self, stress)
            % get the core losses with a given stress (current, temperature, etc.)
            %     - stress - stress applied to the component (core)
            %     - losses - struct with the core losses
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get the core losses
            losses = self.core_class_obj.get_losses(stress);            
        end
        
        function losses = get_window_losses(self, stress)
            % get the window losses with a given stress (current, temperature, etc.)
            %     - stress - stress applied to the component (window)
            %     - losses - struct with the window losses
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % add the winding window losses
            losses = struct();
            field = fieldnames(self.window_class_obj);
            for i=1:length(field)
                losses_raw = self.window_class_obj.(field{i}).get_losses(stress);
                losses = self.window_adapter_obj.(field{i}).parse_losses(losses, losses_raw);
            end
        end
        
        function losses = get_losses(self, stress)
            % get the core and winding losses with a given stress (current, temperature, etc.)
            %     - stress - stress applied to the component (core and winding)
            %     - losses - struct with the core and winding losses
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get the core losses
            losses.core = self.get_core_losses(stress.core);
            losses.window = self.get_window_losses(stress.window);
                        
            % sum core and winding losses
            losses.P = losses.core.P+losses.window.P;
            losses.is_valid = losses.core.is_valid&&losses.window.is_valid;
        end
    end
end
