% =================================================================================================
% Compute the position of a winding with respect to the winding window.
% =================================================================================================
%
% Place the winding with respect to the winding window.
% Left, right, top, bottom, and center placements are possible.
%
% =================================================================================================
%
% See also:
%     - winding_manager (main class)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef winding_geom_external < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        window % struct with the size of the window
        winding_size % struct with the size of the winding to be placed
        external % struct with the information about the placement
        winding_shift % struct with the computed shift with respect to the center of the window
    end
    
    %% init
    methods (Access = public)
        function self = winding_geom_external(window, winding_size, external)
            % create the object
            %     - window - struct with the size of the window
            %     - winding_size - struct with the size of the winding to be placed
            %     - external - struct with the information about the placement
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set the data
            self.window = window;
            self.winding_size = winding_size;
            self.external = external;
            
            % check data
            assert(any(strcmp(self.external.type, {'top', 'bottom', 'left', 'right', 'center'})), 'invalid data');
            validateattributes(self.external.h_shift, {'double'},{'scalar', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.external.d_shift, {'double'},{'scalar', 'nonempty', 'nonnan', 'real','finite'});
            
            % compute the position of the winding
            self.init_data();
        end
    end
    
    %% public api
    methods (Access = public)
        function window = get_window(self)
            % get the size of the window
            %     - window - struct with the size of the window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            window = self.window;
        end
        
        function winding_size = get_winding_size(self)
            % get the size of the winding
            %     - winding_size - struct with the size of the winding to be placed
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            winding_size = self.winding_size;
        end
        
        function external = get_external(self)
            % get the placement information
            %     - external - struct with the information about the placement
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            external = self.external;
        end
        
        function winding_shift = get_winding_shift(self)
            % get the winding shift with respect to the window
            %     - winding_shift - struct with the computed shift with respect to the center of the window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            winding_shift = self.winding_shift;
        end
    end
    
    %% private api
    methods (Access = private)
        function init_data(self)
            % compute the shift of the winding position
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            switch self.external.type
                case 'top'
                    x_tmp = 0.0;
                    y_tmp = (self.window.h-self.winding_size.h)./2.0;
                case 'bottom'
                    x_tmp = 0.0;
                    y_tmp = (-self.window.h+self.winding_size.h)./2.0;
                case 'left'
                    y_tmp = 0.0;
                    x_tmp = (-self.window.d+self.winding_size.d)./2.0;
                case 'right'
                    y_tmp = 0.0;
                    x_tmp = (self.window.d-self.winding_size.d)./2.0;
                case 'center'
                    x_tmp = 0.0;
                    y_tmp = 0.0;
                otherwise
                    error('invalid data')
            end
            
            self.winding_shift.x = x_tmp+self.external.d_shift;
            self.winding_shift.y = y_tmp+self.external.h_shift;
        end
    end
end
