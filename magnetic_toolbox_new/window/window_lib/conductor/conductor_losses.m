% =================================================================================================
% Compute losses (skin and proximity) of round plain or round litz wire
% =================================================================================================
%
% Compute the losses of a wire (plain or litz) with:
%     - skin effect
%     - internal proximity effect
%     - external proximity effect
%
% All parameters are computed for 1 m in the third dimension.
%
% =================================================================================================
%
% Warning: These computation are 2D approximations. The wires are accepted to be round.
%          For litz wire, the density of strands is accepted to be infinite.
%          For litz wire, the lay length is neglected.
%          For litz wire, the wire is perfectly twisted..
%
% Warning: The external magnetic field is considered to be constant over the conductor area.
%          If the total (internal+external) field is considered, the external field should be taken in the middle of the conductor.
%
% =================================================================================================
%
% References:
%     - Muehlethaler, J. / Modeling and multi-objective optimization of inductive power components / ETHZ / 2012
%     - Biela, J. / Wirbelstromverluste in Wicklungen induktiver Bauelemente / ETHZ / 2012
%     - Guillod, T. / On the Computation of Litz Wire Losses: Analytical against Numerical Solutions / ETHZ / 2016
%
% See also:
%     - conductor_geom (manage the geometrical parameter of the wire)
%
% =================================================================================================
% (c) 2016-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod, BSD License
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef conductor_losses < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        conductor % struct with the material and geometrical parameters
    end
    
    %% init
    methods (Access = public)
        function self = conductor_losses(conductor)
            % create the object
            %     - conductor - struct with the material and geometrical parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set data
            self.conductor = conductor;
            
            % check data
            validateattributes(self.conductor.sigma.alpha, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.conductor.sigma.rho, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.conductor.sigma.T_ref, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.conductor.mu, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            
            switch self.conductor.type
                case 'plain'
                    validateattributes(self.conductor.d_c, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
                case 'litz'
                    validateattributes(self.conductor.d_c, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
                    validateattributes(self.conductor.d_litz, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
                    validateattributes(self.conductor.n_litz, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
                otherwise
                    error('invalid type');
            end
        end
    end
    
    %% public api
    methods (Access = public)
        function conductor = get_conductor(self)
            % get the conductor parameter
            %     - conductor - struct with the material and geometrical parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            conductor = self.conductor;
        end
        
        function P = get_losses(self, f_vec, T, I_peak_vec, H_peak_vec)
            % get the losses (per meter) for the given excitation
            %     - f_vec - vector with the frequency components
            %     - T - scalar with the temperature
            %     - I_peak_vec - vector with the peak current harmonics
            %     - H_peak_vec - vector with the peak external magnetic field harmonics
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % check data
            validateattributes(f_vec, {'double'},{'row', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(T, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(I_peak_vec, {'double'},{'row', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(H_peak_vec, {'double'},{'row', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            assert(length(f_vec)==length(I_peak_vec), 'invalid data')
            assert(length(f_vec)==length(H_peak_vec), 'invalid data')
            
            % get the losses
            switch self.conductor.type
                case 'plain'
                    P = self.get_losses_plain(f_vec, T, I_peak_vec, H_peak_vec);
                case 'litz'
                    P = self.get_losses_litz(f_vec, T, I_peak_vec, H_peak_vec);
                otherwise
                    error('invalid type');
            end
        end
    end
    
    %% private api
    methods (Access = private)
        function P = get_losses_plain(self, f_vec, T, I_peak_vec, H_peak_vec)
            % get the losses (per meter) for a plain conductor
            %     - f_vec - vector with the frequency components
            %     - T - scalar with the temperature
            %     - I_peak_vec - vector with the peak current harmonics
            %     - H_peak_vec - vector with the peak external magnetic field harmonics
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get the DC resistance and the AC coefficient for the wire
            [Rdc, FR, GR] = self.get_Rdc_FR_GR(f_vec, T, self.conductor.d_c);
            
            % compute the losses
            P_skin = Rdc.*FR.*I_peak_vec.^2;
            P_proxy = Rdc.*GR.*H_peak_vec.^2;
            
            % sum the spectral components
            P = sum(P_skin+P_proxy);
        end
        
        function P = get_losses_litz(self, f_vec, T, I_peak_vec, H_peak_vec)
            % get the losses (per meter) for a litz wire
            %     - f_vec - vector with the frequency components
            %     - T - scalar with the temperature
            %     - I_peak_vec - vector with the peak current harmonics
            %     - H_peak_vec - vector with the peak external magnetic field harmonics
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get the DC resistance and the AC coefficient for a strand
            [Rdc, FR, GR] = self.get_Rdc_FR_GR(f_vec, T, self.conductor.d_litz);
                        
            % skin effect losses
            P_skin = (self.conductor.n_litz.*Rdc.*FR).*(I_peak_vec./self.conductor.n_litz).^2;
            
            % internal proximity losses
            area = pi.*(self.conductor.d_c./2.0).^2;
            H_int_square = 1./(8.*pi);
            P_proxy_int = (H_int_square./area).*(self.conductor.n_litz.*Rdc.*GR).*I_peak_vec.^2;
            
            % external proximity losses
            P_proxy_ext = self.conductor.n_litz.*Rdc.*GR.*H_peak_vec.^2;
                        
            % sum the spectral components
            P = sum(P_skin+P_proxy_int+P_proxy_ext);
        end
    end
    
    
    %% public abstract api
    methods (Access = private)
        function [Rdc, FR, GR] = get_Rdc_FR_GR(self, f, T, d)
            % get the DC resitance and the AC coefficients
            %     - f - vector with the frequency components
            %     - T - scalar with the temperature
            %     - d - scalar with the diameter of the wire
            %     - Rdc - scalar with the DC resistance
            %     - FR - vector with the AC coefficient for the skin effect
            %     - GR - vector with the AC coefficient for the proximity effect
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get material parameters
            sigma = self.get_sigma(T);
            mu = self.conductor.mu;
            
            % compute data
            [FR, GR] = self.get_bessel_FR_GR(f, sigma, mu, d);
            Rdc = 1./(sigma.*pi.*(d./2.0).^2);
        end
        
        function sigma = get_sigma(self, T)
            % get the conductivity for a given temperature
            %     - T - scalar with the temperature
            %     - sigma - scalar with the conductivity
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            rho = self.conductor.sigma.rho;
            alpha = self.conductor.sigma.alpha;
            T_ref = self.conductor.sigma.T_ref;
            sigma = 1./(rho.*(1+alpha.*(T-T_ref)));
        end
        
        function [FR, GR] = get_bessel_FR_GR(self, f, sigma, mu, d)
            % get the AC coefficients for skin and proximity
            %     - f - vector with the frequency components
            %     - sigma - scalar with the conductivity
            %     - sigma - scalar with the conductivity
            %     - mu - scalar with the permeability
            %     - d - scalar with the diameter of the wire
            %     - FR - vector with the AC coefficient for the skin effect
            %     - GR - vector with the AC coefficient for the proximity effect
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get the skin depth
            mu0 = 4*pi*1e-7;
            delta = 1./sqrt(pi.*mu0.*mu.*sigma.*f);
            chi = d./(sqrt(2).*delta);
                        
            % coefficient for the skin effect
            num_1 = self.KelvinBer(0,chi).*self.KelvinBei(1,chi)-self.KelvinBer(0,chi).*self.KelvinBer(1,chi);
            num_2 = self.KelvinBei(0,chi).*self.KelvinBer(1,chi)+self.KelvinBei(0,chi).*self.KelvinBei(1,chi);
            den = self.KelvinBer(1,chi).^2+self.KelvinBei(1,chi).^2;
            FR = chi./(4.*sqrt(2)).*((num_1-num_2)./den);
            FR(f==0) = 1.0;
            
            % coefficient for the proximity effect
            num_1 = self.KelvinBer(2,chi).*self.KelvinBer(1,chi)+self.KelvinBer(2,chi).*self.KelvinBei(1,chi);
            num_2 = self.KelvinBei(2,chi).*self.KelvinBei(1,chi)-self.KelvinBei(2,chi).*self.KelvinBer(1,chi);
            den = self.KelvinBer(0,chi).^2+self.KelvinBei(0,chi).^2;
            GR = -chi.*pi.^2.*d.^2./(2.*sqrt(2)).*((num_1+num_2)./den);
        end
        
        function out = KelvinBer(self, v,x)
            % get the Kelvin function (real part)
            %     - v - scalar with the order
            %     - x - vector with the value
            %     - out - vector with the result
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            out = real(besselj(v, x.*exp(3.*1i.*pi./4)));
        end
        
        function out = KelvinBei(self, v,x)
            % get the Kelvin function (image part)
            %     - v - scalar with the order
            %     - x - vector with the value
            %     - out - vector with the result
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            out = imag(besselj(v, x.*exp(3.*1i.*pi./4)));
        end
    end
end
