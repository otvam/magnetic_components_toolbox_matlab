% =================================================================================================
% Adapater class for winding window computations.
% =================================================================================================
%
% Parse the data for the window solver.
% For transformer and inductor.
% For winding inside the core and winding head.
%
% =================================================================================================
%
% See also:
%     - component_type_abstract (main class)
%     - window_class (class for window geometry, losses, circuit, etc.)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef window_adapter < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        core % struct with the core data
        winding % struct with the winding data
        data_add % struct with the data which are component specific
        window % struct with the geometry of the window
        window_class_obj % instance of window_class
    end
    
    %% init
    methods (Access = public)
        function self = window_adapter(core, winding, data_add)
            % create the object
            %     - core - struct with the core geometry and material
            %     - winding - struct with the winding geometry and material
            %     - data_add - struct with the data which are component specific
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set the data
            self.core = core;
            self.winding = winding;
            self.data_add = data_add;
            
            % set the window size
            switch self.data_add.type
                case 'inductor'
                    self.init_window_inductor(self.winding.winding);
                case 'transformer'
                    self.init_window_transformer(self.winding.lv, self.winding.hv, self.winding.t_winding_lv_hv);
                otherwise
                    error('invalid data')
            end
            
            % parse the data
            [class_tmp, winding_tmp] = self.get_data_class_winding();
            [core_tmp, window_tmp] = self.get_data_core_window();
            
            % create the instance
            self.window_class_obj = window_class(class_tmp, core_tmp, window_tmp, winding_tmp);
        end
    end
    
    %% public api
    methods (Access = public)
        function window_class_obj = get_window_class_obj(self)
            % get the instance of window_class
            %     - window_class_obj - instance of window_class
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            window_class_obj = self.window_class_obj();
        end
        
        function window = get_window(self)
            % get the size of the window (window geometry)
            %     - window - struct with the geometry of the window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            window = self.window;
        end
        
        function circuit = parse_circuit(self, circuit, circuit_raw)
            % parse the equivalent circuit structure for the window
            %     - circuit_raw - struct created by window_class
            %     - circuit - struct with the parsed circuit data
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            switch self.data_add.type
                case 'inductor'
                    % pass
                case 'transformer'
                    circuit.is_valid = circuit.is_valid&&circuit_raw.is_valid;
                    circuit.L_leak.lv = circuit.L_leak.lv+circuit_raw.L_leak.lv;
                    circuit.L_leak.hv = circuit.L_leak.hv+circuit_raw.L_leak.hv;
                otherwise
                    error('invalid data')
            end
        end
                
        function losses = parse_losses(self, losses, losses_raw)
            % parse the losses structure for the window
            %     - losses_raw - struct created by window_class
            %     - losses - struct with the parsed losses data
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if isempty(fieldnames(losses))
                switch self.data_add.type
                    case 'inductor'
                        losses.P = 0.0;
                        losses.is_valid = true;
                    case 'transformer'
                        losses.P = 0.0;
                        losses.P_lv = 0.0;
                        losses.P_hv = 0.0;
                        losses.is_valid = true;
                    otherwise
                        error('invalid data')
                end
            end
            
            switch self.data_add.type
                case 'inductor'
                    losses.P = losses.P+losses_raw.P;
                    losses.is_valid = losses.is_valid&&losses_raw.is_valid;
                case 'transformer'
                    losses.P_lv = losses.P_lv+losses_raw.P_sub.lv;
                    losses.P_hv = losses.P_hv+losses_raw.P_sub.hv;
                    losses.P = losses.P+losses_raw.P;
                    losses.is_valid = losses.is_valid&&losses_raw.is_valid;
                otherwise
                    error('invalid data')
            end
        end
    end
    
    %% private api
    methods (Access = private)
        function [class_tmp, winding_tmp] = get_data_class_winding(self)
            % parse the data for the class, window, and window
            %     - class_tmp - struct with the component type
            %     - window_tmp - struct with winding definition
            %     - winding_tmp - struct with winding definition
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            switch self.data_add.type
                case 'inductor'
                    % inductor with one winding
                    class_tmp.window_component_class = @window_component_inductor;
                    winding_tmp = self.get_winding(self.winding.winding, 'center');
                case 'transformer'
                    % transformer with two windings
                    class_tmp.window_component_class = @window_component_transformer;
                    
                    % right/left placement of the windings
                    switch self.winding.type_winding
                        case 'lv_hv'
                            winding_tmp.lv = self.get_winding(self.winding.lv, 'left');
                            winding_tmp.hv = self.get_winding(self.winding.hv, 'right');
                        case 'hv_lv'
                            winding_tmp.lv = self.get_winding(self.winding.lv, 'right');
                            winding_tmp.hv = self.get_winding(self.winding.hv, 'left');
                        otherwise
                            error('invalid data')
                    end
                otherwise
                    error('invalid data')
            end
            
            switch self.data_add.geom
                case 'core'
                    % window is enclosed by a core
                    class_tmp.window_geom_class = @window_geom_core;
                case 'core_head'
                    % window is not near a core
                    class_tmp.window_geom_class = @window_geom_core_head;
                case 'head'
                    % window is semi-enclosed by a core (window on the right of the core)
                    class_tmp.window_geom_class = @window_geom_head;
                otherwise
                    error('invalid data')
            end
        end
        
        function [core_tmp, window_tmp] = get_data_core_window(self)
            % parse the data for the core and and window
            %     - core_tmp - struct with the core definition
            %     - window_tmp - struct with window definition
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % core
            core_tmp.mu_core = self.core.material.mu_core;
            core_tmp.mu_domain = self.core.material.mu_domain;
            core_tmp.n_mirror = self.winding.n_mirror;
            core_tmp.d_pole = self.winding.d_pole;
            core_tmp.d_core = self.data_add.d_core;
            
            % window
            window_tmp.d = self.window.d;
            window_tmp.h = self.window.h;
            window_tmp.z_mean = self.data_add.z_mean;
            window_tmp.z_top_left = self.data_add.z_left;
            window_tmp.z_top_right = self.data_add.z_right;
            window_tmp.z_bottom_left = self.data_add.z_left;
            window_tmp.z_bottom_right = self.data_add.z_right;
        end
        
        function init_window_inductor(self, winding)
            % set the window size for an inductor
            %     - winding - struct with winding data
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get winding size
            [d, h] = self.get_winding_size(winding);
            
            % get window size
            d_min = d+2.*winding.t_core_x;
            h_min = h+2.*winding.t_core_y;
            
            % fit the window with the core size
            [self.window.d, self.window.d_add] = self.clamp_window_size(d_min, self.winding.d_window);
            [self.window.h, self.window.h_add] = self.clamp_window_size(h_min, self.winding.h_window);
        end
        
        function init_window_transformer(self, winding_lv, winding_hv, t_winding_lv_hv)
            % set the window size for an inductor
            %     - winding_lv - struct with lv winding data
            %     - winding_hv - struct with hv winding data
            %     - t_winding_lv_hv - scalar with the space between the windings
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get winding size
            [d_lv, h_lv] = self.get_winding_size(winding_lv);
            [d_hv, h_hv] = self.get_winding_size(winding_hv);
            d_min = d_lv+d_hv+winding_lv.t_core_x+winding_hv.t_core_x+t_winding_lv_hv;
            
            % get the window height
            h_lv = h_lv+2.*winding_lv.t_core_y;
            h_hv = h_hv+2.*winding_hv.t_core_y;
            h_min = max(h_lv, h_hv);
            
            % fit the window with the core size
            [self.window.d, self.window.d_add] = self.clamp_window_size(d_min, self.winding.d_window);
            [self.window.h, self.window.h_add] = self.clamp_window_size(h_min, self.winding.h_window);
        end
        
        function [x, x_add] = clamp_window_size(self, x_min, x_given)
            % find the size of the core (minimum computed size vs. given core window)
            %     - x_min - double with the minimum size (computed)
            %     - x_given - double with the window size (given or NaN)
            %     - x - double with the final core size
            %     - x_add - double with the additional required core size
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if isnan(x_given)
                x = x_min;
                x_add = 0.0;
            else
                assert(x_given>=x_min, 'invalid data');
                x = x_given;
                x_add = x_given-x_min;
            end
        end
        
        function [d, h] = get_winding_size(self, winding)
            % get the size for a (single) winding
            %     - winding - struct with winding data
            %     - d - scalar with the width of the winding
            %     - h - scalar with the height of the winding
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get data
            n_layer = length(winding.n_winding);
            n_turn = max(winding.n_winding);
            d_c = winding.conductor.d_c;
            
            % winding size
            d = n_layer.*d_c+(n_layer-1).*winding.t_layer;
            h = n_turn.*d_c+(n_turn-1).*winding.t_turn;
        end
        
        function winding_tmp = get_winding(self, winding_data, type)
            % parse the data for a (single) winding
            %     - winding_data - struct with user provided data
            %     - type - string with the placement of the winding
            %     - winding_tmp - struct with the parsed data
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % assign the data
            winding_tmp.conductor = winding_data.conductor;
            winding_tmp.internal.n_winding = winding_data.n_winding;
            winding_tmp.internal.n_par = winding_data.n_par;
            winding_tmp.internal.t_layer = winding_data.t_layer;
            winding_tmp.internal.t_turn = winding_data.t_turn;
            winding_tmp.internal.orientation = 'vertical';
            
            % place the winding inside the window
            switch type
                case 'center'
                    winding_tmp.external = struct('type', 'center', 'd_shift', 0.0, 'h_shift', 0.0);
                case 'left'
                    winding_tmp.external = struct('type', 'left', 'd_shift', +winding_data.t_core_x+self.window.d_add./2.0, 'h_shift', 0.0);
                case 'right'
                    winding_tmp.external = struct('type', 'right', 'd_shift', -winding_data.t_core_x-self.window.d_add./2.0, 'h_shift', 0.0);
                otherwise
                    error('invalid data')
            end
        end
    end
end