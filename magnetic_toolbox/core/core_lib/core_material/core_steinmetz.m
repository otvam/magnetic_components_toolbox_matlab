% =================================================================================================
% Compute the loss map and the losses using GSE and IGSE.
% =================================================================================================
%
% Manage the losses map.
% Compute the losses with GSE.
% Compute the losses with IGSE.
%
% =================================================================================================
%
% See also:
%     - core_material (main class)
%     - core_steinmetz_map (manage loss map)
%     - core_steinmetz_losses (compute losses)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef core_steinmetz < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        core_steinmetz_map_obj % instance of core_steinmetz_map
        core_steinmetz_losses_obj % instance of core_steinmetz_losses
    end
    
    %% init
    methods (Access = public)
        function self = core_steinmetz(losses_map)
            % create the object
            %     - losses_map - struct with the loss map
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % create the objects
            self.core_steinmetz_map_obj = core_steinmetz_map(losses_map);
            self.core_steinmetz_losses_obj = core_steinmetz_losses();
        end
    end
    
    %% public api
    methods (Access = public)
        function losses_map = get_losses_map(self)
            % get the loss map
            %     - losses_map - scalar with the density of the material
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            losses_map = self.core_steinmetz_map_obj.get_losses_map();
        end
        
        function param = get_param(self, f, B_peak, B_dc, T)
            % get the (locally fitted) steinmetz parameters
            %     - f - scalar with the frequency
            %     - B_peak - scalar with the peak flux density
            %     - B_dc - scalar with the DC flux density
            %     - T - scalar with the temperature
            %     - param - struct with the steinmetz parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % check data
            validateattributes(T, {'double'},{'scalar', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(B_dc, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(f, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(B_peak, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            
            % compute steinmetz parameter
            param = self.core_steinmetz_map_obj.get_param(f, B_peak, B_dc, T);
        end
        
        function losses = get_losses_gse(self, f, B_peak, B_dc, T)
            % get the losses density computed with the GSE (sinusoidal flux)
            %     - f - scalar with the frequency
            %     - B_peak - scalar with the peak flux density
            %     - B_dc - scalar with the DC flux density
            %     - T - scalar with the temperature
            %     - losses - struct with the losses
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % check data
            validateattributes(T, {'double'},{'scalar', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(B_dc, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(f, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(B_peak, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            
            % compute steinmetz parameter
            param = self.core_steinmetz_map_obj.get_param(f, B_peak, B_dc, T);
            
            % compute losses
            losses.is_valid = param.is_valid;
            losses.P = self.core_steinmetz_losses_obj.get_P_gse(param, f, B_peak);
        end
        
        function losses = get_losses_igse(self, f, d_vec, B_vec, T)
            % get the losses density computed with the IGSE (arbitrary flux)
            %     - f - scalar with the frequency
            %     - d_vec - vector with the normalized (to [0.0, 1.0]) where the flux density is defined
            %     - B_vec - vector with the piecewise linear flux density
            %     - T - scalar with the temperature
            %     - losses - struct with the losses
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % check data
            validateattributes(T, {'double'},{'scalar', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(f, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(d_vec, {'double'},{'row', 'increasing','nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            assert(length(d_vec)>=2, 'invalid data');
            validateattributes(B_vec, {'double'},{'row', 'nonempty', 'nonnan', 'real','finite'});
            assert(length(B_vec)>=2, 'invalid data');
            assert(length(B_vec)>=length(d_vec), 'invalid data');
            
            % compute steinmetz parameter
            [B_peak, B_dc] = self.core_steinmetz_losses_obj.get_param_waveform(d_vec, B_vec);
            param = self.core_steinmetz_map_obj.get_param(f, B_peak, B_dc, T);
            
            % compute losses
            losses.is_valid = param.is_valid;
            losses.P = self.core_steinmetz_losses_obj.get_P_isge(param, f, d_vec, B_vec);
        end
    end
end