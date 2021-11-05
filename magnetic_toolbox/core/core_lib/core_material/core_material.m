% =================================================================================================
% Core properties (mu, rho) and losses (bases on mapping and GSE and IGSE).
% =================================================================================================
%
% Manage the core properties, including:
%     - mu (permeability)
%     - rho (density)
%     - losses (GSE and IGSE)
%
% The losses are based on a loss map (f, B_peak, B_dc, T).
% The DC flux density and the temperature are linealy interpolated from the loss map.
% The AC flux density and the frequency are fitted using the GSE (nearest point in the loss map).
% Extrapolation outside the loss map is possible (protection mechanisms are implementes)
%
% The losses can be computed with the obtained steinmetz parameters using:
%     - GSE for sinusoidal flux
%     - IGSE for arbitrary flux shape
%
% =================================================================================================
%
% Warning: The GSE and IGSE are empirical models with a very limited range.
%          Extrapolation should be done with care.
%
% Warning: Magnetic relaxation is not considered since such models are difficult to parametrize.
%          Moreover, the predictability of such complex models is limited.
%
% =================================================================================================
%
% References:
%     - Muehlethaler, J. / Modeling and multi-objective optimization of inductive power components / ETHZ / 2012
%     - Venkatachalam, K. and Sullivan, C.R. and Abdallah, T. and Tacca, H. / Accurate Prediction of Ferrite Core Loss with Nonsinusoidal Waveforms Using Only Steinmetz / COMPEL/ 2012
%
% See also:
%     - core_steinmetz (manage loss map and compute losses)
%     - core_steinmetz_map (manage loss map)
%     - core_steinmetz_losses (compute losses)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef core_material < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        mu_core % scalar with the permeability of the core material
        mu_domain % scalar with the permeability of the air
        rho % density of the material
        core_steinmetz_obj % instance of core_steinmetz
    end
    
    %% init
    methods (Access = public)
        function self = core_material(mu_core, mu_domain, rho, losses_map)
            % create the object
            %     - mu_core - scalar with the permeability of the core material
            %     - mu_domain - scalar with the permeability of the air
            %     - rho - scalar with the density of the material
            %     - losses_map - struct with the loss map
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set data
            self.mu_core = mu_core;
            self.mu_domain = mu_domain;
            self.rho = rho;
            
            % create loss map
            self.core_steinmetz_obj = core_steinmetz(losses_map);
            
            % check data
            validateattributes(self.mu_core, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.mu_domain, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.rho, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
        end
    end
    
    %% public api - get data
    methods (Access = public)
        function mu_core = get_mu_core(self)
            % get the permeability of the material
            %     - mu_core - scalar with the permeability of the core material
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            mu_core = self.mu_core;
        end
        
        function mu_domain = get_mu_domain(self)
            % get the permeability of the material
            %     - mu_core - scalar with the permeability of the air
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            mu_domain = self.mu_domain;
        end
        
        function rho = get_rho(self)
            % get the density of the material
            %     - rho - scalar with the density of the material
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            rho = self.rho;
        end
        
        function losses_map = get_losses_map(self)
            % get the loss map
            %     - losses_map - scalar with the density of the material
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            losses_map = self.core_steinmetz_obj.get_losses_map();
        end
    end
    
    %% public api - compute data
    methods (Access = public)
        function param = get_param(self, f, B_peak, B_dc, T)
            % get the (locally fitted) steinmetz parameters
            %     - f - scalar with the frequency
            %     - B_peak - scalar with the peak flux density
            %     - B_dc - scalar with the DC flux density
            %     - T - scalar with the temperature
            %     - param - struct with the steinmetz parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            param = self.core_steinmetz_obj.get_param(f, B_peak, B_dc, T);
        end
        
        function losses = get_losses_gse(self, f, B_peak, B_dc, T)
            % get the losses density computed with the GSE (sinusoidal flux)
            %     - f - scalar with the frequency
            %     - B_peak - scalar with the peak flux density
            %     - B_dc - scalar with the DC flux density
            %     - T - scalar with the temperature
            %     - losses - struct with the losses
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            losses = self.core_steinmetz_obj.get_losses_gse(f, B_peak, B_dc, T);
        end
        
        function losses = get_losses_igse(self, f, d_vec, B_vec, T)
            % get the losses density computed with the IGSE (arbitrary flux)
            %     - f - scalar with the frequency
            %     - d_vec - vector with the normalized (to [0.0, 1.0]) where the flux density is defined
            %     - B_vec - vector with the piecewise linear flux density
            %     - T - scalar with the temperature
            %     - losses - struct with the losses
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            losses = self.core_steinmetz_obj.get_losses_igse(f, d_vec, B_vec, T);
        end
    end
end