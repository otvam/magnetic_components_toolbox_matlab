% =================================================================================================
% Abstract class for defining magnetic components (transformer, inductor, etc.).
% =================================================================================================
%
% Define an interface for:
%     - parsing the core data
%     - parsing the winding window data
%     - computed the box volume
%
% =================================================================================================
%
% See also:
%     - component_class (main class)
%     - core_adapter (class for managing the core)
%     - window_adapter (class for managing the window)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef component_type_abstract < handle
    %% properties
    properties (SetAccess = protected, GetAccess = protected)
        core % struct with the core geometry and material
        winding % struct with the winding geometry and material
        core_adapter_obj  % instance of core_adapter
        window_adapter_obj % struct with instances of window_adapter
        window % struct with the size of the winding window
    end
    
    %% init
    methods (Access = public)
        function self = component_type_abstract(core, winding)
            % create the object
            %     - core - struct with the core data
            %     - winding - struct with the winding data
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set the data
            self.core = core;
            self.winding = winding;
            
            % init the data
            self.window_adapter_obj = struct();
            self.core_adapter_obj = [];
            self.window = struct();
        end
    end
    
    %% public api
    methods (Access = public)
        function core_adapter_obj = get_core_adapter_obj(self)
            % get the instance of core_adapter
            %     - core_adapter_obj - instance of core_adapter
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            core_adapter_obj = self.core_adapter_obj;
        end
        
        function window_adapter_obj = get_window_adapter_obj(self)
            % get the instances of window_adapter
            %     - window_adapter_obj - struct of instances of window_adapter
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            window_adapter_obj = self.window_adapter_obj;
        end
        
        function core_class_obj = get_core_class_obj(self)
            % get the instance of core_class
            %     - core_class_obj - instance of core_class
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            core_class_obj = self.core_adapter_obj.get_core_class_obj();
        end
        
        function window_class_obj = get_window_class_obj(self)
            % get the instances of window_class
            %     - window_class_obj - struct of instances of window_class
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            field = fieldnames(self.window_adapter_obj);
            for i=1:length(field)
                window_class_obj.(field{i}) = self.window_adapter_obj.(field{i}).get_window_class_obj();
            end
        end
    end
    
    %% public abstract api
    methods (Abstract, Access=public)
        type = get_type(self)
        % get the type of the component
        %     - type - string with the component type
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        V = get_box_volume(self)
        % get the box volume of the component
        %     - V - scalar with the box volume
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end