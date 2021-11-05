% =================================================================================================
% Definition of a transformer with a C-core (shell type windings).
% =================================================================================================
%
% Transformer with two windings.
% Transformer with a C-core.
%
% =================================================================================================
%
% See also:
%     - component_type_abstract (abtract class for the component defintion)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef transformer_C_type < component_type_abstract
    %% init
    methods (Access = public)
        function self = transformer_C_type(core, winding)
            % create the object
            %     - core - struct with the core geometry and material
            %     - winding - struct with the winding geometry and material
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            self = self@component_type_abstract(core, winding);
            
            % get the core window
            data_add = struct('type', 'transformer', 'geom', 'core', 'z_mean', self.core.z_core, 'z_left', self.core.z_core, 'z_right', self.core.z_core, 'd_core', 0.0);
            self.window_adapter_obj.core = window_adapter(self.core, self.winding, data_add);
            
            % get the window size
            self.window = self.window_adapter_obj.core.get_window();
            assert(self.core.t_core>=2.0.*self.core.r_window, 'invalid data')
            z_left = 2.0.*pi.*self.core.r_window+2.0.*(self.core.t_core-2.0.*self.core.r_window);
            z_right = 2.0.*pi.*(self.core.r_window+self.window.d)+2.0.*(self.core.t_core-2.0.*self.core.r_window);
            z_mean = (z_left+z_right)./2.0;
            z_core = self.core.z_core;
            d_core = self.core.r_window;
            
            % get the winding head near the core
            data_add = struct('type', 'transformer', 'geom', 'core_head', 'z_mean', z_core, 'z_left', z_core, 'z_right', z_core, 'd_core', 0.0);
            self.window_adapter_obj.head_core = window_adapter(self.core, self.winding, data_add);
            
            % get the winding head at the turn
            data_add = struct('type', 'transformer', 'geom', 'core_head', 'z_mean', z_mean, 'z_left', z_left, 'z_right', z_right, 'd_core', d_core);
            self.window_adapter_obj.head_turn = window_adapter(self.core, self.winding, data_add);
            
            % get the core
            data_add = struct('type', 'transformer', 'geom', 'C_type', 'd_window', self.window.d, 'h_window', self.window.h);
            self.core_adapter_obj = core_adapter(self.core, self.winding, data_add);
        end
    end
    
    %% public abstract api
    methods (Access = public)
        function type = get_type(self)
            % get the type of the component
            %     - type - string with the component type
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            type = 'transformer';
        end
        
        function V = get_box_volume(self)
            % get the box volume of the component
            %     - V - scalar with the box volume
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % core
            h = self.window.h+2.0.*self.core.t_core;
            d = 2.0.*self.window.d+2.0.*self.core.t_core;
            z = self.core.z_core+2.0.*(self.window.d+self.core.r_window);
            
            % volume
            V = d.*h.*z;
        end
    end
end