% =================================================================================================
% Manage the properties of a single winding.
% =================================================================================================
%
% Manage and compute the following winding properties:
%     - place the winding with respect to the winding window
%     - place the conductors inside the winding
%     - get the geometrical properties
%     - compute the losses
%
% =================================================================================================
%
% See also:
%     - conductor_geom (manage the geometry of the wires)
%     - conductor_losses (manage the losses of the wires)
%     - winding_geom_internal (placement of the conductors inside the winding)
%     - winding_geom_external (placement of the winding with respect to the window)
%     - window_component_abstract (main class)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef winding_manager < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        conductor_geom_obj % instance of conductor_geom
        conductor_losses_obj % instance of conductor_losses
        winding_geom_internal_obj % instance of winding_geom_internal
        winding_geom_external_obj % instance of winding_geom_external
        conductor % struct with the position of the conductors
        z_size % struct with the length of the winding
    end
    
    %% init
    methods (Access = public)
        function self = winding_manager(window, winding)
            % create the object
            %     - window - struct with the size of the window
            %     - winding - struct with the information about the winding geometry and the conductor
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % create the class for managing the conductors
            self.conductor_geom_obj = conductor_geom(winding.conductor);
            self.conductor_losses_obj = conductor_losses(winding.conductor);
            
            % place the conductors inside the winding
            d_c = self.conductor_geom_obj.get_diameter();
            self.winding_geom_internal_obj = winding_geom_internal(winding.internal, d_c);
            
            % place the winding with respect to the window
            winding_size = self.winding_geom_internal_obj.get_winding_size();
            self.winding_geom_external_obj = winding_geom_external(window, winding_size, winding.external);
            
            % find the position of the conductors
            self.init_conductor();
            
            % find the position in the third dimension
            self.init_z_size();
        end
    end
    
    %% public api
    methods (Access = public)
        function conductor = get_conductor(self)
            % get the position of the conductors with respect to the window
            %     - conductor - struct with the position of the conductors
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            conductor = self.conductor;
        end
        
        function n_winding = get_n_winding(self)
            % get the total number of turns
            %     - n_winding - strcut with the number of turns
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            n_winding = self.winding_geom_internal_obj.get_n_winding();
        end
        
        function n_par = get_n_par(self)
            % get the number of parallel turns
            %     - n_par - strcut with the number of parallel turns
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            n_par = self.winding_geom_internal_obj.get_n_par();
        end
        
        function V = get_copper_volume(self)
            % get the copper volume of the wires
            %     - V - scalar with the volume
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            A = self.conductor_geom_obj.get_copper_area();
            V = self.z_size.sum.*A;
        end
        
        function V = get_conductor_volume(self)
            % get the total (copper and insulation) volume of the wires
            %     - V - scalar with the volume
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            A = self.conductor_geom_obj.get_conductor_area();
            V = self.z_size.sum.*A;
        end
        
        function m = get_mass(self)
            % get the mass of the winding
            %     - m - scalar with the mass
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            m = self.conductor_geom_obj.get_mass();
            m = self.z_size.sum.*m;
        end
        
        function P = get_losses(self, f_vec, T, I_peak_vec, H_peak_mat)
            % get the losses of the conductors for the given excitation
            %     - f_vec - vector with the frequency components
            %     - T - scalar with the temperature
            %     - I_peak_vec - vector with the peak current harmonics
            %     - H_peak_mat - matrix with the peak external magnetic field harmonics
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            H_peak_scale_vec = sqrt(self.z_size.all*(H_peak_mat.^2));
            I_peak_scale_vec = sqrt(self.z_size.sum)*I_peak_vec;
            
            P = self.conductor_losses_obj.get_losses(f_vec, T, I_peak_scale_vec, H_peak_scale_vec);
        end
    end
    
    %% private api
    methods (Access = private)
        function init_conductor(self)
            % find the position of the conductors with respect to the window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get the position
            self.conductor = self.winding_geom_internal_obj.get_conductor();
            winding_shift = self.winding_geom_external_obj.get_winding_shift();
            
            % shift the conductors with respect to the window
            self.conductor.x = self.conductor.x+winding_shift.x;
            self.conductor.y = self.conductor.y+winding_shift.y;
            self.conductor.d_c = self.get_diameter();
        end
        
        function d_c = get_diameter(self)
            % get the diameter of the conductors
            %     - z_size - vector with the diameter of the conductors
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            n_winding = self.winding_geom_internal_obj.get_n_winding();
            d_c = self.conductor_geom_obj.get_diameter();
            d_c = d_c.*ones(1, n_winding);
        end
        
        function init_z_size(self)
            % find the length in the third dimension
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % winding length
            self.z_size.all = self.get_z_size(self.conductor.x, self.conductor.y);
            
            % total winding length
            self.z_size.sum = sum(self.z_size.all);
        end
        
        function z_size = get_z_size(self, x_position, y_position)
            % get the size in the third dimension
            %     - x_position - vector with the x position of the point to compute
            %     - y_position - vector with the y position of the point to compute
            %     - z_size - vector with the size in the third dimension
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            window = self.winding_geom_external_obj.get_window();
            
            x = [-window.d./2.0 +window.d./2.0];
            y = [-window.h./2.0 +window.h./2.0];
            z = [window.z_bottom_left window.z_top_left ; window.z_bottom_right window.z_top_right];
            
            interp = griddedInterpolant({x, y}, z, 'linear', 'linear');
            z_size = interp(x_position, y_position);
        end
    end
end
