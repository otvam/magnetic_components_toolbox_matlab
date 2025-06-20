% =================================================================================================
% Compute the loss map.
% =================================================================================================
%
% Manage the losses map.
% Find the local steinmetz parameters.
%
% =================================================================================================
%
% See also:
%     - core_material (main class)
%
% =================================================================================================
% (c) 2021, T. Guillod, BSD License
% =================================================================================================
classdef core_steinmetz_map < handle
    %% properties
    properties (SetAccess = private, GetAccess = private)
        losses_map % struct with the loss map
    end
    
    %% init
    methods (Access = public)
        function self = core_steinmetz_map(losses_map)
            % create the object
            %     - losses_map - struct with the loss map
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % fix scalar dimensions

            % set the data
            self.losses_map = losses_map;

            % expand singleton
            self.init_expand_losses_map();

            % check data
            self.init_check_losses_map();
        end
    end
    
    %% public api
    methods (Access = public)
        function losses_map = get_losses_map(self)
            % get the loss map
            %     - losses_map - scalar with the density of the material
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            losses_map = self.losses_map;
        end
        
        function param = get_param(self, f, B_peak, B_dc, T)
            % get the (locally fitted) steinmetz parameters (with validty check)
            %     - f - scalar with the frequency
            %     - B_peak - scalar with the peak flux density
            %     - B_dc - scalar with the DC flux density
            %     - T - scalar with the temperature
            %     - param - struct with the steinmetz parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            is_valid = self.check_param(f, B_peak, B_dc, T);
            [alpha, beta, k, ki] = self.get_param_sub(f, B_peak, B_dc, T);
            
            param.alpha = alpha;
            param.beta = beta;
            param.k = k;
            param.ki = ki;
            param.is_valid = is_valid;
        end
    end
    
    %% private api - check data
    methods (Access = private)
        function init_expand_losses_map(self)
            % expand singleton dimension for temperature and DC flux density
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            T_vec = self.losses_map.T.vec;
            B_dc_vec = self.losses_map.B_dc.vec;
            P_f_B_peak_B_dc_T = self.losses_map.P_f_B_peak_B_dc_T;

            if isscalar(T_vec)
                eps_tmp = eps(T_vec);
                T_vec = [T_vec-eps_tmp T_vec+eps_tmp];
                P_f_B_peak_B_dc_T = repmat(P_f_B_peak_B_dc_T, 1, 1, 1, 2);
            end
            if isscalar(B_dc_vec)
                eps_tmp = eps(B_dc_vec);
                B_dc_vec = [B_dc_vec-eps_tmp B_dc_vec+eps_tmp];
                P_f_B_peak_B_dc_T = repmat(P_f_B_peak_B_dc_T, 1, 1, 2, 1);
            end

            self.losses_map.T.vec = T_vec;
            self.losses_map.B_dc.vec = B_dc_vec;
            self.losses_map.P_f_B_peak_B_dc_T = P_f_B_peak_B_dc_T;
        end

        function init_check_losses_map(self)
            % check the validity of the loss map
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            self.check_data(self.losses_map.T);
            self.check_data(self.losses_map.B_dc);
            self.check_data(self.losses_map.f);
            self.check_data(self.losses_map.B_peak);
            
            validateattributes(self.losses_map.P_f_B_peak_B_dc_T, {'double'},{'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            validateattributes(self.losses_map.P_f_B_peak_B_dc_T, {'double'},{'ndims', 4});
            assert(size(self.losses_map.P_f_B_peak_B_dc_T, 1)==length(self.losses_map.f.vec), 'invalid data')
            assert(size(self.losses_map.P_f_B_peak_B_dc_T, 2)==length(self.losses_map.B_peak.vec), 'invalid data')
            assert(size(self.losses_map.P_f_B_peak_B_dc_T, 3)==length(self.losses_map.B_dc.vec), 'invalid data')
            assert(size(self.losses_map.P_f_B_peak_B_dc_T, 4)==length(self.losses_map.T.vec), 'invalid data')
        end
        
        function check_data(self, limit)
            % check the validity of the sample points and of the range
            %     - limit - struct with the sample vector and the range
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            validateattributes(limit.range, {'double'},{'row', 'increasing','nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            assert(length(limit.range)>=2, 'invalid data');

            validateattributes(limit.vec, {'double'},{'row', 'increasing','nonnegative', 'nonempty', 'nonnan', 'real','finite'});
            assert(length(limit.vec)>=2, 'invalid data');
        end
    end
    
    %% private api - manage steinmetz
    methods (Access = private)
        function is_valid = check_param(self, f, B_peak, B_dc, T)
            % find if a point is inside the given range of the loss map
            %     - f - scalar with the frequency
            %     - B_peak - scalar with the peak flux density
            %     - B_dc - scalar with the DC flux density
            %     - T - scalar with the temperature
            %     - is_valid - boolean with the validity of the point
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            is_valid_T = self.find_in_range(self.losses_map.T.range, T);
            is_valid_B_dc = self.find_in_range(self.losses_map.B_dc.range, B_dc);
            is_valid_f = self.find_in_range(self.losses_map.f.range, f);
            is_valid_B_peak = self.find_in_range(self.losses_map.B_peak.range, B_peak);
            
            is_valid = is_valid_T&&is_valid_B_dc&&is_valid_f&&is_valid_B_peak;
        end
        
        function [alpha, beta, k, ki] = get_param_sub(self, f, B_peak, B_dc, T)
            % get the (locally fitted) steinmetz parameters (without validty check)
            %     - f - scalar with the frequency
            %     - B_peak - scalar with the peak flux density
            %     - B_dc - scalar with the DC flux density
            %     - T - scalar with the temperature
            %     - param - struct with the steinmetz parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % interpolate the loss map for B_dc and T
            P_f_B_peak = self.get_param_T_B_dc(B_dc, T);
            
            % fit the steimetz parameters for f and B_peak
            [alpha, beta, k, ki] = self.get_param_f_B_peak(P_f_B_peak, f, B_peak);
        end
        
        function P_f_B_peak = get_param_T_B_dc(self, B_dc, T)
            % interpolate linearly the loss map for B_dc and T
            %     - B_dc - scalar with the DC flux density
            %     - T - scalar with the temperature
            %     - P_f_B_peak - matrix with the interpolated parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % clamp the parameters in the given range
            B_dc = self.find_clamp(self.losses_map.B_dc.range, B_dc);
            T = self.find_clamp(self.losses_map.T.range, T);
            
            % grid paramters
            idx_B_peak = 1:length(self.losses_map.B_peak.vec);
            B_dc_vec = self.losses_map.B_dc.vec;
            idx_f = 1:length(self.losses_map.f.vec);
            T_vec = self.losses_map.T.vec;
            data = self.losses_map.P_f_B_peak_B_dc_T;
            
            % interpolate
            vec = {idx_f, idx_B_peak, B_dc_vec, T_vec};
            pts = {idx_f, idx_B_peak, B_dc, T};
            P_f_B_peak = self.interp_grid(vec, data, pts, self.losses_map.interp_T_B_dc);
        end
        
        function [alpha, beta, k, ki] = get_param_f_B_peak(self, P_f_B_peak, f, B_peak)
            % fit the steimetz parameter with the three nearest points (f and B_peak)
            %     - P_f_B_peak - matrix with the interpolated parameters
            %     - f - scalar with the frequency
            %     - B_peak - scalar with the peak flux density
            %     - alpha - SE parameter
            %     - beta - SE parameter
            %     - k - SE parameter
            %     - ki - IGSE parameter
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % clamp the parameters in the given range
            f = self.find_clamp(self.losses_map.f.range, f);
            B_peak = self.find_clamp(self.losses_map.B_peak.range, B_peak);
            
            % find the two nearest points for the frequency
            idx_f = self.find_nearest(self.losses_map.f.vec, f);
            f_vec = self.losses_map.f.vec(idx_f);
            
            % find the two nearest points for the flux density
            idx_B_peak = self.find_nearest(self.losses_map.B_peak.vec, B_peak);
            B_peak_vec = self.losses_map.B_peak.vec(idx_B_peak);
            
            % compute the steimetz parameters
            P_f_B_peak_mat = P_f_B_peak(idx_f, idx_B_peak);
            [alpha_vec, beta_vec] = self.compute_steinmetz_alpha_beta(f_vec, B_peak_vec, P_f_B_peak_mat);
            
            % interpolate alpha and beta
            alpha = self.interp_grid({B_peak_vec}, alpha_vec, {B_peak}, self.losses_map.interp_f_B_peak);
            beta = self.interp_grid({f_vec}, beta_vec, {f}, self.losses_map.interp_f_B_peak);
            
            % interpolate k
            k_mat = self.compute_steinmetz_k(f_vec, B_peak_vec, P_f_B_peak_mat, alpha, beta);
            k = self.interp_grid({f_vec, B_peak_vec}, k_mat, {f, B_peak}, self.losses_map.interp_f_B_peak);
            
            % compute IGSE parameter
            ki = self.compute_steinmetz_ki(alpha, beta, k);
        end
        
        function [alpha_vec, beta_vec] = compute_steinmetz_alpha_beta(self, f_vec, B_peak_vec, P_f_B_peak_mat)
            % get the steinmetz parameters alpha and beta (vector, all values defined by four points)
            %     - f_vec - vector with the two frequency points
            %     - B_peak_vec - vector with the two flux density points
            %     - P_f_B_peak_mat - matrix with the four corresponding losses
            %     - alpha_vec - vector with the SE parameter
            %     - beta_vec - vector with the SE parameter
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            f_0 = f_vec(1);
            f_1 = f_vec(2);
            P_0 = P_f_B_peak_mat(1, :);
            P_f = P_f_B_peak_mat(2, :);
            alpha_vec = log(P_0./P_f)./log(f_0./f_1);
            
            B_peak_0 = B_peak_vec(1);
            B_peak_1 = B_peak_vec(2);
            P_0 = P_f_B_peak_mat(:, 1).';
            P_B_peak = P_f_B_peak_mat(:, 2).';
            beta_vec = log(P_0./P_B_peak)./log(B_peak_0./B_peak_1);
        end
        
        function k_mat = compute_steinmetz_k(self, f_vec, B_peak_vec, P_f_B_peak_mat, alpha, beta)
            % get the steinmetz parameters k (matrix, all values defined by four points)
            %     - f_vec - vector with the two frequency points
            %     - B_peak_vec - vector with the two flux density points
            %     - P_f_B_peak_mat - matrix with the four corresponding losses
            %     - alpha - SE parameter
            %     - beta - SE parameter
            %     - k_mat - matrix with the SE parameter
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            f_mat = [f_vec.' f_vec.'];
            B_peak_mat = [B_peak_vec ; B_peak_vec];
            k_mat = P_f_B_peak_mat./((f_mat.^alpha).*(B_peak_mat.^beta));
        end
        
        function ki = compute_steinmetz_ki(self, alpha, beta, k)
            % get the IGSE parameter ki
            %     - alpha - SE parameter
            %     - beta - SE parameter
            %     - k - SE parameter
            %     - ki - IGSE parameter
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            t1 = (2.*pi).^(alpha-1);
            t2 = 2.*sqrt(pi).*gamma(1./2+alpha./2)./gamma(1+alpha./2);
            t3 = 2.^(beta-alpha);
            ki = k./(t1.*t2.*t3);
        end
    end
    
    %% private api - utils
    methods (Access = private)
        function is_valid = find_in_range(self, vec, pts)
            % check if a point is in a given range
            %     - vec - vector with the range
            %     - pts - scalar with the point
            %     - is_valid - boolean with the range comparison
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            is_valid = (pts>=min(vec))&&(pts<=max(vec));
        end
        
        function pts_clamp = find_clamp(self, vec, pts)
            % clamp a point in a given range
            %     - vec - vector with the range
            %     - pts - scalar with the point
            %     - pts_clamp - scalar with the clamped point
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            pts_clamp = pts;
            pts_clamp = max(pts_clamp, min(vec));
            pts_clamp = min(pts_clamp, max(vec));
        end
        
        function idx = find_nearest(self, vec, pts)
            % find the two nearest points (less and greater than the reference) in a vec
            %     - vec - vector with the sample points
            %     - pts - scalar with the point
            %     - idx - vector with the index of the nearest points
            %     - idx_1 - integer with the index of the second point
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            idx_0 = find(vec<=pts, true, 'last');
            idx_1 = find(vec>pts, true, 'first');
            
            if isempty(idx_0)
                idx_0 = 1;
                idx_1 = 2;
            end
            if isempty(idx_1)
                idx_0 = length(vec)-1;
                idx_1 = length(vec);
            end
            
            idx = [idx_0 idx_1];
        end
        
        function value = interp_grid(self, vec, data, pts, interp)
            % grid interpolation in n dimension
            %     - vec - cell with the sample points
            %     - data - matrix with the data
            %     - pts - cell with the points to evaluate
            %     - interp - struct with the interpolation method
            %     - value - matrix with the interpolated values
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            interp = griddedInterpolant(vec, data, interp.method, interp.extrap);
            value = interp(pts);
        end
    end
end